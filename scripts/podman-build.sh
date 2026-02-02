#!/usr/bin/env bash
set -euo pipefail

# Configuration
ECR_REGISTRY="471112576951.dkr.ecr.ap-northeast-1.amazonaws.com"
ECR_REPOSITORY="weightwave/skill"
AWS_REGION="ap-northeast-1"

# Generate timestamp tag
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TAG="${1:-$TIMESTAMP}"

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Building Docker images for linux/amd64 with tag: ${YELLOW}${TAG}${NC}"

# Skills to build
SKILLS=(
  "ascii-image-converter"
  "ffmpeg"
  "imagemagick"
)

# Build each skill using podman
for SKILL in "${SKILLS[@]}"; do
  echo -e "\n${GREEN}Building ${SKILL}...${NC}"

  IMAGE_TAG="${ECR_REGISTRY}/${ECR_REPOSITORY}:${SKILL}-${TAG}"
  LATEST_TAG="${ECR_REGISTRY}/${ECR_REPOSITORY}:${SKILL}-latest"

  podman build \
    --platform=linux/amd64 \
    -t "${IMAGE_TAG}" \
    -t "${LATEST_TAG}" \
    -f "container/${SKILL}/Dockerfile" \
    "container/${SKILL}"

  echo -e "${GREEN}✓ Built ${IMAGE_TAG}${NC}"
  echo -e "${GREEN}✓ Tagged ${LATEST_TAG}${NC}"
done

echo -e "\n${BLUE}All images built successfully!${NC}"
echo -e "\nImages tagged with: ${YELLOW}${TAG}${NC} and ${YELLOW}latest${NC}"
echo -e "\nTo push images to ECR, run: ${GREEN}./scripts/podman-push.sh ${TAG}${NC}"
