# dev-env-bootstrap
这是一个在 macOS 上使用 Multipass 快速创建 Ubuntu 虚拟机，并完成环境自动化部署的脚本仓库。

## 目录结构

- `start-ubuntu.sh`：一键启动 Ubuntu VM 脚本  
- `cloud-init.yaml`：cloud-init 配置示例  
- `provision/`：后续环境部署脚本集合  

## 快速开始

```bash
git clone https://github.com/yourname/ubuntu-vm-bootstrap.git
cd ubuntu-vm-bootstrap

# 一键启动并进入 Ubuntu VM
bash start-ubuntu.sh

# VM 创建完毕后，可执行基础环境安装脚本
multipass exec ubuntu-test -- bash /home/ubuntu/provision/base-env.sh

```