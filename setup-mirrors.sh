#!/usr/bin/env bash
set -euo pipefail

# 配置 Podman 镜像加速器
# 适用于国内网络环境

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}配置 Podman 镜像加速器...${NC}\n"

# 检查操作系统
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo -e "${YELLOW}检测到 macOS 系统${NC}"

  # Podman machine 的配置路径
  PODMAN_MACHINE_NAME=$(podman machine list --format '{{.Name}}' | head -n 1)

  if [ -z "$PODMAN_MACHINE_NAME" ]; then
    echo -e "${YELLOW}未找到运行中的 Podman machine，正在初始化...${NC}"
    podman machine init
    PODMAN_MACHINE_NAME=$(podman machine list --format '{{.Name}}' | head -n 1)
  fi

  echo -e "${GREEN}Podman machine: ${PODMAN_MACHINE_NAME}${NC}"

  # 创建配置文件
  cat > /tmp/registries.conf << 'EOF'
# 镜像加速配置
unqualified-search-registries = ["docker.io"]

[[registry]]
prefix = "docker.io"
location = "docker.io"

[[registry.mirror]]
location = "docker.mirrors.ustc.edu.cn"
insecure = false

[[registry.mirror]]
location = "hub-mirror.c.163.com"
insecure = false

[[registry.mirror]]
location = "registry.docker-cn.com"
insecure = false
EOF

  echo -e "${YELLOW}正在将配置复制到 Podman machine...${NC}"

  # 将配置文件复制到 podman machine
  podman machine ssh ${PODMAN_MACHINE_NAME} "sudo mkdir -p /etc/containers/registries.conf.d"
  cat /tmp/registries.conf | podman machine ssh ${PODMAN_MACHINE_NAME} "sudo tee /etc/containers/registries.conf.d/mirrors.conf" > /dev/null

  # 重启 podman machine
  echo -e "${YELLOW}重启 Podman machine 以应用配置...${NC}"
  podman machine stop ${PODMAN_MACHINE_NAME} || true
  podman machine start ${PODMAN_MACHINE_NAME}

  echo -e "${GREEN}✓ 镜像加速器配置完成！${NC}"

else
  echo -e "${YELLOW}检测到 Linux 系统${NC}"

  # Linux 系统直接修改配置
  sudo mkdir -p /etc/containers/registries.conf.d

  sudo tee /etc/containers/registries.conf.d/mirrors.conf > /dev/null << 'EOF'
# 镜像加速配置
unqualified-search-registries = ["docker.io"]

[[registry]]
prefix = "docker.io"
location = "docker.io"

[[registry.mirror]]
location = "docker.mirrors.ustc.edu.cn"
insecure = false

[[registry.mirror]]
location = "hub-mirror.c.163.com"
insecure = false

[[registry.mirror]]
location = "registry.docker-cn.com"
insecure = false
EOF

  echo -e "${GREEN}✓ 镜像加速器配置完成！${NC}"
fi

echo -e "\n${BLUE}测试镜像拉取...${NC}"
podman pull docker.io/library/alpine:3.19 || echo -e "${YELLOW}测试失败，但配置已应用${NC}"

echo -e "\n${GREEN}配置完成！现在可以运行 make build 了${NC}"
