#!/bin/bash

# 服务器配置脚本 - 精简版
# 功能：安装Python 3.11和配置GitHub SSH
# 日期：$(date +%Y-%m-%d)

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

# 安装Python 3.11和pip
install_python() {
    log_info "检查Python 3.11..."
    
    # 检查Python是否已安装
    if command -v python3.11 &> /dev/null; then
        log_info "Python 3.11 已安装"
    else
        log_info "开始安装Python 3.11..."
        
        if [[ "$OS" == "Ubuntu"* ]] || [[ "$OS" == "Debian"* ]]; then
            # 安装依赖包
            apt update
            apt install -y software-properties-common build-essential libssl-dev zlib1g-dev \
                libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
                libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev
            
            # 添加deadsnakes PPA仓库并安装Python 3.11
            add-apt-repository -y ppa:deadsnakes/ppa
            apt update
            apt install -y python3.11 python3.11-venv python3.11-dev python3.11-distutils
            
            # 安装pip - 使用--ignore-installed避免卸载系统pip
            log_info "安装pip..."
            curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 - --ignore-installed
            
            # 确保pip命令可用
            if [ ! -L /usr/bin/pip ]; then
                # 使用软链接前先检查目标是否存在
                if [ -f /usr/local/bin/pip3.11 ]; then
                    ln -sf /usr/local/bin/pip3.11 /usr/bin/pip
                elif [ -f ~/.local/bin/pip3.11 ]; then
                    ln -sf ~/.local/bin/pip3.11 /usr/bin/pip
                fi
            fi
            if [ ! -L /usr/bin/pip3 ]; then
                # 使用软链接前先检查目标是否存在
                if [ -f /usr/local/bin/pip3.11 ]; then
                    ln -sf /usr/local/bin/pip3.11 /usr/bin/pip3
                elif [ -f ~/.local/bin/pip3.11 ]; then
                    ln -sf ~/.local/bin/pip3.11 /usr/bin/pip3
                fi
            fi
        elif [[ "$OS" == "CentOS"* ]] || [[ "$OS" == "Red Hat"* ]] || [[ "$OS" == "Fedora"* ]]; then
            # 在CentOS/RHEL上安装Python 3.11
            if [[ "$OS" == "CentOS"* ]] && [[ "$OS_VERSION" == "7"* ]]; then
                # CentOS 7需要特殊处理
                yum install -y gcc openssl-devel bzip2-devel libffi-devel
                
                # 下载并编译Python 3.11
                cd /tmp
                wget https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tgz
                tar xzf Python-3.11.0.tgz
                cd Python-3.11.0
                ./configure --enable-optimizations
                make altinstall
                
                # 安装pip - 使用--ignore-installed避免卸载系统pip
                log_info "安装pip..."
                curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 - --ignore-installed
                
                # 确保pip命令可用
                if [ ! -L /usr/bin/pip ]; then
                    # 使用软链接前先检查目标是否存在
                    if [ -f /usr/local/bin/pip3.11 ]; then
                        ln -sf /usr/local/bin/pip3.11 /usr/bin/pip
                    elif [ -f ~/.local/bin/pip3.11 ]; then
                        ln -sf ~/.local/bin/pip3.11 /usr/bin/pip
                    fi
                fi
                if [ ! -L /usr/bin/pip3 ]; then
                    # 使用软链接前先检查目标是否存在
                    if [ -f /usr/local/bin/pip3.11 ]; then
                        ln -sf /usr/local/bin/pip3.11 /usr/bin/pip3
                    elif [ -f ~/.local/bin/pip3.11 ]; then
                        ln -sf ~/.local/bin/pip3.11 /usr/bin/pip3
                    fi
                fi
                
                cd /tmp
                rm -rf Python-3.11.0*
            else
                # CentOS 8/Fedora/RHEL 8
                dnf install -y python3.11 python3.11-devel
                
                # 安装pip - 使用--ignore-installed避免卸载系统pip
                log_info "安装pip..."
                curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 - --ignore-installed
                
                # 确保pip命令可用
                if [ ! -L /usr/bin/pip ]; then
                    # 使用软链接前先检查目标是否存在
                    if [ -f /usr/local/bin/pip3.11 ]; then
                        ln -sf /usr/local/bin/pip3.11 /usr/bin/pip
                    elif [ -f ~/.local/bin/pip3.11 ]; then
                        ln -sf ~/.local/bin/pip3.11 /usr/bin/pip
                    fi
                fi
                if [ ! -L /usr/bin/pip3 ]; then
                    # 使用软链接前先检查目标是否存在
                    if [ -f /usr/local/bin/pip3.11 ]; then
                        ln -sf /usr/local/bin/pip3.11 /usr/bin/pip3
                    elif [ -f ~/.local/bin/pip3.11 ]; then
                        ln -sf ~/.local/bin/pip3.11 /usr/bin/pip3
                    fi
                fi
            fi
        else
            log_error "不支持的操作系统: $OS"
            exit 1
        fi
        
        log_info "Python 3.11 和 pip 安装完成"
    fi
    
    # 检查pip是否已安装
    if ! command -v pip &> /dev/null; then
        log_info "安装pip..."
        # 使用--ignore-installed避免卸载系统pip
        curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 - --ignore-installed
        
        # 确保pip命令可用
        if [ ! -L /usr/bin/pip ]; then
            # 使用软链接前先检查目标是否存在
            if [ -f /usr/local/bin/pip3.11 ]; then
                ln -sf /usr/local/bin/pip3.11 /usr/bin/pip
            elif [ -f ~/.local/bin/pip3.11 ]; then
                ln -sf ~/.local/bin/pip3.11 /usr/bin/pip
            fi
        fi
        if [ ! -L /usr/bin/pip3 ]; then
            # 使用软链接前先检查目标是否存在
            if [ -f /usr/local/bin/pip3.11 ]; then
                ln -sf /usr/local/bin/pip3.11 /usr/bin/pip3
            elif [ -f ~/.local/bin/pip3.11 ]; then
                ln -sf ~/.local/bin/pip3.11 /usr/bin/pip3
            fi
        fi
    else
        log_info "pip 已安装"
    fi
    
    # 将Python 3.11设置为默认Python版本
    log_info "将Python 3.11设置为默认Python解释器..."
    
    # 检查是否有其他Python版本
    if [[ "$OS" == "Ubuntu"* ]] || [[ "$OS" == "Debian"* ]]; then
        # 使用update-alternatives
        update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
        update-alternatives --set python3 /usr/bin/python3.11
        
        # 创建python软链接指向python3
        if [ -L /usr/bin/python ]; then
            rm /usr/bin/python
        fi
        ln -s /usr/bin/python3 /usr/bin/python
    elif [[ "$OS" == "CentOS"* ]] || [[ "$OS" == "Red Hat"* ]] || [[ "$OS" == "Fedora"* ]]; then
        # CentOS/RHEL/Fedora
        alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
        alternatives --set python3 /usr/bin/python3.11
        
        # 创建python软链接指向python3
        if [ -L /usr/bin/python ]; then
            rm /usr/bin/python
        fi
        ln -s /usr/bin/python3 /usr/bin/python
    fi
    
    # 验证Python和pip版本
    log_info "验证Python和pip版本..."
    python3 --version
    python --version
    pip --version || log_warn "pip命令可能尚未在PATH中，请尝试使用python -m pip代替"
    
    log_info "Python 3.11 和 pip 设置完成，并已设为默认"
}

# 配置GitHub SSH密钥
setup_github_ssh() {
    log_info "开始配置GitHub SSH密钥..."
    
    # 获取用户名，如果是通过sudo运行，则获取实际用户
    if [ -n "$SUDO_USER" ]; then
        USERNAME=$SUDO_USER
    else
        USERNAME=$(whoami)
    fi
    
    # 检查是否已有SSH密钥
    SSH_DIR="/home/$USERNAME/.ssh"
    if [ "$USERNAME" = "root" ]; then
        SSH_DIR="/root/.ssh"
    fi
    
    # 确保SSH目录存在
    mkdir -p "$SSH_DIR"
    if [ "$USERNAME" != "root" ]; then
        chown -R $USERNAME:$USERNAME "$SSH_DIR"
    fi
    
    # 配置密钥
    if [ -f "$SSH_DIR/id_ed25519" ]; then
        log_warn "SSH密钥已存在，使用现有密钥"
    else
        # 获取用户的GitHub邮箱
        if [ -z "$GITHUB_EMAIL" ]; then
            if [ -t 0 ]; then  # 检查标准输入是否为终端
                echo ""
                read -p "请输入您的GitHub邮箱: " GITHUB_EMAIL
            else
                log_error "执行脚本时未提供GitHub邮箱。请使用 -e 参数提供邮箱，如: bash server_setup.sh -e your_email@example.com"
                exit 1
            fi
        fi
        
        log_info "使用邮箱 $GITHUB_EMAIL 生成SSH密钥"
        
        # 生成密钥
        log_info "正在生成SSH密钥..."
        if [ "$USERNAME" = "root" ]; then
            ssh-keygen -t ed25519 -C "$GITHUB_EMAIL" -f "$SSH_DIR/id_ed25519" -N ""
        else
            su $USERNAME -c "ssh-keygen -t ed25519 -C \"$GITHUB_EMAIL\" -f \"$SSH_DIR/id_ed25519\" -N \"\""
        fi
        
        # 启动ssh-agent
        eval "$(ssh-agent -s)"
        
        # 添加密钥到ssh-agent
        if [ "$USERNAME" = "root" ]; then
            ssh-add "$SSH_DIR/id_ed25519"
        else
            su $USERNAME -c "ssh-add $SSH_DIR/id_ed25519"
        fi
        
        # 配置SSH配置文件
        if [ ! -f "$SSH_DIR/config" ]; then
            echo "Host github.com
    User git
    IdentityFile $SSH_DIR/id_ed25519
    AddKeysToAgent yes" > "$SSH_DIR/config"
            
            if [ "$USERNAME" != "root" ]; then
                chown $USERNAME:$USERNAME "$SSH_DIR/config"
            fi
        fi
    fi
    
    # 显示公钥
    log_info "请将以下SSH公钥添加到您的GitHub账户："
    echo ""
    cat "$SSH_DIR/id_ed25519.pub"
    echo ""
    log_info "请访问 https://github.com/settings/keys 并添加上面的SSH公钥"
    
    if [ ! -t 0 ] || [ ! -t 1 ]; then  # 如果不是在终端中运行
        log_info "由于非交互式运行，请手动完成SSH密钥添加后再测试连接"
        log_info "可以使用以下命令测试连接：ssh -T git@github.com"
    else
        # 等待用户确认
        read -p "添加密钥后，按回车键继续..." continue
        
        # 测试连接
        log_info "测试与GitHub的连接..."
        if [ "$USERNAME" = "root" ]; then
            ssh -T git@github.com -o StrictHostKeyChecking=no || true
        else
            su $USERNAME -c "ssh -T git@github.com -o StrictHostKeyChecking=no" || true
        fi
        
        # 一般情况下，即使成功GitHub也会返回非零退出码，但会显示欢迎消息
        log_info "如果看到'Hi username! You've successfully authenticated...'说明成功认证"
        read -p "连接是否成功? (y/n): " is_success
        
        if [[ $is_success == "y" || $is_success == "Y" ]]; then
            log_info "GitHub SSH配置完成！"
        else
            log_error "GitHub SSH配置未成功，请检查错误信息"
        fi
    fi
}

# 主函数
main() {
    # 解析命令行参数
    GITHUB_EMAIL=""
    
    while [ $# -gt 0 ]; do
        case "$1" in
            -e|--email)
                GITHUB_EMAIL="$2"
                shift 2
                ;;
            -y|--yes)
                # 只是为保持兼容性，现在不再需要这个标志
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    clear
    echo "=========================================================="
    echo "             服务器配置脚本 - Python与GitHub               "
    echo "=========================================================="
    
    check_root
    detect_os
    
    echo "将执行以下操作:"
    echo "- 安装Python 3.11和pip，并设置为默认版本"
    echo "- 配置GitHub SSH密钥"
    
    # 检查是否在终端运行，决定是否需要用户确认
    if [ -t 0 ] && [ -t 1 ]; then  # 如果标准输入和标准输出都连接到终端
        read -p "是否继续? (y/n): " confirm
        if [[ $confirm != "y" && $confirm != "Y" ]]; then
            log_info "操作已取消"
            exit 0
        fi
    else
        log_info "自动模式，跳过确认"
    fi
    
    # 执行任务
    install_python
    setup_github_ssh
    
    log_info "所有任务已完成！"
}

# 执行主函数
main "$@" 