#!/usr/bin/env bash
set -euo pipefail

# Generate timestamp tag
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TAG="${1:-$TIMESTAMP}"

# Color output
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Building and pushing images with tag: ${YELLOW}${TAG}${NC}\n"

# Build and push
./scripts/podman-build.sh "${TAG}"
./scripts/podman-push.sh "${TAG}"

echo -e "\n${BLUE}Done! Images are now available in ECR.${NC}"
