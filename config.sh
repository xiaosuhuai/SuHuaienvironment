#!/bin/bash

# 服务器环境配置文件
# 可以根据需要修改下面的选项

# 软件安装选项 (true/false)
INSTALL_DOCKER=true      # 安装Docker和Docker Compose
INSTALL_NODEJS=true      # 安装Node.js (v18)
INSTALL_PYTHON=true      # 安装Python3
INSTALL_GOLANG=false     # 安装Go语言
INSTALL_JAVA=false       # 安装Java
INSTALL_NGINX=true       # 安装Nginx
INSTALL_GIT=true         # 安装Git

# 系统配置选项
CONFIGURE_SSH=true       # 配置SSH (禁用root登录和密码认证)
CONFIGURE_FIREWALL=true  # 配置防火墙 (允许SSH, HTTP, HTTPS)
SETUP_SWAP=true          # 设置交换空间
SWAP_SIZE=4G             # 交换空间大小 (例如: 2G, 4G, 8G)
TIMEZONE="Asia/Shanghai" # 时区设置 