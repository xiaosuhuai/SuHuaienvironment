#!/bin/bash

# 服务器开发环境配置脚本
# 作者：用户
# 日期：$(date +%Y-%m-%d)
# 描述：自动配置新服务器的开发环境

set -e  # 出错时停止脚本执行

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        log_error "此脚本需要root权限运行！"
        log_info "请使用sudo运行此脚本: sudo $0"
        exit 1
    fi
}

# 检测操作系统
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        OS_VERSION=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        OS_VERSION=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        OS_VERSION=$DISTRIB_RELEASE
    else
        log_error "无法检测操作系统类型！"
        exit 1
    fi

    log_info "检测到操作系统: $OS $OS_VERSION"
}

# 加载配置
load_config() {
    CONFIG_FILE="./config.sh"
    if [ -f "$CONFIG_FILE" ]; then
        log_info "加载配置文件..."
        source "$CONFIG_FILE"
    else
        log_warn "配置文件不存在，将使用默认配置"
        # 默认配置
        INSTALL_DOCKER=true
        INSTALL_NODEJS=true
        INSTALL_PYTHON=true
        INSTALL_GOLANG=false
        INSTALL_JAVA=false
        INSTALL_NGINX=true
        INSTALL_GIT=true
        CONFIGURE_SSH=true
        CONFIGURE_FIREWALL=true
        SETUP_SWAP=true
        SWAP_SIZE=4G
        TIMEZONE="Asia/Shanghai"
    fi
}

# 系统更新
update_system() {
    log_info "正在更新系统..."
    if [[ "$OS" == "Ubuntu"* ]] || [[ "$OS" == "Debian"* ]]; then
        apt update -y
        apt upgrade -y
    elif [[ "$OS" == "CentOS"* ]] || [[ "$OS" == "Red Hat"* ]] || [[ "$OS" == "Fedora"* ]]; then
        yum update -y
    else
        log_warn "不支持的操作系统类型: $OS，跳过系统更新"
    fi
}

# 安装基础工具
install_basic_tools() {
    log_info "正在安装基础工具..."
    if [[ "$OS" == "Ubuntu"* ]] || [[ "$OS" == "Debian"* ]]; then
        apt install -y curl wget vim nano git htop tmux zip unzip net-tools
    elif [[ "$OS" == "CentOS"* ]] || [[ "$OS" == "Red Hat"* ]] || [[ "$OS" == "Fedora"* ]]; then
        yum install -y curl wget vim nano git htop tmux zip unzip net-tools
    else
        log_warn "不支持的操作系统类型: $OS，跳过基础工具安装"
    fi
}

# 配置时区
configure_timezone() {
    log_info "配置时区为 $TIMEZONE..."
    timedatectl set-timezone $TIMEZONE
}

# 安装Docker
install_docker() {
    if [ "$INSTALL_DOCKER" = true ]; then
        log_info "正在安装Docker..."
        if command -v docker &> /dev/null; then
            log_warn "Docker已安装，跳过此步骤"
        else
            if [[ "$OS" == "Ubuntu"* ]] || [[ "$OS" == "Debian"* ]]; then
                apt install -y apt-transport-https ca-certificates gnupg lsb-release
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
                apt update
                apt install -y docker-ce docker-ce-cli containerd.io
                systemctl enable docker
                systemctl start docker
                usermod -aG docker $SUDO_USER
            elif [[ "$OS" == "CentOS"* ]] || [[ "$OS" == "Red Hat"* ]] || [[ "$OS" == "Fedora"* ]]; then
                yum install -y yum-utils
                yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                yum install -y docker-ce docker-ce-cli containerd.io
                systemctl enable docker
                systemctl start docker
                usermod -aG docker $SUDO_USER
            else
                log_warn "不支持的操作系统类型: $OS，跳过Docker安装"
                return
            fi
            
            # 安装Docker Compose
            log_info "正在安装Docker Compose..."
            curl -L "https://github.com/docker/compose/releases/download/v2.17.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
            log_info "Docker和Docker Compose安装完成"
        fi
    fi
}

# 安装NodeJS
install_nodejs() {
    if [ "$INSTALL_NODEJS" = true ]; then
        log_info "正在安装Node.js..."
        if command -v node &> /dev/null; then
            log_warn "Node.js已安装，跳过此步骤"
        else
            curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
            
            if [[ "$OS" == "Ubuntu"* ]] || [[ "$OS" == "Debian"* ]]; then
                apt install -y nodejs
            elif [[ "$OS" == "CentOS"* ]] || [[ "$OS" == "Red Hat"* ]] || [[ "$OS" == "Fedora"* ]]; then
                yum install -y nodejs
            else
                log_warn "不支持的操作系统类型: $OS，跳过Node.js安装"
                return
            fi
            
            # 安装常用的npm全局包
            npm install -g pm2 yarn
            log_info "Node.js安装完成"
        fi
    fi
}

# 安装Python
install_python() {
    if [ "$INSTALL_PYTHON" = true ]; then
        log_info "正在安装Python..."
        if [[ "$OS" == "Ubuntu"* ]] || [[ "$OS" == "Debian"* ]]; then
            apt install -y python3 python3-pip python3-venv
        elif [[ "$OS" == "CentOS"* ]] || [[ "$OS" == "Red Hat"* ]] || [[ "$OS" == "Fedora"* ]]; then
            yum install -y python3 python3-pip
        else
            log_warn "不支持的操作系统类型: $OS，跳过Python安装"
            return
        fi
        
        # 配置pip镜像（可选，取决于地区）
        mkdir -p ~/.pip
        echo "[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn" > ~/.pip/pip.conf
        
        log_info "Python安装完成"
    fi
}

# 安装Golang
install_golang() {
    if [ "$INSTALL_GOLANG" = true ]; then
        log_info "正在安装Go..."
        if command -v go &> /dev/null; then
            log_warn "Go已安装，跳过此步骤"
        else
            wget https://go.dev/dl/go1.20.3.linux-amd64.tar.gz
            rm -rf /usr/local/go && tar -C /usr/local -xzf go1.20.3.linux-amd64.tar.gz
            rm go1.20.3.linux-amd64.tar.gz
            
            # 配置环境变量
            echo 'export PATH=$PATH:/usr/local/go/bin' > /etc/profile.d/go.sh
            echo 'export GOPATH=$HOME/go' >> /etc/profile.d/go.sh
            echo 'export PATH=$PATH:$GOPATH/bin' >> /etc/profile.d/go.sh
            source /etc/profile.d/go.sh
            
            log_info "Go安装完成"
        fi
    fi
}

# 安装Java
install_java() {
    if [ "$INSTALL_JAVA" = true ]; then
        log_info "正在安装Java..."
        if command -v java &> /dev/null; then
            log_warn "Java已安装，跳过此步骤"
        else
            if [[ "$OS" == "Ubuntu"* ]] || [[ "$OS" == "Debian"* ]]; then
                apt install -y default-jdk
            elif [[ "$OS" == "CentOS"* ]] || [[ "$OS" == "Red Hat"* ]] || [[ "$OS" == "Fedora"* ]]; then
                yum install -y java-11-openjdk-devel
            else
                log_warn "不支持的操作系统类型: $OS，跳过Java安装"
                return
            fi
            
            log_info "Java安装完成"
        fi
    fi
}

# 安装Nginx
install_nginx() {
    if [ "$INSTALL_NGINX" = true ]; then
        log_info "正在安装Nginx..."
        if command -v nginx &> /dev/null; then
            log_warn "Nginx已安装，跳过此步骤"
        else
            if [[ "$OS" == "Ubuntu"* ]] || [[ "$OS" == "Debian"* ]]; then
                apt install -y nginx
                systemctl enable nginx
                systemctl start nginx
            elif [[ "$OS" == "CentOS"* ]] || [[ "$OS" == "Red Hat"* ]] || [[ "$OS" == "Fedora"* ]]; then
                yum install -y nginx
                systemctl enable nginx
                systemctl start nginx
            else
                log_warn "不支持的操作系统类型: $OS，跳过Nginx安装"
                return
            fi
            
            log_info "Nginx安装完成"
        fi
    fi
}

# 配置SSH
configure_ssh() {
    if [ "$CONFIGURE_SSH" = true ]; then
        log_info "配置SSH服务..."
        
        # 备份原有配置
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
        
        # 应用安全配置
        sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
        sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
        sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
        
        # 重启SSH服务
        systemctl restart sshd
        
        log_info "SSH配置完成"
    fi
}

# 配置防火墙
configure_firewall() {
    if [ "$CONFIGURE_FIREWALL" = true ]; then
        log_info "配置防火墙..."
        
        if [[ "$OS" == "Ubuntu"* ]] || [[ "$OS" == "Debian"* ]]; then
            apt install -y ufw
            ufw default deny incoming
            ufw default allow outgoing
            ufw allow ssh
            ufw allow http
            ufw allow https
            echo "y" | ufw enable
        elif [[ "$OS" == "CentOS"* ]] || [[ "$OS" == "Red Hat"* ]] || [[ "$OS" == "Fedora"* ]]; then
            yum install -y firewalld
            systemctl enable firewalld
            systemctl start firewalld
            firewall-cmd --permanent --add-service=ssh
            firewall-cmd --permanent --add-service=http
            firewall-cmd --permanent --add-service=https
            firewall-cmd --reload
        else
            log_warn "不支持的操作系统类型: $OS，跳过防火墙配置"
            return
        fi
        
        log_info "防火墙配置完成"
    fi
}

# 设置交换空间
setup_swap() {
    if [ "$SETUP_SWAP" = true ]; then
        log_info "设置交换空间..."
        
        # 检查是否已有交换空间
        if free | grep -q Swap; then
            SWAP_TOTAL=$(free | grep Swap | awk '{print $2}')
            if [ $SWAP_TOTAL -gt 0 ]; then
                log_warn "已存在交换空间，跳过此步骤"
                return
            fi
        fi
        
        # 提取数值和单位
        SWAP_SIZE_NUM=$(echo $SWAP_SIZE | sed 's/[^0-9]*//g')
        SWAP_SIZE_UNIT=$(echo $SWAP_SIZE | sed 's/[0-9]*//g')
        
        # 转换为MB
        case $SWAP_SIZE_UNIT in
            G|GB|g|gb)
                SWAP_SIZE_MB=$((SWAP_SIZE_NUM * 1024))
                ;;
            M|MB|m|mb)
                SWAP_SIZE_MB=$SWAP_SIZE_NUM
                ;;
            *)
                SWAP_SIZE_MB=4096  # 默认4GB
                ;;
        esac
        
        # 创建交换文件
        dd if=/dev/zero of=/swapfile bs=1M count=$SWAP_SIZE_MB
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        
        # 添加到fstab以便开机自动挂载
        echo '/swapfile none swap sw 0 0' >> /etc/fstab
        
        # 配置交换空间参数
        echo 'vm.swappiness=10' >> /etc/sysctl.conf
        echo 'vm.vfs_cache_pressure=50' >> /etc/sysctl.conf
        sysctl -p
        
        log_info "交换空间设置完成"
    fi
}

# 安装Git并配置
install_git() {
    if [ "$INSTALL_GIT" = true ]; then
        log_info "安装和配置Git..."
        
        if command -v git &> /dev/null; then
            log_warn "Git已安装，仅进行配置"
        else
            if [[ "$OS" == "Ubuntu"* ]] || [[ "$OS" == "Debian"* ]]; then
                apt install -y git
            elif [[ "$OS" == "CentOS"* ]] || [[ "$OS" == "Red Hat"* ]] || [[ "$OS" == "Fedora"* ]]; then
                yum install -y git
            else
                log_warn "不支持的操作系统类型: $OS，跳过Git安装"
                return
            fi
        fi
        
        log_info "Git安装和配置完成"
    fi
}

# 主函数
main() {
    clear
    echo "=========================================================="
    echo "               服务器开发环境配置脚本                      "
    echo "=========================================================="
    
    check_root
    detect_os
    load_config
    
    echo "将执行以下操作:"
    [ "$INSTALL_DOCKER" = true ] && echo "- 安装Docker和Docker Compose"
    [ "$INSTALL_NODEJS" = true ] && echo "- 安装Node.js"
    [ "$INSTALL_PYTHON" = true ] && echo "- 安装Python"
    [ "$INSTALL_GOLANG" = true ] && echo "- 安装Go"
    [ "$INSTALL_JAVA" = true ] && echo "- 安装Java"
    [ "$INSTALL_NGINX" = true ] && echo "- 安装Nginx"
    [ "$INSTALL_GIT" = true ] && echo "- 安装Git"
    [ "$CONFIGURE_SSH" = true ] && echo "- 配置SSH"
    [ "$CONFIGURE_FIREWALL" = true ] && echo "- 配置防火墙"
    [ "$SETUP_SWAP" = true ] && echo "- 设置交换空间: $SWAP_SIZE"
    echo "- 配置时区: $TIMEZONE"
    
    read -p "是否继续? (y/n): " confirm
    if [[ $confirm != "y" && $confirm != "Y" ]]; then
        log_info "操作已取消"
        exit 0
    fi
    
    # 执行任务
    update_system
    install_basic_tools
    configure_timezone
    install_docker
    install_nodejs
    install_python
    install_golang
    install_java
    install_nginx
    install_git
    configure_ssh
    configure_firewall
    setup_swap
    
    log_info "所有任务已完成！"
    log_info "请重新登录以应用所有更改。"
}

# 执行主函数
main 