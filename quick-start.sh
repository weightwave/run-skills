#!/usr/bin/env bash
set -euo pipefail

# Quick start script for building and deploying run-skills containers

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Run-Skills Container Quick Start    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v podman &> /dev/null; then
  echo -e "${RED}✗ Podman not found${NC}"
  echo -e "  Install with: ${GREEN}brew install podman${NC}"
  exit 1
fi
echo -e "${GREEN}✓ Podman installed${NC}"

if ! command -v aws &> /dev/null; then
  echo -e "${RED}✗ AWS CLI not found${NC}"
  echo -e "  Install with: ${GREEN}brew install awscli${NC}"
  exit 1
fi
echo -e "${GREEN}✓ AWS CLI installed${NC}"

# Check podman machine
if ! podman machine list 2>/dev/null | grep -q "running"; then
  echo -e "${YELLOW}Starting podman machine...${NC}"
  podman machine start || {
    echo -e "${YELLOW}Initializing podman machine...${NC}"
    podman machine init
    podman machine start
  }
fi
echo -e "${GREEN}✓ Podman machine running${NC}"

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
  echo -e "${RED}✗ AWS credentials not configured${NC}"
  echo -e "  Configure with: ${GREEN}aws configure${NC}"
  exit 1
fi
echo -e "${GREEN}✓ AWS credentials valid${NC}\n"

# Show options
echo -e "${BLUE}What would you like to do?${NC}"
echo -e "  ${GREEN}1${NC} - Build all images (local only)"
echo -e "  ${GREEN}2${NC} - Build and push to ECR"
echo -e "  ${GREEN}3${NC} - Just push existing images"
echo -e "  ${GREEN}4${NC} - View build info"
echo -e "  ${GREEN}5${NC} - Test images"
echo -e ""
read -p "Enter choice (1-5): " choice

case $choice in
  1)
    echo -e "\n${BLUE}Building all images...${NC}"
    make build
    echo -e "\n${GREEN}✓ Build complete!${NC}"
    echo -e "Run ${YELLOW}make images${NC} to view built images"
    ;;
  2)
    echo -e "\n${BLUE}Building and pushing all images...${NC}"
    make build-push
    echo -e "\n${GREEN}✓ Build and push complete!${NC}"
    ;;
  3)
    read -p "Enter tag to push (or press Enter for latest): " tag
    if [ -z "$tag" ]; then
      tag="latest"
    fi
    echo -e "\n${BLUE}Pushing images with tag: ${YELLOW}${tag}${NC}"
    make push TAG="${tag}"
    echo -e "\n${GREEN}✓ Push complete!${NC}"
    ;;
  4)
    echo ""
    make info
    ;;
  5)
    echo -e "\n${BLUE}Testing all images...${NC}"
    make test-all
    ;;
  *)
    echo -e "${RED}Invalid choice${NC}"
    exit 1
    ;;
esac

echo -e "\n${BLUE}────────────────────────────────────────${NC}"
echo -e "${GREEN}For more options, run: ${YELLOW}make help${NC}"
echo -e "${BLUE}────────────────────────────────────────${NC}"
