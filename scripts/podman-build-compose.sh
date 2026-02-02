#!/usr/bin/env bash
set -euo pipefail

# Generate timestamp tag
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TAG="${1:-$TIMESTAMP}"

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Building images for linux/amd64 using podman-compose with tag: ${YELLOW}${TAG}${NC}"

# Export TAG for docker-compose
export TAG

# Build using podman-compose
podman-compose -f docker-compose.build.yml build

# Also tag as latest
ECR_REGISTRY="471112576951.dkr.ecr.ap-northeast-1.amazonaws.com"
ECR_REPOSITORY="weightwave/skill"

SKILLS=(
  "ascii-image-converter"
  "ffmpeg"
  "imagemagick"
)

echo -e "\n${YELLOW}Tagging images as latest...${NC}"
for SKILL in "${SKILLS[@]}"; do
  IMAGE_TAG="${ECR_REGISTRY}/${ECR_REPOSITORY}:${SKILL}-${TAG}"
  LATEST_TAG="${ECR_REGISTRY}/${ECR_REPOSITORY}:${SKILL}-latest"

  podman tag "${IMAGE_TAG}" "${LATEST_TAG}"
  echo -e "${GREEN}✓ Tagged ${SKILL} as latest${NC}"
done

echo -e "\n${BLUE}All images built successfully!${NC}"
echo -e "\nImages tagged with: ${YELLOW}${TAG}${NC} and ${YELLOW}latest${NC}"
echo -e "\nTo push images to ECR, run: ${GREEN}./scripts/podman-push.sh ${TAG}${NC}"
