#!/usr/bin/env bash
set -o nounset
set -o pipefail

# Cloudflare DDNS（双栈版）：同一个主机名同时维护 A（IPv4）和 AAAA（IPv6）记录
# 基于 cf-v4-ddns.sh 改写，针对 AWS EC2 / Lightsail：
#   - IPv4 优先取实例元数据（IMDSv2 public-ipv4），取不到再问外部网站
#   - IPv6 优先取实例元数据，其次取本机默认路由的源地址（跳过 wg/warp/tun 隧道），最后问外部网站
#   - 记录不存在时自动新建（proxied=false），存在时用 PATCH 只改 IP，保留原来的代理开关和备注
#   - 两种地址互不影响：没有 IPv6 的机器只更新 A，纯 IPv6 机器只更新 AAAA
#   - IP 没变时不打日志、不调 API；每 60 分钟会对照一次 Cloudflare 上的实际值，被别人改了也能纠正回来
#
# 安装（cron 每分钟检查 + 开机立即执行）：
# curl -fsSLo /usr/local/bin/cf-ddns.sh https://raw.githubusercontent.com/EdNovas/vpstoolbox/main/cf-v4v6-ddns.sh && chmod +x /usr/local/bin/cf-ddns.sh
# crontab 加两行：
# @reboot   /usr/local/bin/cf-ddns.sh -k KEY -u EMAIL -z example.com -h host.example.com -w 120 -f true >> /var/log/cf-ddns.log 2>&1
# * * * * * /usr/local/bin/cf-ddns.sh -k KEY -u EMAIL -z example.com -h host.example.com >> /var/log/cf-ddns.log 2>&1

# Usage:
# cf-ddns.sh -k cloudflare-api-key \   # Global API Key；不给 -u 时按 API Token（Bearer）处理
#            -u user@example.com \     # Global API Key 对应的邮箱
#            -z example.com \          # 域名所在的 zone
#            -h host.example.com       # 要更新的主机名，A 和 AAAA 默认都写到这个名字上

# Optional flags:
#            -t both|A|AAAA \          # 更新哪种记录，默认 both
#            -H host6.example.com \    # AAAA 用另一个主机名（默认与 -h 相同）
#            -f false|true \           # 强制对照 Cloudflare 更新，不管本地缓存
#            -w 0 \                    # 取不到 IP 时最多等待的秒数（开机时网络可能还没好，建议 120）
#            -l 60                     # TTL，60~86400，1 为自动

# default config

# API key 或 API Token（Token 需要 Zone.DNS 编辑权限）
CFKEY=

# Global API Key 对应的邮箱；留空则 CFKEY 按 API Token 使用
CFUSER=

# Zone name, eg: example.com
CFZONE_NAME=

# Hostname to update, eg: homeserver.example.com
CFRECORD_NAME=

# AAAA 记录的主机名，留空则与 CFRECORD_NAME 相同
CFRECORD_NAME_V6=

# both|A|AAAA
CFRECORD_TYPE=both

# Cloudflare TTL for record, between 60 and 86400 seconds, 1 = auto
CFTTL=60

# Ignore local cache, check Cloudflare anyway
FORCE=false

# 取不到 IP 时最多等待多少秒
WAIT=0

# 缓存目录（zone id、上次的 IP）
STATE_DIR=${CF_DDNS_STATE_DIR:-/var/lib/cf-ddns}

# 本地缓存多少分钟后重新对照一次 Cloudflare
RECHECK_MINUTES=60

CFAPI=https://api.cloudflare.com/client/v4

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*"
}

# get parameter
while getopts k:u:h:H:z:t:f:w:l: opts; do
  case ${opts} in
    k) CFKEY=${OPTARG} ;;
    u) CFUSER=${OPTARG} ;;
    h) CFRECORD_NAME=${OPTARG} ;;
    H) CFRECORD_NAME_V6=${OPTARG} ;;
    z) CFZONE_NAME=${OPTARG} ;;
    t) CFRECORD_TYPE=${OPTARG} ;;
    f) FORCE=${OPTARG} ;;
    w) WAIT=${OPTARG} ;;
    l) CFTTL=${OPTARG} ;;
    *) exit 2 ;;
  esac
done

case $CFRECORD_TYPE in
  both|BOTH|all|46) CFRECORD_TYPE=both ;;
  A|a|4|v4|ipv4) CFRECORD_TYPE=A ;;
  AAAA|aaaa|6|v6|ipv6) CFRECORD_TYPE=AAAA ;;
  *)
    echo "$CFRECORD_TYPE specified is invalid, -t can only be both|A|AAAA"
    exit 2
    ;;
esac

# If required settings are missing just exit
if [ "$CFKEY" = "" ]; then
  echo "Missing api-key/token, get at: https://dash.cloudflare.com/profile/api-tokens"
  echo "and save in ${0} or using the -k flag"
  exit 2
fi
if [ "$CFRECORD_NAME" = "" ]; then
  echo "Missing hostname, what host do you want to update?"
  echo "save in ${0} or using the -h flag"
  exit 2
fi
if [ "$CFZONE_NAME" = "" ]; then
  CFZONE_NAME=$(echo "$CFRECORD_NAME" | awk -F. 'NF>=2 {print $(NF-1)"."$NF}')
  echo " => Missing zone name (-z), assuming $CFZONE_NAME"
fi

# If the hostname is not a FQDN
to_fqdn() {
  if [ "$1" != "$CFZONE_NAME" ] && [ -n "${1##*."$CFZONE_NAME"}" ]; then
    echo " => Hostname $1 is not a FQDN, assuming $1.$CFZONE_NAME" >&2
    printf '%s' "$1.$CFZONE_NAME"
  else
    printf '%s' "$1"
  fi
}
CFRECORD_NAME=$(to_fqdn "$CFRECORD_NAME")
CFRECORD_NAME_V6=$(to_fqdn "${CFRECORD_NAME_V6:-$CFRECORD_NAME}")

# 缓存目录；非 root 写不了 /var/lib 时退回到 HOME
if ! mkdir -p "$STATE_DIR" 2>/dev/null || [ ! -w "$STATE_DIR" ]; then
  STATE_DIR="${HOME:-/tmp}/.cf-ddns"
  mkdir -p "$STATE_DIR" || exit 1
fi

# @reboot 和每分钟的任务可能同时跑，加锁避免重复新建记录
if command -v flock >/dev/null 2>&1; then
  exec 9>"$STATE_DIR/lock"
  flock -n 9 || exit 0
fi

# ---------- 取 IP ----------

is_ipv4() {
  printf '%s' "$1" | grep -Eq '^([0-9]{1,3}\.){3}[0-9]{1,3}$'
}

# 只认 2000::/3 公网单播，排除 fe80::/fc00:: 等
is_public_ipv6() {
  printf '%s' "$1" | grep -Eiq '^[23][0-9a-f]{3}:[0-9a-f:]+$'
}

# AWS 实例元数据，先试 IMDSv2，没有 token 再试 IMDSv1；非 AWS 机器 2 秒内超时
imds() {
  local token
  token=$(curl -sf --connect-timeout 2 --max-time 3 -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 60" 2>/dev/null) || token=""
  if [ -n "$token" ]; then
    curl -sf --connect-timeout 2 --max-time 3 -H "X-aws-ec2-metadata-token: $token" \
      "http://169.254.169.254/latest/meta-data/$1" 2>/dev/null
  else
    curl -sf --connect-timeout 2 --max-time 3 "http://169.254.169.254/latest/meta-data/$1" 2>/dev/null
  fi
}

get_ipv4() {
  local addr site
  addr=$(imds public-ipv4 | head -n1 | tr -d '[:space:]')
  if is_ipv4 "$addr"; then echo "$addr"; return 0; fi
  for site in https://api.ipify.org https://ipv4.icanhazip.com https://api-ipv4.ip.sb/ip; do
    addr=$(curl -4 -sf --max-time 6 "$site" 2>/dev/null | tr -d '[:space:]')
    if is_ipv4 "$addr"; then echo "$addr"; return 0; fi
  done
  return 1
}

get_ipv6() {
  local addr mac route site
  addr=$(imds ipv6 | head -n1 | tr -d '[:space:]')
  if is_public_ipv6 "$addr"; then echo "$addr"; return 0; fi
  mac=$(imds mac | head -n1 | tr -d '[:space:]')
  if [ -n "$mac" ]; then
    addr=$(imds "network/interfaces/macs/$mac/ipv6s" | head -n1 | tr -d '[:space:]')
    if is_public_ipv6 "$addr"; then echo "$addr"; return 0; fi
  fi
  # 默认 IPv6 路由走 WARP/WireGuard 等隧道时，源地址和外部网站看到的都不是本机地址，直接放弃
  if command -v ip >/dev/null 2>&1; then
    route=$(ip -6 route get 2606:4700:4700::1111 2>/dev/null | head -n1)
    case $route in
      *" dev wg"*|*" dev warp"*|*" dev tun"*|*" dev tap"*|*" dev CloudflareWARP"*)
        return 1 ;;
    esac
    addr=$(printf '%s' "$route" | sed -n 's/.* src \([0-9a-fA-F:]*\).*/\1/p')
    if is_public_ipv6 "$addr"; then echo "$addr"; return 0; fi
  fi
  for site in https://api6.ipify.org https://ipv6.icanhazip.com https://api-ipv6.ip.sb/ip; do
    addr=$(curl -6 -sf --max-time 6 "$site" 2>/dev/null | tr -d '[:space:]')
    if is_public_ipv6 "$addr"; then echo "$addr"; return 0; fi
  done
  return 1
}

# 开机时网络可能还没起来，按 -w 重试
get_ip_wait() {
  local deadline addr
  deadline=$(( $(date +%s) + WAIT ))
  while :; do
    if addr=$("get_ipv$1"); then echo "$addr"; return 0; fi
    [ "$(date +%s)" -ge "$deadline" ] && return 1
    sleep 5
  done
}

# ---------- Cloudflare API ----------

cf_api() {
  local method=$1 path=$2 data=${3:-}
  if [ -n "$CFUSER" ]; then
    set -- -H "X-Auth-Email: $CFUSER" -H "X-Auth-Key: $CFKEY"
  else
    set -- -H "Authorization: Bearer $CFKEY"
  fi
  if [ -n "$data" ]; then
    set -- "$@" --data "$data"
  fi
  curl -sS --max-time 15 --retry 2 -X "$method" "$CFAPI$path" -H "Content-Type: application/json" "$@"
}

api_ok() {
  printf '%s' "$1" | grep -Eq '"success":[[:space:]]*true'
}

# 取 JSON 里第一个 "key":"value" 的 value
json_first() {
  grep -Eo "\"$1\":[[:space:]]*\"[^\"]*\"" | head -n1 | cut -d'"' -f4
}

get_zone_id() {
  local cache="$STATE_DIR/zone_$CFZONE_NAME" resp id
  if [ -s "$cache" ]; then
    cat "$cache"
    return 0
  fi
  resp=$(cf_api GET "/zones?name=$CFZONE_NAME")
  id=$(printf '%s' "$resp" | json_first id)
  if ! api_ok "$resp" || [ -z "$id" ]; then
    log "获取 zone $CFZONE_NAME 的 id 失败: $resp" >&2
    return 1
  fi
  printf '%s' "$id" > "$cache"
  printf '%s' "$id"
}

# update_record A|AAAA 主机名 IP
update_record() {
  local type=$1 name=$2 addr=$3
  local cache="$STATE_DIR/ip_${type}_$name"
  local old="" zid resp rid cur count action

  [ -f "$cache" ] && old=$(cat "$cache")

  # IP 没变且缓存还新鲜，什么都不做
  if [ "$addr" = "$old" ] && [ "$FORCE" != true ] \
    && [ -n "$(find "$cache" -mmin -"$RECHECK_MINUTES" 2>/dev/null)" ]; then
    return 0
  fi

  zid=$(get_zone_id) || return 1
  resp=$(cf_api GET "/zones/$zid/dns_records?type=$type&name=$name")
  if ! api_ok "$resp"; then
    # zone id 缓存可能过期（比如域名删了重加），下次重新取
    rm -f "$STATE_DIR/zone_$CFZONE_NAME"
    log "$type $name 查询记录失败: $resp"
    return 1
  fi
  rid=$(printf '%s' "$resp" | json_first id)
  cur=$(printf '%s' "$resp" | json_first content)
  count=$(printf '%s' "$resp" | grep -Eo "\"type\":[[:space:]]*\"$type\"" | wc -l)
  if [ "$count" -gt 1 ]; then
    log "警告: $name 有 $count 条 $type 记录，只会更新第一条 ($cur)"
  fi

  if [ -n "$rid" ] && [ "$cur" = "$addr" ]; then
    [ "$addr" != "$old" ] && log "$type $name 在 Cloudflare 上已是 $addr"
    printf '%s' "$addr" > "$cache"
    return 0
  fi

  if [ -n "$rid" ]; then
    action="更新 $cur -> $addr"
    resp=$(cf_api PATCH "/zones/$zid/dns_records/$rid" "{\"content\":\"$addr\",\"ttl\":$CFTTL}")
  else
    action="新建 -> $addr"
    resp=$(cf_api POST "/zones/$zid/dns_records" \
      "{\"type\":\"$type\",\"name\":\"$name\",\"content\":\"$addr\",\"ttl\":$CFTTL,\"proxied\":false}")
  fi

  if api_ok "$resp"; then
    log "$type $name $action 成功"
    printf '%s' "$addr" > "$cache"
    return 0
  fi
  log "$type $name $action 失败: $resp"
  return 1
}

# ---------- main ----------

RC=0
GOT_ANY=false

if [ "$CFRECORD_TYPE" != AAAA ]; then
  if WAN_IP4=$(get_ip_wait 4); then
    GOT_ANY=true
    update_record A "$CFRECORD_NAME" "$WAN_IP4" || RC=1
  elif [ "$CFRECORD_TYPE" = A ]; then
    log "获取公网 IPv4 失败"
    RC=1
  fi
fi

if [ "$CFRECORD_TYPE" != A ]; then
  if WAN_IP6=$(get_ip_wait 6); then
    GOT_ANY=true
    update_record AAAA "$CFRECORD_NAME_V6" "$WAN_IP6" || RC=1
  elif [ "$CFRECORD_TYPE" = AAAA ]; then
    log "获取公网 IPv6 失败"
    RC=1
  fi
fi

# both 模式下只有一种地址是正常的（没开 IPv6 / 纯 IPv6 实例），两种都取不到才算失败
if [ "$CFRECORD_TYPE" = both ] && [ "$GOT_ANY" = false ]; then
  log "IPv4 和 IPv6 都没取到，检查网络"
  RC=1
fi

exit $RC
