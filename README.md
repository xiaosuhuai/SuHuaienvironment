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
- ✅ 安装pip并配置为全局可用命令
- ✅ 配置GitHub SSH密钥，方便克隆私有仓库

## 快速开始

### 方法1：一行命令运行（推荐）

直接使用以下命令一键安装（需要提供GitHub邮箱）：

```bash
# 最佳方式：使用bash执行远程脚本
bash <(curl -sSL https://raw.githubusercontent.com/xiaosuhuai/SuHuaienvironment/main/server_setup.sh) -e your_email@example.com

# 或者使用wget
bash <(wget -qO- https://raw.githubusercontent.com/xiaosuhuai/SuHuaienvironment/main/server_setup.sh) -e your_email@example.com
```

以下方式也可以使用，但可能不如上面的方式可靠：

```bash
# 使用curl管道传输到bash
curl -sSL https://raw.githubusercontent.com/xiaosuhuai/SuHuaienvironment/main/server_setup.sh | sudo bash -s -- -e your_email@example.com

# 或使用wget管道传输到bash
wget -qO- https://raw.githubusercontent.com/xiaosuhuai/SuHuaienvironment/main/server_setup.sh | sudo bash -s -- -e your_email@example.com
```

### 方法2：克隆仓库运行

```bash
git clone https://github.com/xiaosuhuai/SuHuaienvironment.git
cd SuHuaienvironment
sudo ./server_setup.sh
```

### 方法3：下载脚本运行

```bash
wget https://raw.githubusercontent.com/xiaosuhuai/SuHuaienvironment/main/server_setup.sh
chmod +x server_setup.sh
sudo ./server_setup.sh
```

## 命令行参数

脚本支持以下命令行参数：

- `-y, --yes`: 自动确认所有提示，无需交互
- `-e, --email`: 指定GitHub邮箱地址（通过管道运行时必需）

示例：
```bash
# 自动确认模式
sudo ./server_setup.sh -y -e your_email@example.com
```

## 脚本执行流程

1. **Python 3.11与pip安装**：
   - 检查是否已安装Python 3.11
   - 如果未安装，根据操作系统安装Python 3.11
   - 安装pip并创建全局命令软链接
   - 将Python 3.11设置为默认Python解释器
   - 验证安装结果，包括Python和pip版本

2. **GitHub SSH密钥配置**：
   - 检查是否已存在SSH密钥
   - 如果不存在，生成新的SSH密钥
   - 显示公钥，用户需要将其添加到GitHub账户
   - 测试SSH连接，确认配置成功

## 安全注意事项

- 此脚本需要root权限运行
- 如果您使用sudo运行脚本，SSH密钥将生成给实际的用户，而非root用户
- 使用一行命令安装前，建议先检查脚本内容：`curl -sSL https://raw.githubusercontent.com/xiaosuhuai/SuHuaienvironment/main/server_setup.sh | less`

## 故障排除

- **pip安装失败**：某些系统上，系统自带的pip可能会导致安装冲突。脚本现已增加`--ignore-installed`选项，避免卸载系统pip
- **找不到pip命令**：如果pip命令不可用，请尝试使用`python3.11 -m pip`命令代替
- **脚本执行过程中退出**：尝试使用`bash <(curl ...)`方式运行脚本，而不是`curl ... | bash`

## 贡献

欢迎通过Pull Request或Issue贡献代码和建议。

## 许可证

MIT 