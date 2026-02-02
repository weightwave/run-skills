#!/usr/bin/env bash
set -euo pipefail

# 测试网络连接和镜像源可用性

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        网络连接测试工具               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

# 测试函数
test_endpoint() {
  local name="$1"
  local url="$2"

  echo -n "测试 ${name}... "

  if curl -s --max-time 5 -I "$url" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ 可用${NC}"
    return 0
  else
    echo -e "${RED}✗ 不可用${NC}"
    return 1
  fi
}

echo -e "${YELLOW}测试 Docker Hub 连接性...${NC}\n"

# 测试各个端点
docker_hub_ok=0
mirror_ok=0

# Docker Hub 官方
if test_endpoint "Docker Hub 官方" "https://registry-1.docker.io/v2/"; then
  docker_hub_ok=1
fi

echo ""
echo -e "${YELLOW}测试国内镜像源...${NC}\n"

# 中科大镜像
if test_endpoint "中科大镜像" "https://docker.mirrors.ustc.edu.cn/v2/"; then
  mirror_ok=1
fi

# 网易镜像
if test_endpoint "网易镜像" "https://hub-mirror.c.163.com/v2/"; then
  mirror_ok=1
fi

# Docker 中国
if test_endpoint "Docker 中国" "https://registry.docker-cn.com/v2/"; then
  mirror_ok=1
fi

# 阿里云（公共）
if test_endpoint "阿里云镜像" "https://registry.cn-hangzhou.aliyuncs.com/v2/"; then
  mirror_ok=1
fi

echo ""
echo -e "${YELLOW}测试 DNS 解析...${NC}\n"

echo -n "解析 registry-1.docker.io... "
if nslookup registry-1.docker.io > /dev/null 2>&1; then
  echo -e "${GREEN}✓ 成功${NC}"
else
  echo -e "${RED}✗ 失败${NC}"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 总结
if [ $docker_hub_ok -eq 1 ]; then
  echo -e "${GREEN}✓ Docker Hub 官方可用，可以直接构建${NC}"
  echo -e "  运行: ${YELLOW}make build${NC}"
elif [ $mirror_ok -eq 1 ]; then
  echo -e "${YELLOW}⚠ Docker Hub 官方不可用，但镜像源可用${NC}"
  echo -e "  建议配置镜像加速器: ${GREEN}./setup-mirrors.sh${NC}"
  echo -e "  然后运行: ${YELLOW}make build${NC}"
else
  echo -e "${RED}✗ 所有镜像源都不可用${NC}"
  echo -e "\n${YELLOW}建议：${NC}"
  echo -e "  1. 检查网络连接"
  echo -e "  2. 检查防火墙/代理设置"
  echo -e "  3. 尝试使用 VPN"
  echo -e "  4. 查看详细文档: ${GREEN}NETWORK_TROUBLESHOOTING.md${NC}"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# 提供下一步建议
if [ $docker_hub_ok -eq 0 ] && [ $mirror_ok -eq 1 ]; then
  echo -e "${YELLOW}推荐操作：${NC}"
  echo -e "  1. ${GREEN}./setup-mirrors.sh${NC}   # 配置镜像加速"
  echo -e "  2. ${GREEN}make build${NC}            # 开始构建"
fi
