#!/usr/bin/env bash
set -euo pipefail

# Configuration
ECR_REGISTRY="471112576951.dkr.ecr.ap-northeast-1.amazonaws.com"
ECR_REPOSITORY="weightwave/skill"
AWS_REGION="ap-northeast-1"

# Use provided tag or default to latest
TAG="${1:-latest}"

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Pushing Docker images to ECR with tag: ${YELLOW}${TAG}${NC}"

# Login to ECR
echo -e "${YELLOW}Logging in to ECR...${NC}"
aws ecr get-login-password --region ${AWS_REGION} | \
  podman login --username AWS --password-stdin ${ECR_REGISTRY}

# Skills to push
SKILLS=(
  "ascii-image-converter"
  "ffmpeg"
  "imagemagick"
)

# Push each skill
for SKILL in "${SKILLS[@]}"; do
  echo -e "\n${GREEN}Pushing ${SKILL}...${NC}"

  # Push timestamped version
  IMAGE_TAG="${ECR_REGISTRY}/${ECR_REPOSITORY}:${SKILL}-${TAG}"
  podman push "${IMAGE_TAG}"
  echo -e "${GREEN}✓ Pushed ${IMAGE_TAG}${NC}"

  # Also push latest if not already pushing latest
  if [ "${TAG}" != "latest" ]; then
    LATEST_TAG="${ECR_REGISTRY}/${ECR_REPOSITORY}:${SKILL}-latest"
    podman push "${LATEST_TAG}"
    echo -e "${GREEN}✓ Pushed ${LATEST_TAG}${NC}"
  fi
done

echo -e "\n${BLUE}All images pushed successfully!${NC}"
