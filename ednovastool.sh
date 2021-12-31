#!/bin/bash
ver="1.0.9"
changeLog="添加青龙面板一键脚本"

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


function rootLogin(){
    wget -N https://raw.githubusercontent.com/wdm1732418365/vpstoolbox/main/root.sh && chmod -R 755 root.sh && bash root.sh
}

function ipdetestonekey(){
	yellow "'curl: (7) Couldn't connect to server' 即表示无IPV4/IPV6地址"
	green "IPV4地址为："
	curl -4 ip.p3terx.com
	green "IPV6地址为："
	curl -6 ip.p3terx.com
}

function Get_Ip_Address(){
	getIpAddress=$(curl -sS --connect-timeout 10 -m 60 https://www.aapanel.com/api/common/getClientIP)
	echo "IP地址为 $getIpAddress"
}

function warponekey(){
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

function ssronekey(){
    bash <(curl -sL https://s.hijk.art/ssr.sh)
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

function xui(){
    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
}

function macka(){
    wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
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

function benchoneky(){
    wget -qO- bench.sh | bash
}

function superbench(){
    wget -qO- --no-check-certificate https://raw.githubusercontent.com/oooldking/script/master/superbench.sh | bash
}

function superspeed(){
    bash <(curl -Lso- https://git.io/superspeed)
}

function gostonekey(){
    wget --no-check-certificate -O gost.sh http://xiaojier.mooncloud.top/backup/gost.sh && chmod +x gost.sh && ./gost.sh
}

function teamspeakonekey(){
    cd /home
    wget https://files.teamspeak-services.com/releases/server/3.13.6/teamspeak3-server_linux_amd64-3.13.6.tar.bz2
    yum install vim wget perl tar net-tools bzip2 -y
    tar -xjvf teamspeak3-server_linux_amd64-3.13.6.tar.bz2
    mkdir teamspeak
    mv  teamspeak3-server_linux_amd64/* teamspeak
    rm -rf teamspeak3-server_linux_amd64
    cd teamspeak
    touch .ts3server_license_accepted
    ./ts3server_startscript.sh start
}

function brookonekey(){
    wget  -N --no-check-certificate http://xiaojier.mooncloud.top/backup/brook-pf-mod.sh && bash brook-pf-mod.sh
}

function socatonekey(){
    wget https://www.moerats.com/usr/shell/socat.sh && bash socat.sh
}

function iptablesonekey(){
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

function dockeronekey(){
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
}

function lemonbench(){
    curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s fast
}

function xrayronekey(){
    bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)
}

function acacia233(){
    curl -sL https://raw.githubusercontent.com/acacia233/Project-WARP-Unlock/main/run.sh | bash
}

function rulelist(){
    cd /etc/XrayR
    wget https://raw.githubusercontent.com/wdm1732418365/rulelist/main/rulelist
    sudo sed -i 's/RuleListPath:/RuleListPath: \/etc\/XrayR\/rulelist/g' /etc/XrayR/config.yml
    xrayr restart
}

function changehostname(){
    read -p "您的新主机名(Your new hostname):" newhostname
    hostnamectl set-hostname $newhostname
    green "修改完成，请重新连接ssh或重新启动服务器!"
    green "Finished! Please reconnect to ssh or reboot your vps"
}

function mtproxyonekey(){
    mkdir /home/mtproxy && cd /home/mtproxy
    curl -s -o mtproxy.sh https://raw.githubusercontent.com/ellermister/mtproxy/master/mtproxy.sh && chmod +x mtproxy.sh && bash mtproxy.sh
}

function aria2onekey(){
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

function cxxmatrix(){
    sudo apt install make
    sudo apt install g++ -y
    cd /home
    git clone https://github.com/akinomyoga/cxxmatrix.git
    cd cxxmatrix
    make
    ./cxxmatrix 'The Matrix' 'Reloaded'
}

function rcloneonekey(){
    curl https://rclone.org/install.sh | sudo bash
}

function epicgamesonekey(){
    apt install python3-pip -y
    cd /home
    git clone -b main https://github.com/luminoleon/epicgames-claimer.git
    cd epicgames-claimer
    pip3 install -r requirements.txt
    sudo sh install_dependencies.sh
    python3 main.py
}



function qinglongonekey(){
    sudo yum check-update
    curl -fsSL https://get.docker.com/ | sh
    sudo systemctl start docker
    sudo systemctl status docker
    sudo systemctl enable docker
    docker run -dit \
      --name QL \
      --hostname QL \
      --restart always \
      -p 5700:5700 \
      -v $PWD/QL/config:/ql/config \
      -v $PWD/QL/log:/ql/log \
      -v $PWD/QL/db:/ql/db \
      -v $PWD/QL/scripts:/ql/scripts \
      -v $PWD/QL/jbot:/ql/jbot \
      whyour/qinglong:latest
    echo "安装成功，访问 https://${getIpAddress}:5700 即可登录青龙面板，记得开放5700端口！"
    echo "用户名为 admin 密码是 adminadmin"
}

function updateScript(){
    wget -N https://raw.githubusercontent.com/wdm1732418365/vpstoolbox/main/ednovastool.sh && chmod +x ednovastool.sh && ./ednovastool.sh
}

function start_menu(){
    clear
    green "~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "                        "
    green "        EdNovas         "
    green "   https://ednovas.xyz  "
    echo "                        "
    green "~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "                        "
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
    echo "15. Mtproxy+伪tls一键脚本"
    echo "                        "
    echo "16. TCP调优脚本"
    echo "17. 六合一BBR脚本"
    echo "18. OVZ开启BBR"
    echo "                        "
    echo "19. 流媒体检测脚本"
    echo "20. AMD奈飞检测脚本"
    echo "21. ARM奈飞检测脚本"
    echo "                        "
    echo "22. fscarmen warp一键脚本"
    echo "23. acacia233 warp解锁奈飞脚本"
    echo "24. GeorgeXie2333 warp解锁奈飞脚本"
    echo "25. GeorgeXie2333 ARM warp解锁奈飞脚本"
    echo "26. GeorgeXie2333 warp刷IP脚本"
    echo "27. fscarmen warp刷IP脚本"
    echo "                        "
    echo "28. Iptables转发脚本"
    echo "29. Socat转发脚本"
    echo "30. Gost加密脚本"
    echo "31. Brook转发脚本"
    echo "                        "
    echo "32. Docker一键脚本"
    echo "33. aapanel 国际版宝塔安装"
    echo "34. cxxmatrix黑客帝国屏保"
    echo "35. Rclone官方一键脚本"
    echo "36. Xrayr添加本地审计规则"
    echo "37. Teamspeak一键脚本 3.13.6"
    echo "38. ssr一键脚本"
    echo "39. Epic Games自动领取每周免费游戏脚本"
	echo "40. 显示本机IP"
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
        6 ) benchonekey ;;
        7 ) superbench ;;
        8 ) lemonbench ;;
        9 ) superspeed ;;
        10 ) aria2onekey ;;
        11 ) nezha ;;
        12 ) xui ;; 
        13 ) macka ;;
        14 ) xrayronekey ;;
        15 ) mtproxyonekey ;;
        16 ) tcponekey ;;
        17 ) bbronekey ;;
        18 ) ovzbbr ;;
        19 ) region ;;
        20 ) netflixamd ;;
        21 ) netflixarm ;;
        22 ) warponekey ;;
        23 ) acacia233 ;;
        24 ) georgexie2333amd ;;
        25 ) georgexie2333arm ;;
        26 ) georgexie2333 ;;
        27 ) fscarmen ;;
        28 ) iptablesonekey ;;
        29 ) socatonekey ;;
        30 ) gostoneky ;;
        31 ) brookonekey ;;
        32 ) dockeronekey ;;
        33 ) aapanel ;;
        34 ) cxxmatrix ;;
        35 ) rcloneonekey ;;
        36 ) rulelist ;;
        37 ) teamspeakonekey ;;
        38 ) ssronekey ;;
        39 ) epicgamesonekey ;;
	40 ) ipdetestonekey ;;
        v ) updateScript ;;
        0 ) exit 0 ;;
    esac
}
echo "你的VPS当前IP地址为 ${getIpAddress} "
start_menu
