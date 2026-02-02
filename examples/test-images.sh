#!/usr/bin/env bash
set -euo pipefail

# 测试构建的镜像是否正常工作
# 使用方法: ./examples/test-images.sh [tag]

TAG="${1:-latest}"
ECR_REGISTRY="471112576951.dkr.ecr.ap-northeast-1.amazonaws.com"
ECR_REPOSITORY="weightwave/skill"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Testing images with tag: ${YELLOW}${TAG}${NC}\n"

# Test ascii-image-converter
echo -e "${BLUE}Testing ascii-image-converter...${NC}"
if podman run --rm \
  "${ECR_REGISTRY}/${ECR_REPOSITORY}:ascii-image-converter-${TAG}" \
  --version >/dev/null 2>&1; then
  echo -e "${GREEN}✓ ascii-image-converter OK${NC}\n"
else
  echo -e "${RED}✗ ascii-image-converter FAILED${NC}\n"
fi

# Test ffmpeg
echo -e "${BLUE}Testing ffmpeg...${NC}"
if podman run --rm \
  -e CALLBACK_URL=http://localhost:3000/callback \
  -e INTERNAL_SECRET=test \
  -e COMMAND=/usr/bin/ffmpeg \
  -e USER_ID=test \
  "${ECR_REGISTRY}/${ECR_REPOSITORY}:ffmpeg-${TAG}" \
  -version >/dev/null 2>&1; then
  echo -e "${GREEN}✓ ffmpeg OK${NC}\n"
else
  echo -e "${RED}✗ ffmpeg FAILED${NC}\n"
fi

# Test imagemagick
echo -e "${BLUE}Testing imagemagick...${NC}"
if podman run --rm \
  -e CALLBACK_URL=http://localhost:3000/callback \
  -e INTERNAL_SECRET=test \
  -e COMMAND=/usr/bin/convert \
  -e USER_ID=test \
  "${ECR_REGISTRY}/${ECR_REPOSITORY}:imagemagick-${TAG}" \
  -version >/dev/null 2>&1; then
  echo -e "${GREEN}✓ imagemagick OK${NC}\n"
else
  echo -e "${RED}✗ imagemagick FAILED${NC}\n"
fi

echo -e "${BLUE}All tests completed!${NC}"
