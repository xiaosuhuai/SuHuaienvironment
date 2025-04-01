# 服务器配置脚本 - Python与GitHub

> **注意**: 本仓库正在更新中，功能可能会有变动，请关注最新更新。

这个仓库包含一个自动化脚本，用于快速配置新服务器上的Python 3.11环境和GitHub SSH密钥。

## 功能特性

- ✅ 自动检测操作系统类型（支持Ubuntu、Debian、CentOS、RHEL和Fedora）
- ✅ 安装Python 3.11并设置为默认解释器
- ✅ 安装pip并配置为全局可用命令
- ✅ 配置GitHub SSH密钥，方便克隆私有仓库

## 快速开始

一行命令安装：

```bash
bash <(curl -sSL https://raw.githubusercontent.com/xiaosuhuai/SuHuaienvironment/main/server_setup.sh)
```

## 安全注意事项

- 此脚本需要root权限运行
- 使用前建议查看脚本内容：`curl -sSL https://raw.githubusercontent.com/xiaosuhuai/SuHuaienvironment/main/server_setup.sh | less`

## 许可证

MIT 