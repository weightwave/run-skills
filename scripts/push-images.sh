#!/usr/bin/env bash
set -euo pipefail

# Configuration
ECR_REGISTRY="471112576951.dkr.ecr.ap-northeast-1.amazonaws.com"
ECR_REPOSITORY="weightwave/skill"
AWS_REGION="ap-northeast-1"

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Pushing Docker images to ECR...${NC}"

# Login to ECR
echo -e "${YELLOW}Logging in to ECR...${NC}"
aws ecr get-login-password --region ${AWS_REGION} | \
  docker login --username AWS --password-stdin ${ECR_REGISTRY}

# Skills to push
SKILLS=(
  "ascii-image-converter"
  "ffmpeg"
  "imagemagick"
)

# Push each skill
for SKILL in "${SKILLS[@]}"; do
  echo -e "\n${GREEN}Pushing ${SKILL}...${NC}"

  IMAGE_TAG="${ECR_REGISTRY}/${ECR_REPOSITORY}:${SKILL}-latest"

  docker push "${IMAGE_TAG}"

  echo -e "${GREEN}✓ Pushed ${IMAGE_TAG}${NC}"
done

echo -e "\n${BLUE}All images pushed successfully!${NC}"
