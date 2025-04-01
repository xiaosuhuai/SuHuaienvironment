# 服务器开发环境配置脚本

这个仓库包含一个自动化脚本，用于快速配置新服务器的开发环境。通过运行单个脚本，您可以安装和配置常用的开发工具、服务和系统设置，避免手动执行大量重复的命令。

## 支持的操作系统

- Ubuntu
- Debian
- CentOS
- Red Hat
- Fedora

## 功能特性

- ✅ 自动检测操作系统类型
- ✅ 系统更新与基础工具安装
- ✅ Docker 和 Docker Compose 安装
- ✅ Node.js 环境配置
- ✅ Python 环境配置
- ✅ Go 语言环境配置（可选）
- ✅ Java 环境配置（可选）
- ✅ Nginx 安装与配置
- ✅ Git 安装与配置
- ✅ SSH 安全配置
- ✅ 防火墙配置
- ✅ 交换空间设置
- ✅ 时区配置

## 快速开始

### 1. 获取脚本

```bash
git clone https://github.com/用户名/server-setup.git
cd server-setup
```

或者直接下载脚本：

```bash
wget https://raw.githubusercontent.com/用户名/server-setup/main/server_setup.sh
wget https://raw.githubusercontent.com/用户名/server-setup/main/config.sh
chmod +x server_setup.sh
```

### 2. 配置安装选项（可选）

编辑 `config.sh` 文件以自定义您的安装选项：

```bash
nano config.sh
```

### 3. 运行脚本

```bash
sudo ./server_setup.sh
```

## 自定义配置

您可以通过编辑 `config.sh` 文件来自定义安装选项。所有选项都可以设置为 `true` 或 `false`：

```bash
# 软件安装选项
INSTALL_DOCKER=true      # 安装Docker和Docker Compose
INSTALL_NODEJS=true      # 安装Node.js
INSTALL_PYTHON=true      # 安装Python3
INSTALL_GOLANG=false     # 安装Go语言
INSTALL_JAVA=false       # 安装Java
INSTALL_NGINX=true       # 安装Nginx
INSTALL_GIT=true         # 安装Git

# 系统配置选项
CONFIGURE_SSH=true       # 配置SSH (禁用root登录和密码认证)
CONFIGURE_FIREWALL=true  # 配置防火墙
SETUP_SWAP=true          # 设置交换空间
SWAP_SIZE=4G             # 交换空间大小
TIMEZONE="Asia/Shanghai" # 时区设置
```

## 安全注意事项

- 脚本会禁用SSH的密码认证和root登录，确保您在运行脚本前已设置好SSH密钥
- 对于生产环境，请仔细检查并根据您的特定安全需求调整配置

## 贡献

欢迎通过Pull Request或Issue贡献代码和建议。

## 许可证

MIT 