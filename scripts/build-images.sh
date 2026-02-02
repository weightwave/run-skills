#!/usr/bin/env bash
set -euo pipefail

# Configuration
ECR_REGISTRY="471112576951.dkr.ecr.ap-northeast-1.amazonaws.com"
ECR_REPOSITORY="weightwave/skill"
AWS_REGION="ap-northeast-1"

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Building Docker images for linux/amd64...${NC}"

# Skills to build
SKILLS=(
  "ascii-image-converter"
  "ffmpeg"
  "imagemagick"
)

# Build each skill
for SKILL in "${SKILLS[@]}"; do
  echo -e "\n${GREEN}Building ${SKILL}...${NC}"

  IMAGE_TAG="${ECR_REGISTRY}/${ECR_REPOSITORY}:${SKILL}-latest"

  docker build \
    --platform=linux/amd64 \
    -t "${IMAGE_TAG}" \
    -f "container/${SKILL}/Dockerfile" \
    "container/${SKILL}"

  echo -e "${GREEN}✓ Built ${IMAGE_TAG}${NC}"
done

echo -e "\n${BLUE}All images built successfully!${NC}"
echo -e "\nTo push images to ECR, run: ${GREEN}./scripts/push-images.sh${NC}"
