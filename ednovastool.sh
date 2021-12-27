ver="1.0.0"
changeLog="创建该整合脚本"

green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}

if [[ -f /etc/redhat-release ]]; then
release="Centos"
elif cat /etc/issue | grep -q -E -i "debian"; then
release="Debian"
elif cat /etc/issue | grep -q -E -i "ubuntu"; then
release="Ubuntu"
elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
release="Centos"
elif cat /proc/version | grep -q -E -i "debian"; then
release="Debian"
elif cat /proc/version | grep -q -E -i "ubuntu"; then
release="Ubuntu"
elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
release="Centos"
else 
red "不支持你当前系统，请使用Ubuntu,Debian,Centos系统"
rm -f MisakaToolbox.sh
exit 1
fi

if ! type curl >/dev/null 2>&1; then 
yellow "检测到curl未安装，安装中 "
if [ $release = "Centos" ]; then
yum -y update && yum install curl -y
else
apt-get update -y && apt-get install curl -y
fi	   
else
green "curl已安装"
fi

if ! type wget >/dev/null 2>&1; then 
yellow "检测到wget未安装，安装中 "
if [ $release = "Centos" ]; then
yum -y update && yum install wget -y
else
apt-get update -y && apt-get install wget -y
fi	   
else
green "wget已安装"
fi

if ! type sudo >/dev/null 2>&1; then 
yellow "检测到sudo未安装，安装中 "
if [ $release = "Centos" ]; then
yum -y update && yum install sudo -y
else
apt-get update -y && apt-get install sudo -y
fi	   
else
green "sudo已安装"
fi


function rootLogin(){
    wget -N https://raw.githubusercontent.com/wdm1732418365/vpstoolbox/main/root.sh && chmod -R 755 root.sh && bash root.sh
}


function warp(){
    wget -N https://cdn.jsdelivr.net/gh/fscarmen/warp/menu.sh && bash menu.sh
}


function vpsupdate(){
    if [ $release = "Centos" ]; then
        yum update -y
        yum update -y && apt-get install curl -y
    else
        apt update -y
        apt-get update -y && apt-get install curl -y
    fi
}

function oraclefirewall(){
    if [ $release = "Centos" ]; then
        systemctl stop oracle-cloud-agent
        systemctl disable oracle-cloud-agent
        systemctl stop oracle-cloud-agent-updater
        systemctl disable oracle-cloud-agent-updater
        systemctl stop firewalld.service
        systemctl disable firewalld.service
    else
        iptables -P INPUT ACCEPT
        iptables -P FORWARD ACCEPT
        iptables -P OUTPUT ACCEPT
        iptables -F
        yellow "请输入y并回车(Press 'y' and enter)"
        apt-get purge netfilter-persistent
    fi
}

function centosfirewall(){
    systemctl stop firewalld
    systemctl disable firewalld
}

function xui(){
    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
}

function macka(){
    wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
}

function tcp(){
    wget https://raw.githubusercontent.com/wdm1732418365/bbr-tcp-boost/main/tools.sh -O tools.sh && bash tools.sh
}

function bbr(){
    wget -N --no-check-certificate "https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
}


function ovzbbr(){
    wget --no-cache -O lkl-haproxy.sh https://github.com/mzz2017/lkl-haproxy/raw/master/lkl-haproxy.sh && bash lkl-haproxy.sh
}

function bench(){
    wget -qO- bench.sh | bash
}

function superbench(){
    wget -qO- --no-check-certificate https://raw.githubusercontent.com/oooldking/script/master/superbench.sh | bash
}

function superspeed(){
    bash <(curl -Lso- https://git.io/superspeed)
}

function gost(){
    wget --no-check-certificate -O gost.sh http://xiaojier.mooncloud.top/backup/gost.sh && chmod +x gost.sh && ./gost.sh
}

function brook(){
    wget  -N --no-check-certificate http://xiaojier.mooncloud.top/backup/brook-pf-mod.sh && bash brook-pf-mod.sh
}

function socat(){
    wget https://www.moerats.com/usr/shell/socat.sh && bash socat.sh
}

function iptables(){
    wget -N --no-check-certificate https://www.vrrmr.net/Code/iptables-pf.sh && chmod +x iptables-pf.sh && bash iptables-pf.sh
}

function aapanel(){
    if [ $release = "Centos" ]; then
        yum install -y wget && wget -O install.sh http://www.aapanel.com/script/install_6.0_en.sh && bash install.sh forum
    elif [ $release = "Debian" ]; then
        wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh && bash install.sh forum
    else
        wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh && sudo bash install.sh forum
    fi
}

function nezha(){
    curl -L https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -o nezha.sh && chmod +x nezha.sh && sudo ./nezha.sh
}

function region(){
    bash <(curl -L -s https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/check.sh)
}

function netflixamd(){
    wget -O nf https://github.com/sjlleo/netflix-verify/releases/download/2.61/nf_2.61_linux_amd64 && chmod +x nf && clear && ./nf
}

function netflixarm(){
    wget -O nf https://github.com/sjlleo/netflix-verify/releases/download/2.61/nf_2.61_linux_arm64 && chmod +x nf && clear && ./nf
}

function docker(){
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
}

function lemonbench(){
    curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s fast
}

function xrayr(){
    bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)
}

function acacia233(){
    curl -sL https://raw.githubusercontent.com/acacia233/Project-WARP-Unlock/main/run.sh | bash
}

function changehostname(){
    read -p "您的新主机名(Your new hostname):" newhostname
    hostnamectl set-hostname $newhostname
    green "修改完成，请重新连接ssh或重新启动服务器!"
    green "Finished! Please reconnect to ssh or reboot your vps"
}

function aria2(){
    apt install wget curl ca-certificates && wget -N git.io/aria2.sh && chmod +x aria2.sh && ./aria2.sh
}

function fscarmen(){
    yellow "这是在'warp'的screen中，如需退出按ctrl+a+d，返回'screen -r warp'"
    screen -R warp && warp i
}

function georgexie2333(){
    wget https://github.com/GeorgeXie2333/Project-WARP-Unlock/raw/main/warp_change_ip.sh && chmod +x warp_change_ip.sh && ./warp_change_ip.sh
}

function georgexie2333amd(){
    curl -sL https://raw.githubusercontent.com/GeorgeXie2333/Project-WARP-Unlock/main/run.sh | bash
}

function georgexie2333arm(){
    curl -sL https://raw.githubusercontent.com/GeorgeXie2333/Project-WARP-Unlock/main/run_arm.sh | bash
}

function updateScript(){
    wget -N https://raw.githubusercontent.com/wdm1732418365/vpstoolbox/main/ednovastool.sh && chmod -R 755 ednovastool.sh && bash ednovastool.sh
}

function start_menu(){
    clear
    green "~~~~~~~~~~~~~~~~~~~~~~~~"
    green "                        "
    green "       From EdNovas     "
    green "   https://ednovas.xyz  "
    green "                        "
    green "~~~~~~~~~~~~~~~~~~~~~~~~"
    yellow "当前版本(Version): $ver"
    yellow "更新(Updates): $changeLog"
    echo "                        "
    echo "1. 修改登录为 root 密码登录"
    echo "2. VPS系统更新"
    echo "3. 甲骨文关闭防火墙"
    echo "4. Centos关闭防火墙"
    echo "5. 修改主机名"
    echo "                        "
    echo "6. Bench VPS检测脚本"
    echo "7. SuperBench VPS检测脚本"
    echo "8. LemonBench VPS检测脚本"
    echo "9. Superspeed 测速脚本"
    echo "                        "
    echo "10. Aria2一键脚本"
    echo "11. 哪吒探针"
    echo "                        "
    echo "12. x-ui面板"
    echo "13. Mack-a v2rayagent八合一脚本"
    echo "14. Xrayr 后端安装"
    echo "                        "
    echo "15. TCP调优脚本"
    echo "16. 六合一BBR脚本"
    echo "17. OVZ开启BBR"
    echo "                        "
    echo "18. 流媒体检测脚本"
    echo "19. AMD奈飞检测脚本"
    echo "20. ARM奈飞检测脚本"
    echo "                        "
    echo "21. fscarmen warp一键脚本"
    echo "22. acacia233 warp解锁奈飞脚本"
    echo "23. GeorgeXie2333 warp解锁奈飞脚本"
    echo "24. GeorgeXie2333 ARM warp解锁奈飞脚本"
    echo "25. GeorgeXie2333 warp刷IP脚本"
    echo "26. fscarmen warp刷IP脚本"
    echo "                        "
    echo "27. Iptables转发脚本"
    echo "28. Socat转发脚本"
    echo "29. Gost加密脚本"
    echo "30. Brook转发脚本"
    echo "                        "
    echo "31. Docker一键脚本"
    echo "32. aapanel 国际版宝塔安装"
    echo "                        "
    echo "v. 更新脚本"
    echo "0. 退出脚本"
    read -p "请输入选项:" menuNumberInput

    case "$menuNumberInput" in     
        1 ) rootLogin ;;
        2 ) vpsupdate ;;
        3 ) oraclefirewall ;;
        4 ) centosfirewall ;;
        5 ) changehostname ;;
        6 ) bench ;;
        7 ) superbench ;;
        8 ) lemonbench ;;
        9 ) superspeed ;;
        10 ) aria2 ;;
        11 ) nezha ;;
        12 ) xui ;; 
        13 ) macka ;;
        14 ) xrayr ;;
        15 ) tcp ;;
        16 ) bbr ;;
        17 ) ovzbbr ;;
        18 ) region ;;
        19 ) netflixamd ;;
        20 ) netflixarm ;;
        21 ) warp ;;
        22 ) acacia233 ;;
        23 ) georgexie2333amd ;;
        24 ) georgexie2333arm ;;
        25 ) georgexie2333 ;;
        26 ) fscarmen ;;
        27 ) iptables ;;
        28 ) socat ;;
        29 ) gost ;;
        30 ) brook ;;
        31 ) docker ;;
        32 ) aapanel ;;
        v ) updateScript ;;
        0 ) exit 0 ;;
    esac
    

}
start_menu
