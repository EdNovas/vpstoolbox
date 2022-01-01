#!/bin/bash
ver="1.2.0"
changeLog="添加了二级目录，加入了内存信息查看，程序实时占用，硬盘占用查询"
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
	getIpAddress=$(curl https://ip.gs)
}





# ==============part1=============

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
    top
}

# ==============part1=============





# ==============part2=============

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

function chinaSpeedTest(){
    green "单线程/双线程三网测速"
    echo "1. 多线程"
    echo "2. 单线程"
    echo "0. 返回上级目录"
    read -p "请输入选项（直接回车为多线程) ：" chinaSpeedTestChoice
    case "$chinaSpeedTestChoice" in
        1 )
            bash <(curl -sSL "https://github.com/CoiaPrant/Speedtest/raw/main/speedtest-multi.sh")
        ;;
        2 ) 
            bash <(curl -sSL "https://github.com/CoiaPrant/Speedtest/raw/main/speedtest-single.sh")
        ;;
        0 ) start_menu ;;
        * )
            bash <(curl -sSL "https://github.com/CoiaPrant/Speedtest/raw/main/speedtest-multi.sh")
        ;;
    esac
}
# ==============part2=============





# ==============part3=============
function macka(){
    wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
}


function xui(){
    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
}

function ssronekey(){
    bash <(curl -sL https://s.hijk.art/ssr.sh)
}


function xrayronekey(){
    bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)
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

function tcponekey(){
    wget https://raw.githubusercontent.com/wdm1732418365/bbr-tcp-boost/main/tools.sh -O tools.sh && bash tools.sh
}

function bbronekey(){
    wget -N --no-check-certificate "https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
}


function ovzbbr(){
    wget --no-cache -O lkl-haproxy.sh https://github.com/mzz2017/lkl-haproxy/raw/master/lkl-haproxy.sh && bash lkl-haproxy.sh
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
    wget -N https://cdn.jsdelivr.net/gh/fscarmen/warp/menu.sh && bash menu.sh
}

function fscarmen(){
    if [ $release = "Centos" ]; then
        yum install screen -y
    else
        apt install screen -y
    fi
    yellow "这是在'warp'的screen中，如需退出按ctrl+a+d，返回'screen -r warp'"
    screen -R warp && warp i
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
    git clone -b main https://github.com/luminoleon/epicgames-claimer.git
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
    wget -N https://raw.githubusercontent.com/wdm1732418365/vpstoolbox/main/ednovastool.sh && chmod +x ednovastool.sh && ./ednovastool.sh
}
# ==============part9=============










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
    echo "5. 修改主机名"
    echo "6. 显示本机IP"
    echo "7. 显示实时进程"
    echo "8. 显示内存使用情况"
    echo "9. 显示磁盘占用"
    echo "0. 返回上一级"
    echo "                        "
    read -p "请输入选项:" partOneInput
    case "$partOneInput" in
        1 ) rootLogin ;;
        2 ) vpsupdate ;;
        3 ) oraclefirewall ;;
        4 ) centosfirewall ;;
        5 ) changehostname ;;
        6 ) driveSpace ;;
        7 ) interestingTools ;;
        8 ) memorySpace ;;
        9 ) realTimeProgress ;;
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
    echo "4. 三网测速脚本"
    echo "0. 返回上一级"
    echo "                        "
    read -p "请输入选项:" partTwoInput
    case "$partTwoInput" in
        1 ) benchonekey ;;
        2 ) superbench ;;
        3 ) lemonbench ;;
        4 ) chinaSpeedTest ;;
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
    echo "5. Xrayr添加本地审计规则"
    echo "6. Mtproxy+伪tls一键脚本"
    echo "                        "
    echo "7. TCP调优脚本"
    echo "8. 六合一BBR脚本"
    echo "9. OVZ开启BBR"
    echo "0. 返回上一级"
    echo "                        "
    read -p "请输入选项:" partThreeInput
    case "$partThreeInput" in
        1 ) macka ;;
        2 ) xui ;;
        3 ) ssronekey ;;
        4 ) xrayronekey ;;
        5 ) rulelist ;;
        6 ) mtproxyonekey ;;
        7 ) tcponekey ;;
        8 ) bbronekey ;;
        9 ) ovzbbr ;;
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
    echo "4. fscarmen warp刷IP脚本"
    echo "5. acacia233 warp解锁奈飞脚本"
    echo "6. GeorgeXie2333 warp解锁奈飞脚本"
    echo "7. GeorgeXie2333 warp刷IP脚本"
    echo "0. 返回上一级"
    echo "                        "
    read -p "请输入选项:" partFourInput
    case "$partFourInput" in
        1 ) region ;;
        2 ) netflixdetect ;;
        3 ) warponekey ;;
        4 ) fscarmen ;;
        5 ) acacia233 ;;
        6 ) georgexie2333onekey ;;
        7 ) georgexie2333 ;;
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


# part 9
# function updateScript(){
#     wget -N https://raw.githubusercontent.com/wdm1732418365/vpstoolbox/main/ednovastool.sh && chmod +x ednovastool.sh && ./ednovastool.sh
# }



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
start_menu
