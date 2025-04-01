# 服务器配置脚本 - Python与GitHub

这个仓库包含一个自动化脚本，用于快速配置新服务器上的Python 3.11环境和GitHub SSH密钥。减少重复工作，提高效率。

## 支持的操作系统

- Ubuntu
- Debian
- CentOS
- Red Hat
- Fedora

## 功能特性

- ✅ 自动检测操作系统类型
- ✅ 安装Python 3.11并设置为默认解释器
- ✅ 配置GitHub SSH密钥，方便克隆私有仓库

## 快速开始

### 1. 获取脚本

```bash
git clone https://github.com/xiaosuhuai/SuHuaienvironment.git
cd SuHuaienvironment
```

或者直接下载脚本：

```bash
wget https://raw.githubusercontent.com/xiaosuhuai/SuHuaienvironment/main/server_setup.sh
chmod +x server_setup.sh
```

### 2. 运行脚本

```bash
sudo ./server_setup.sh
```

## 脚本执行流程

1. **Python 3.11安装**：
   - 检查是否已安装Python 3.11
   - 如果未安装，根据操作系统安装Python 3.11
   - 将Python 3.11设置为默认Python解释器
   - 验证安装结果

2. **GitHub SSH密钥配置**：
   - 检查是否已存在SSH密钥
   - 如果不存在，生成新的SSH密钥
   - 显示公钥，用户需要将其添加到GitHub账户
   - 测试SSH连接，确认配置成功

## 安全注意事项

- 此脚本需要root权限运行
- 如果您使用sudo运行脚本，SSH密钥将生成给实际的用户，而非root用户

## 贡献

欢迎通过Pull Request或Issue贡献代码和建议。

## 许可证

MIT 