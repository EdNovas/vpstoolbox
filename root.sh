green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}

red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}

yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}

sudo lsattr /etc/passwd /etc/shadow >/dev/null 2>&1
sudo chattr -i /etc/passwd /etc/shadow >/dev/null 2>&1
sudo chattr -a /etc/passwd /etc/shadow >/dev/null 2>&1
sudo lsattr /etc/passwd /etc/shadow >/dev/null 2>&1

green "VPS 允许 root 登录"
green "VPS enable root login"
read -p "请输入你的 root 账户密码 (Set your root password):" password
echo root:$password | sudo chpasswd root
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
sudo service sshd restart
green "VPS 用户名: root"
green "VPS 密码: $password"
green "VPS username：root"
green "VPS password：$password"
yellow "如果出现'sudo:unable to resolve host'的提示可直接忽略"
yellow "If 'sudo:unable to resolve host' shows, just ignore it"
echo "Finished!"
