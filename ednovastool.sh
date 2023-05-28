#!/bin/bash
ver="1.2.10"
changeLog="添加了回程检测脚本，优化了部分脚本，修复了一些bug"
arch=`uname -m`
virt=`systemd-detect-virt`
kernelVer=`uname -r`
hostnameVariable=`hostname`

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
    rm -f ednovastool.sh
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



function Get_Ip_Address(){
	getIpAddress=$(curl ip.p3terx.com)
}





# ==============part1=============

function ddonekey(){
	green "重装的系统说明："
	read -r -p "我已保存好默认root密码，并了解重装后VPS所有内容将会被清除[Y/n] " input
 
	case $input in
	    [yY][eE][sS]|[yY])
	        wget --no-check-certificate -O AutoReinstall.sh https://git.io/betags && chmod a+x AutoReinstall.sh && bash AutoReinstall.sh
	        ;;
	 
	    [nN][oO]|[nN])
	        vpsBasic
	           ;;
	 
	    *)
	        echo "Invalid input..."
	        vpsBasic
	        ;;
	esac
}

function closeipv6(){
    sed -i "\$anet.ipv6.conf.all.disable_ipv6=1" /etc/sysctl.conf
    sed -i "\$anet.ipv6.conf.default.disable_ipv6=1" /etc/sysctl.conf
    sysctl -p && sysctl --system
}

function openipv6(){
    sudo sed -i 's/net.ipv6.conf.all.disable_ipv6=1/#net.ipv6.conf.all.disable_ipv6=1/g' /etc/sysctl.conf
    sudo sed -i 's/net.ipv6.conf.default.disable_ipv6=1/#net.ipv6.conf.default.disable_ipv6=1/g' /etc/sysctl.conf
    sysctl -p && sysctl --system
}

function addipv6(){
	read -p "请输入你要添加的IPV6地址(IPV6 Address），带/64或/128：" IPV6ADDRESS
	read -p "请输入你要添加的IPV6地址的网关(Gateway）：" IPV6GATEWAY
	apt install net-tools -y
	ifconfig
	read -p "请输入你要添加的网卡名（例如“ens3”）：" NETWORKNAME
	ip addr add $IPV6ADDRESS dev $NETWORKNAME
	ip -6 route add $IPV6GATEWAY dev $NETWORKNAME
	ip -6 route add default via $IPV6GATEWAY dev $NETWORKNAME
	curl -6 ip.p3terx.com
}

function changesshport(){
    green "请输入你要更改为的ssh端口(1024-65535)"
    read -p "请输入你要更改为的ssh端口(1024-65535):" changedsshport
    if [$changedsshport < 1024 ||]
    then
        read -p "输入不合法，请重新输入你要更改的ssh端口(1024-65535)：" changedsshport
    fi

    if [ -e "/etc/ssh/sshd_config" ];then
    [ -z "`grep ^Port /etc/ssh/sshd_config`" ] && ssh_port=22 || ssh_port=`grep ^Port /etc/ssh/sshd_config | awk '{print $2}'`
    while :; do echo
        read -p "请输入你要更改为的端口，端口范围为1025-65534(默认: $ssh_port): " SSH_PORT
        [ -z "$SSH_PORT" ] && SSH_PORT=$ssh_port
        if [ $SSH_PORT -eq 22 >/dev/null 2>&1 -o $SSH_PORT -gt 1024 >/dev/null 2>&1 -a $SSH_PORT -lt 65535 >/dev/null 2>&1 ];then
            break
        else
            echo "${CWARNING}不合法的输入！端口范围: 22,1025~65534${CEND}"
        fi
    done
 
    if [ -z "`grep ^Port /etc/ssh/sshd_config`" -a "$SSH_PORT" != '22' ];then
        sed -i "s@^#Port.*@&\nPort $SSH_PORT@" /etc/ssh/sshd_config
    elif [ -n "`grep ^Port /etc/ssh/sshd_config`" ];then
        sed -i "s@^Port.*@Port $SSH_PORT@" /etc/ssh/sshd_config
    fi
fi
}

function rootLogin(){
    wget -N https://raw.githubusercontent.com/wdm1732418365/vpstoolbox/main/root.sh && chmod -R 755 root.sh && bash root.sh
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
        apt-get purge netfilter-persistent -y
    fi
}



function centosfirewall(){
    systemctl stop firewalld
    systemctl disable firewalld
}

function ubuntufirewall(){
    ufw disable
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -F
}

function changehostname(){
    read -p "您的新主机名(Your new hostname):" newhostname
    hostnamectl set-hostname $newhostname
    green "修改完成，请重新连接ssh或重新启动服务器!"
    green "Finished! Please reconnect to ssh or reboot your vps"
}

function ipdetestonekey(){
	yellow "'curl: (7) Couldn't connect to server' 即表示无IPV4/IPV6地址"
	green "IPV4地址为："
	curl -4 ip.p3terx.com
	green "IPV6地址为："
	curl -6 ip.p3terx.com
}

function driveSpace(){
    df -h
}

function memorySpace(){
    free -m
}

function realTimeProgress(){
    green "ctrl + c 退出"
    sleep 2
    top
}

function synctime(){
	if [ $release = "Centos" ]; then
		yum -y install ntpdate
		ntpdate -u  pool.ntp.org
		date
	    else
		apt -y install ntpdate
		ntpdate -u  pool.ntp.org
		date
	    fi
}

function changednscn(){
	echo -e "options timeout:1 attempts:1 rotate\nnameserver 223.5.5.5\nnameserver 119.29.29.29">/etc/resolv.conf;
	cat /etc/resolv.conf
}

function changednsgoogle(){
	echo -e "options timeout:1 attempts:1 rotate\nnameserver 8.8.8.8\nnameserver 8.8.4.4" >/etc/resolv.conf;
	cat /etc/resolv.conf
}

function changednscombine(){
	echo -e "options timeout:1 attempts:1 rotate\nnameserver 223.5.5.5\nnameserver 8.8.4.4" >/etc/resolv.conf;
	cat /etc/resolv.conf
}

function changedns(){
	echo "1. Google DNS"
	echo "2. CloudFlare DNS"
	echo "3. 国内阿里&腾讯 DNS"
	echo "4. 国内阿里&国外腾讯 DNS"
	echo "0. 反回上一级"
	echo "                        "
    	read -p "请输入选项:" dnschanges
	case "$dnschanges" in
		1 ) changednsgoogle ;;
		2 ) changednscf ;;
		3 ) changednscn ;;
		4 ) changednscombine ;;
		0 ) vpsBasic ;;
	esac
}

function addswap(){
	wget https://raw.githubusercontent.com/wdm1732418365/vpstoolbox/main/swap.sh && bash swap.sh
}

function nopingin(){
	iptables -A INPUT -p icmp --icmp-type 8 -s 0/0 -j DROP
}

function yespingin(){
	iptables -D INPUT -p icmp --icmp-type 8 -s 0/0 -j DROP
}

function nopinginout(){
	echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all
}

function yespinginout(){
	echo 0 > /proc/sys/net/ipv4/icmp_echo_ignore_all
}

function noping(){
	echo "1. 禁ping入"
	echo "2. 恢复ping入"
	echo "3. 禁ping入和出"
	echo "4. 恢复ping入和出"
	echo "0. 反回上一级"
	echo "                        "
    	read -p "请输入选项:" nopingswitch
	case "$nopingswitch" in
		1 ) changednsgoogle ;;
		2 ) changednscf ;;
		3 ) changednscn ;;
		4 ) changednscombine ;;
		0 ) vpsBasic ;;
	esac
}

function cloudflareddns(){
	curl https://raw.githubusercontent.com/EdNovas/vpstoolbox/main/cf-v4-ddns.sh > /root/cf-v4-ddns.sh && chmod +x /root/cf-v4-ddns.sh
	read -p "请输入你的Cloudflare邮箱地址: " cloudflareemail
	read -p "请输入你的Cloudflare API: " cloudflareapi
	read -p "请输入你的主域名（example.com）：" cloudflaredomain
	read -p "请输入你的Hostname（homeserver.example.com）：" cloudflarehostname
	sed -i "s/CFUSER=$/CFUSER=$cloudflareemail/g" /root/cf-v4-ddns.sh
	sed -i "s/CFKEY=$/CFKEY=$cloudflareapi/g" /root/cf-v4-ddns.sh
	sed -i "s/CFZONE_NAME=$/CFZONE_NAME=$cloudflaredomain/g" /root/cf-v4-ddns.sh
	sed -i "s/CFRECORD_NAME=$/CFRECORD_NAME=$cloudflarehostname/g" /root/cf-v4-ddns.sh
	if [ $release = "Centos" ]; then
		echo "*/2 * * * * /root/cf-v4-ddns.sh >/dev/null 2>&1" >> /etc/crontab
	    else
		echo "*/2 * * * * /root/cf-v4-ddns.sh >/dev/null 2>&1" >> /var/spool/cron/crontabs/root
	    fi
	./cf-v4-ddns.sh
}

function ipv4first(){
	sed -i 's/#precedence ::ffff:0:0\/96  100/precedence ::ffff:0:0\/96  100/' /etc/gai.conf
	curl ip.sb
}

function ipv6first(){
	sed -i 's/precedence ::ffff:0:0\/96  100/#precedence ::ffff:0:0\/96  100/' /etc/gai.conf
	echo "label 2002::/16   2" >> /etc/gai.conf
	curl ip.sb
}

function changenat64(){
	echo -e "nameserver 2a01:4f8:c2c:123f::1\nnameserver 2a00:1098:2c::1\nnameserver 2a01:4f9:c010:3f02::1" > /etc/resolv.conf
	green "DNS已更改为 2a01:4f9:c010:3f02::1"
	green "2a00:1098:2c::1"
	green "2a01:4f8:c2c:123f::1"
}

function changetrex(){
	echo -e "nameserver 2001:67c:2b0::4\nnameserver 2001:67c:2b0::6" > /etc/resolv.conf
	green "DNS已更改为 2001:67c:2b0::4"
	green "2001:67c:2b0::6"
}

function changego6lab(){
	echo -e "nameserver 2001:67c:27e4:15::6411\nnameserver 2001:67c:27e4::64" > /etc/resolv.conf
	green "DNS已更改为 2001:67c:27e4:15::6411"
	green "2001:67c:27e4::64"
}

function addDNS64(){
	echo "1. 使用 https://nat64.net/ DNS64"
	echo "2. 使用 http://www.trex.fi/2011/dns64.html DNS64"
	echo "3. 使用 https://go6lab.si/current-ipv6-tests/nat64dns64-public-test/ DNS64"
	echo "0. 反回上一级"
	echo "                        "
    	read -p "请输入选项:" dns64switch
	case "$dns64switch" in
		1 ) changenat64 ;;
		2 ) changetrex ;;
		3 ) changego6lab ;;
		0 ) vpsBasic ;;
	esac
}

# ==============part1=============





# ==============part2=============

function speedtest-clionekey(){
	if [ $release = "Centos" ]; then
        	curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.rpm.sh | sudo bash
		sudo yum install speedtest -y
		speedtest
   	 else
        	curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
		sudo apt-get install speedtest -y
		speedtest
    	fi
}

function benchonekey(){
    wget -qO- bench.sh | bash
}

function superbench(){
    wget -qO- --no-check-certificate https://raw.githubusercontent.com/oooldking/script/master/superbench.sh | bash
}

function superspeed(){
    bash <(curl -Lso- https://git.io/superspeed)
}

function lemonbench(){
    curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s fast
}

function speedtest-go(){
	bash <(curl -Lsk https://raw.githubusercontent.com/BigMangos/speedtest-go-script/master/install.sh)
}

function routetrace(){
	wget -qO- git.io/besttrace | bash
}

function routetracesimple(){
	curl https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh -sSf | sh
}

function yabs(){
	curl -sL yabs.sh | bash
}

# ==============part2=============





# ==============part3=============
function macka(){
    wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/ednovas/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
}


function xui(){
    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
}

function ssronekey(){
    bash <(curl -sL https://storage.googleapis.com/tiziblog/ssr.sh)
}


function xrayronekey(){
    bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)
    cd /etc/XrayR
}


function rulelist(){
    cd /etc/XrayR
    wget https://raw.githubusercontent.com/wdm1732418365/rulelist/main/rulelist
    sudo sed -i 's/RuleListPath:/RuleListPath: \/etc\/XrayR\/rulelist/g' /etc/XrayR/config.yml
    xrayr restart
}

function mtproxyonekey(){
    mkdir /home/mtproxy && cd /home/mtproxy
    curl -s -o mtproxy.sh https://raw.githubusercontent.com/ellermister/mtproxy/master/mtproxy.sh && chmod +x mtproxy.sh && bash mtproxy.sh
}

function sursharkinstall(){
	sudo wget https://ocean.surfshark.com/debian/pool/main/s/surfshark-release/surfshark-release_1.0.0-2_amd64.deb
	sudo dpkg -i surfshark-release_1.0.0-2_amd64.deb
	sudo apt-get update -y
	sudo apt-get install surfshark-vpn -y
	sudo surfshark-vpn
}

function expressinstall(){
	sudo wget https://www.expressvpn.works/clients/linux/expressvpn_3.48.0.4-1_amd64.deb
	sudo dpkg -i expressvpn_3.39.0.8-1_amd64.deb
	sudo expressvpn activate
}

function tcponekey(){
    wget https://raw.githubusercontent.com/wdm1732418365/bbr-tcp-boost/main/tools.sh -O tools.sh && bash tools.sh
}

function bbronekey(){
    wget -N --no-check-certificate "https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
}


function ovzbbr(){
    wget --no-cache -O lkl-haproxy.sh https://github.com/mzz2017/lkl-haproxy/raw/master/lkl-haproxy.sh && bash lkl-haproxy.sh
}

function wireguardonekey(){
	sudo apt install iproute2 openresolv -y
	sudo apt install wireguard-tools --no-install-recommends
	sudo apt install iptables -y
	cd /etc/wireguard
}

function l2tponekey(){
	wget --no-check-certificate https://raw.githubusercontent.com/teddysun/across/master/l2tp.sh
	chmod +x l2tp.sh
	./l2tp.sh
}

function sogaonekey(){
	bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)
	cd /etc/soga
}

# ==============part3=============






# ==============part4=============

function region(){
    bash <(curl -L -s https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/check.sh)
}

function netflixdetect(){
    if [ $arch = "aarch64" ]; then
        wget -O nf https://github.com/sjlleo/netflix-verify/releases/download/2.61/nf_2.61_linux_arm64 && chmod +x nf && clear && ./nf
    else
        wget -O nf https://github.com/sjlleo/netflix-verify/releases/download/2.61/nf_2.61_linux_amd64 && chmod +x nf && clear && ./nf
    fi
}

function warponekey(){
    wget -N https://raw.githubusercontent.com/fscarmen/warp/main/menu.sh && bash menu.sh [option] [lisence/url/token]
}

function p3trexwarp(){
    bash <(curl -fsSL git.io/warp.sh) install
}

function acacia233(){
    curl -sL https://raw.githubusercontent.com/acacia233/Project-WARP-Unlock/main/run.sh | bash
}


function georgexie2333(){
    wget https://github.com/GeorgeXie2333/Project-WARP-Unlock/raw/main/warp_change_ip.sh && chmod +x warp_change_ip.sh && ./warp_change_ip.sh
}

function georgexie2333onekey(){
    if [ $arch = "aarch64" ]; then
        curl -sL https://raw.githubusercontent.com/GeorgeXie2333/Project-WARP-Unlock/main/run_arm.sh | bash
    else
        curl -sL https://raw.githubusercontent.com/GeorgeXie2333/Project-WARP-Unlock/main/run.sh | bash
    fi
}

function tiktokcheck(){
	bash <(curl -s https://raw.githubusercontent.com/lmc999/TikTokCheck/main/tiktok.sh)
}
# ==============part4=============






# ==============part5=============
function brookonekey(){
    wget  -N --no-check-certificate http://xiaojier.mooncloud.top/backup/brook-pf-mod.sh && bash brook-pf-mod.sh
}

function socatonekey(){
    wget https://www.moerats.com/usr/shell/socat.sh && bash socat.sh
}

function iptablesonekey(){
    wget -N --no-check-certificate https://www.vrrmr.net/Code/iptables-pf.sh && chmod +x iptables-pf.sh && bash iptables-pf.sh
}

function gostonekey(){
    wget --no-check-certificate -O gost.sh http://xiaojier.mooncloud.top/backup/gost.sh && chmod +x gost.sh && ./gost.sh
}
# ==============part5=============







# ==============part6=============
function aria2onekey(){
    if [ $release = "Centos" ]; then
        yum install wget curl ca-certificates && wget -N git.io/aria2.sh && chmod +x aria2.sh && ./aria2.sh
    else
        apt install wget curl ca-certificates && wget -N git.io/aria2.sh && chmod +x aria2.sh && ./aria2.sh
    fi
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

function dockeronekey(){
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
}

function rcloneonekey(){
    curl https://rclone.org/install.sh | sudo bash
}

function acmeonekey(){
    wget -N https://cdn.jsdelivr.net/gh/Misaka-blog/acme1key@master/acme1key.sh && chmod -R 777 acme1key.sh && bash acme1key.sh
}

function screenonekey(){
    wget -N https://cdn.jsdelivr.net/gh/Misaka-blog/screenManager@master/screen.sh && chmod -R 777 screen.sh && bash screen.sh
}
# ==============part6=============







# ==============part7=============
function teamspeakonekey(){
    if [ $release = "Centos" ]; then
        yum install vim wget perl tar net-tools bzip2 -y
    else
        apt install vim wget perl tar net-tools bzip2 -y
    fi
    cd /home
    wget https://files.teamspeak-services.com/releases/server/3.13.6/teamspeak3-server_linux_amd64-3.13.6.tar.bz2
    tar -xjvf teamspeak3-server_linux_amd64-3.13.6.tar.bz2
    mkdir teamspeak
    mv  teamspeak3-server_linux_amd64/* teamspeak
    rm -rf teamspeak3-server_linux_amd64
    cd teamspeak
    touch .ts3server_license_accepted
    ./ts3server_startscript.sh start
}

function cxxmatrix(){
    if [ $release = "Centos" ]; then
        sudo yum install make
        sudo yum install g++ -y
    else
        sudo apt install make
        sudo apt install g++ -y
    fi
    cd /home
    git clone https://github.com/akinomyoga/cxxmatrix.git
    cd cxxmatrix
    make
    ./cxxmatrix 'The Matrix' 'Reloaded'
}

function epicgamesonekey(){
    if [ $release = "Centos" ]; then
        yum install python3-pip -y
    else
        apt install python3-pip -y
    fi
    cd /home
    git clone -b main https://github.com/EdNovas/epicgames.git
    cd epicgames-claimer
    pip3 install -r requirements.txt
    sudo sh install_dependencies.sh
    python3 main.py
}

function qinglongonekey(){
	curl -fsSL https://get.docker.com/ | sh
	sudo systemctl start docker
    sudo systemctl enable docker
    docker run -dit --name QL --hostname QL --restart always -p 5700:5700 -v $PWD/QL/config:/ql/config -v $PWD/QL/log:/ql/log -v $PWD/QL/db:/ql/db -v $PWD/QL/scripts:/ql/scripts -v $PWD/QL/jbot:/ql/jbot whyour/qinglong:latest
    echo "安装成功，访问 https://${getIpAddress}:5700 即可登录青龙面板，记得开放5700端口！"
    echo "用户名为 admin 密码是 adminadmin"
}
# ==============part7=============





# ==============part8=============

function reallyNothing(){
    echo "都说了真的没东西啦！"
}

# ==============part8=============




# ==============part9=============
function updateScript(){
    wget -N https://raw.githubusercontent.com/ednovas/vpstoolbox/main/ednovastool.sh && chmod +x ednovastool.sh && ./ednovastool.sh
}
# ==============part9=============



function aliasInstall() {

	if [[ -f "$HOME/ednovastool.sh" ]] && [[ -d "/etc/ednovastool" ]] && grep <"$HOME/ednovastool.sh" -q "作者:EdNovas"; then
		mv "$HOME/ednovastool.sh" /etc/ednovastool/ednovastool.sh
		local installedN=
		if [[ -d "/usr/bin/" ]]; then
			if [[ ! -f "/usr/bin/ednovas" ]]; then
				ln -s /etc/ednovastool/ednovastool.sh /usr/bin/ednovas
				chmod 700 /usr/bin/ednovas
				installedN=true
			fi

			rm -rf "$HOME/ednovastool.sh"
		elif [[ -d "/usr/sbin" ]]; then
			if [[ ! -f "/usr/sbin/ednovas" ]]; then
				ln -s /etc/ednovastool/ednovastool.sh /usr/sbin/ednovas
				chmod 700 /usr/sbin/ednovas
				installedN=true
			fi
			rm -rf "$HOME/ednovastool.sh"
		fi
		if [[ "${installedN}" == "true" ]]; then
			echoContent green "快捷方式创建成功，可执行[ednovas]重新打开脚本"
		fi
	fi
}






# part 1
function vpsBasic() {
    clear
    green "============================="
    echo "                             "
    green "            EdNovas          "
    green "      https://ednovas.xyz    "
    echo "                             "
    green "============================="
    echo "                        "
    yellow "当前版本(Version): $ver"
    yellow "更新(Updates): $changeLog"
    echo "                        "
    yellow "======检测到VPS信息如下======"
    green "ip地址：$getIpAddress"
	green "主机名：$hostnameVariable"
    green "处理器架构：$arch"
    green "虚拟化架构：$virt"
    green "操作系统：$release"
    green "内核版本：$kernelVer"
    echo "                        "
    echo "1. 修改登录为 root 密码登录"
    echo "2. VPS系统更新"
    echo "3. 甲骨文关闭防火墙"
    echo "4. Centos关闭防火墙"
    echo "5. Ubuntu/Debian关闭防火墙"
    echo "6. 关闭IPV6"
    echo "7. 打开IPV6"
    echo "8. 修改主机名"
    echo "9. 修改SSH连接端口"
    echo "10. 显示本机IP"
    echo "11. 显示实时进程"
    echo "12. 显示内存使用情况"
    echo "13. 显示磁盘占用"
    echo "14. 一键DD脚本"
	echo "15. 同步系统时间"
	echo "16. 修改系统DNS"
	echo "17. 一键添加SWAP"
	echo "18. Cloudflare DDNS解析"
	echo "19. IPV4优先"
	echo "20. IPV6优先"
	echo "21. 添加IPV6地址和网关"
	echo "22. 添加 DNS64 DNS解析"
    echo "0. 返回上一级"
    echo "                        "
    read -p "请输入选项:" partOneInput
    case "$partOneInput" in
        1 ) rootLogin ;;
        2 ) vpsupdate ;;
        3 ) oraclefirewall ;;
        4 ) centosfirewall ;;
		5 ) ubuntufirewall ;;
        6 ) closeipv6 ;;
        7 ) openipv6 ;;
        8 ) changehostname ;;
        9 ) changesshport ;;
        10 ) ipdetestonekey ;;
        11 ) realTimeProgress ;;
        12 ) memorySpace ;;
        13 ) driveSpace ;;
        14 ) ddonekey ;;
		15 ) synctime ;;
		16 ) changedns ;;
		17 ) addswap ;;
		18 ) cloudflareddns ;;
		19 ) ipv4first ;;
		20 ) ipv6first ;;
		21 ) addipv6 ;;
		22 ) addDNS64 ;;
        0 ) start_menu ;;
    esac
}



# part 2
function vpsPerformance(){
    clear
    green "============================="
    echo "                             "
    green "            EdNovas          "
    green "      https://ednovas.xyz    "
    echo "                             "
    green "============================="
    echo "                        "
    yellow "当前版本(Version): $ver"
    yellow "更新(Updates): $changeLog"
    echo "                        "
    yellow "======检测到VPS信息如下======"
    green "ip地址：$getIpAddress"
	green "主机名：$hostnameVariable"
    green "处理器架构：$arch"
    green "虚拟化架构：$virt"
    green "操作系统：$release"
    green "内核版本：$kernelVer"
    echo "                        "
    echo "1. Bench VPS检测脚本"
    echo "2. SuperBench VPS检测脚本"
    echo "3. LemonBench VPS检测脚本"
    echo "4. yabs VPS检测脚本"
	echo "5. Speedtest-cli一键测速"
	echo "6. Speedtest-go网页测速搭建脚本"
	echo "7. 回程一键检测脚本"
	echo "8. 回程一键检测脚本简易版"
    echo "0. 返回上一级"
    echo "                        "
    read -p "请输入选项:" partTwoInput
    case "$partTwoInput" in
        1 ) benchonekey ;;
        2 ) superbench ;;
        3 ) lemonbench ;;
	4 ) yabs ;;
		5 ) speedtest-clionekey ;;
		6 ) speedtest-go ;;
		7 ) routetrace ;;
		8 ) routetracesimple ;;
        0 ) start_menu ;;
    esac
}


# part 3
function proxyRelated(){
    clear
    green "============================="
    echo "                             "
    green "            EdNovas          "
    green "      https://ednovas.xyz    "
    echo "                             "
    green "============================="
    echo "                        "
    yellow "当前版本(Version): $ver"
    yellow "更新(Updates): $changeLog"
    echo "                        "
    yellow "======检测到VPS信息如下======"
    green "ip地址：$getIpAddress"
	green "主机名：$hostnameVariable"
    green "处理器架构：$arch"
    green "虚拟化架构：$virt"
    green "操作系统：$release"
    green "内核版本：$kernelVer"
    echo "                        "
    echo "1. Mack-a v2rayagent八合一脚本"
    echo "2. x-ui面板"
    echo "3. ssr一键脚本"
    echo "4. Xrayr 后端安装"
    echo "5. Soga一键安装"
    echo "6. Xrayr添加本地审计规则"
    echo "7. Mtproxy+伪tls一键脚本"
    echo "8. Surshark VPN一键安装脚本"
    echo "9. Express VPN一键安装脚本"
    echo "10. Wireguard一键安装脚本"
    echo "11. L2TP一键安装脚本"
    echo "                        "
    echo "12. TCP调优脚本"
    echo "13. 六合一BBR脚本"
    echo "14. OVZ开启BBR"
    echo "0. 返回上一级"
    echo "                        "
    read -p "请输入选项:" partThreeInput
    case "$partThreeInput" in
        1 ) macka ;;
        2 ) xui ;;
        3 ) ssronekey ;;
        4 ) xrayronekey ;;
	5 ) sogaonekey ;;
        6 ) rulelist ;;
        7 ) mtproxyonekey ;;
	8 ) sursharkinstall ;;
	9 ) expressinstall ;;
	10 ) wireguardonekey ;;
	11 ) l2tponekey ;;
        12 ) tcponekey ;;
        13 ) bbronekey ;;
        14 ) ovzbbr ;;
        0 ) start_menu ;;
    esac
}



# part 4
function mediaDetectionUnlock(){
    clear
    green "============================="
    echo "                             "
    green "            EdNovas          "
    green "      https://ednovas.xyz    "
    echo "                             "
    green "============================="
    echo "                        "
    yellow "当前版本(Version): $ver"
    yellow "更新(Updates): $changeLog"
    echo "                        "
    yellow "======检测到VPS信息如下======"
    green "ip地址：$getIpAddress"
	green "主机名：$hostnameVariable"
    green "处理器架构：$arch"
    green "虚拟化架构：$virt"
    green "操作系统：$release"
    green "内核版本：$kernelVer"
    echo "                        "
    echo "1. 流媒体检测脚本"
    echo "2. 奈飞检测脚本"
    echo "                  "
    echo "3. fscarmen warp一键脚本"
    echo "4. p3trex warp一键脚本"
    echo "5. acacia233 warp解锁奈飞脚本"
    echo "6. GeorgeXie2333 warp解锁奈飞脚本"
    echo "7. GeorgeXie2333 warp刷IP脚本"
    echo "8. Tiktok区域检测脚本"
    echo "0. 返回上一级"
    echo "                        "
    read -p "请输入选项:" partFourInput
    case "$partFourInput" in
        1 ) region ;;
        2 ) netflixdetect ;;
        3 ) warponekey ;;
        4 ) p3trexwarp ;;
        5 ) acacia233 ;;
        6 ) georgexie2333onekey ;;
        7 ) georgexie2333 ;;
	8 ) tiktokcheck ;;
        0 ) start_menu ;;
    esac
}



# part 5
function forwardonekey(){
    clear
    green "============================="
    echo "                             "
    green "            EdNovas          "
    green "      https://ednovas.xyz    "
    echo "                             "
    green "============================="
    echo "                        "
    yellow "当前版本(Version): $ver"
    yellow "更新(Updates): $changeLog"
    echo "                        "
    yellow "======检测到VPS信息如下======"
    green "ip地址：$getIpAddress"
	green "主机名：$hostnameVariable"
    green "处理器架构：$arch"
    green "虚拟化架构：$virt"
    green "操作系统：$release"
    green "内核版本：$kernelVer"
    echo "                        "
    echo "1. Iptables转发脚本"
    echo "2. Socat转发脚本"
    echo "3. Gost加密脚本"
    echo "4. Brook转发脚本"
    echo "0. 返回上一级"
    echo "                        "
    read -p "请输入选项:" partFiveInput
    case "$partFiveInput" in
        1 ) iptablesonekey ;;
        2 ) socatonekey ;;
        3 ) gostoneky ;;
        4 ) brookonekey ;;
        0 ) start_menu ;;
    esac
}

# part 6
function usefulTools(){
    clear
    green "============================="
    echo "                             "
    green "            EdNovas          "
    green "      https://ednovas.xyz    "
    echo "                             "
    green "============================="
    echo "                        "
    yellow "当前版本(Version): $ver"
    yellow "更新(Updates): $changeLog"
    echo "                        "
    yellow "======检测到VPS信息如下======"
    green "ip地址：$getIpAddress"
	green "主机名：$hostnameVariable"
    green "处理器架构：$arch"
    green "虚拟化架构：$virt"
    green "操作系统：$release"
    green "内核版本：$kernelVer"
    echo "                        "
    echo "1. aapanel国际版宝塔安装"
    echo "2. Docker一键脚本"
    echo "3. Rclone官方一键脚本"
    echo "4. Aria2一键脚本"
    echo "5. Acme.sh一键申请证书"
    echo "6. Screen后台运行管理脚本"
    echo "7. 哪吒探针"
    echo "0. 返回上一级"
    echo "                        "
    read -p "请输入选项:" partSixInput
    case "$partSixInput" in
        1 ) aapanel ;;
        2 ) dockeronekey ;;
        3 ) rcloneonekey ;;
        4 ) aria2onekey ;;
        5 ) acmeonekey ;;
        6 ) screenonekey ;;
        7 ) nezha ;;
        0 ) start_menu ;;
    esac
}

# part 7
function interestingTools(){
    clear
    green "============================="
    echo "                             "
    green "            EdNovas          "
    green "      https://ednovas.xyz    "
    echo "                             "
    green "============================="
    echo "                        "
    yellow "当前版本(Version): $ver"
    yellow "更新(Updates): $changeLog"
    echo "                        "
    yellow "======检测到VPS信息如下======"
    green "ip地址：$getIpAddress"
	green "主机名：$hostnameVariable"
    green "处理器架构：$arch"
    green "虚拟化架构：$virt"
    green "操作系统：$release"
    green "内核版本：$kernelVer"
    echo "                        "
    echo "1. cxxmatrix黑客帝国屏保"
    echo "2. Teamspeak一键脚本v3.13.6"
    echo "3. Epic Games自动领取每周免费游戏脚本"
    echo "4. 青龙面板一键脚本"
    echo "0. 返回上一级"
    echo "                        "
    read -p "请输入选项:" partSevenInput
    case "$partSevenInput" in
        1 ) cxxmatrix ;;
        2 ) teamspeakonekey ;;
        3 ) epicgamesonekey ;;
        4 ) qinglongonekey ;;
        0 ) start_menu ;;
    esac
}




# part 8
function othersonekey(){
    clear
    green "============================="
    echo "                             "
    green "            EdNovas          "
    green "      https://ednovas.xyz    "
    echo "                             "
    green "============================="
    echo "                        "
    yellow "当前版本(Version): $ver"
    yellow "更新(Updates): $changeLog"
    echo "                        "
    yellow "======检测到VPS信息如下======"
    green "ip地址：$getIpAddress"
	green "主机名：$hostnameVariable"
    green "处理器架构：$arch"
    green "虚拟化架构：$virt"
    green "操作系统：$release"
    green "内核版本：$kernelVer"
    echo "                        "
    echo "1. 目前还没有哦，投稿可以联系 @ednovas"
    echo "0. 返回上一级"
    echo "                        "
    read -p "请输入选项:" partSevenInput
    case "$partSevenInput" in
        1 ) reallyNothing ;;
        0 ) start_menu ;;
        * ) start_menu ;;
    esac
}


#part 9
function updateScript(){
    wget -P /root -N https://cdn.jsdelivr.net/gh/ednovas/vpstoolbox@main/ednovastool.sh && chmod +x ednovastool.sh && ./ednovastool.sh
}



function start_menu(){
    clear
    green "============================="
    echo "                             "
    green "            EdNovas          "
    green "      https://ednovas.xyz    "
    echo "                             "
    green "============================="
    echo "                        "
    yellow "当前版本(Version): $ver"
    yellow "更新(Updates): $changeLog"
    echo "                        "
    yellow "======检测到VPS信息如下======"
    green "ip地址：$getIpAddress"
	green "主机名：$hostnameVariable"
    green "处理器架构：$arch"
    green "虚拟化架构：$virt"
    green "操作系统：$release"
    green "内核版本：$kernelVer"
    echo "                        "
    echo "1. VPS基本操作"
    echo "2. VPS性能检测"
    echo "3. 科学上网"
    echo "4. 流媒体检测和解锁"
    echo "5. 转发脚本"
    echo "6. 常用软件"
    echo "7. 有趣软件"
    echo "8. 其他"
    echo "9. 更新脚本"
    echo "0. 退出脚本"
    echo "                        "
    echo "快捷方式创建成功，可执行[ednovas]快捷重新打开脚本"
    read -p "请输入选项:" menuNumberInput
    case "$menuNumberInput" in
        1 ) vpsBasic ;;
        2 ) vpsPerformance ;;
        3 ) proxyRelated ;;
        4 ) mediaDetectionUnlock ;;
        5 ) forwardonekey ;;
        6 ) usefulTools ;;
        7 ) interestingTools ;;
        8 ) othersonekey ;;
        9 ) updateScript ;;
        0 ) exit 0 ;;
    esac
}

Get_Ip_Address
mkdir -p /etc/ednovastool
aliasInstall
start_menu
