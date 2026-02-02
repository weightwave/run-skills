.PHONY: help build push build-push clean login images info summary test-network setup-mirrors

# Configuration
TIMESTAMP := $(shell date +%Y%m%d-%H%M%S)
TAG ?= $(TIMESTAMP)

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

help: ## Show this help message
	@echo "$(BLUE)Run-Skills Podman Build Helper$(NC)"
	@echo ""
	@echo "$(YELLOW)Available targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Usage examples:$(NC)"
	@echo "  make build              # Build with timestamp tag"
	@echo "  make build TAG=v1.0.0   # Build with custom tag"
	@echo "  make build-push         # Build and push in one command"

build: ## Build all images with podman
	@echo "$(BLUE)Building images with tag: $(YELLOW)$(TAG)$(NC)"
	@./scripts/podman-build.sh $(TAG)

build-compose: ## Build all images using podman-compose
	@echo "$(BLUE)Building images with podman-compose, tag: $(YELLOW)$(TAG)$(NC)"
	@./scripts/podman-build-compose.sh $(TAG)

push: ## Push images to ECR
	@echo "$(BLUE)Pushing images with tag: $(YELLOW)$(TAG)$(NC)"
	@./scripts/podman-push.sh $(TAG)

build-push: ## Build and push in one command
	@echo "$(BLUE)Building and pushing images with tag: $(YELLOW)$(TAG)$(NC)"
	@./scripts/podman-build-and-push.sh $(TAG)

login: ## Login to ECR
	@echo "$(YELLOW)Logging in to ECR...$(NC)"
	@aws ecr get-login-password --region ap-northeast-1 | \
		podman login --username AWS --password-stdin \
		471112576951.dkr.ecr.ap-northeast-1.amazonaws.com

images: ## List built images
	@echo "$(BLUE)Local images:$(NC)"
	@podman images | grep -E "weightwave/skill|REPOSITORY" || echo "No images found"

clean: ## Remove all local images
	@echo "$(YELLOW)Removing all weightwave/skill images...$(NC)"
	@podman rmi $$(podman images | grep weightwave/skill | awk '{print $$3}') 2>/dev/null || echo "No images to remove"

verify: ## Verify images can run
	@echo "$(BLUE)Verifying ascii-image-converter...$(NC)"
	@podman run --rm \
		-e CALLBACK_URL=http://localhost:3000/callback \
		-e INTERNAL_SECRET=test \
		-e COMMAND=/usr/local/bin/ascii-image-converter \
		-e USER_ID=test \
		471112576951.dkr.ecr.ap-northeast-1.amazonaws.com/weightwave/skill:ascii-image-converter-latest \
		--version || echo "Image test failed"

dev: ## Start development server
	@pnpm run dev

test-local: ## Test with local docker-compose
	@echo "$(BLUE)Testing with docker-compose...$(NC)"
	@TAG=$(TAG) podman-compose -f docker-compose.build.yml build
	@echo "$(GREEN)Build complete!$(NC)"

info: ## Show build configuration info
	@echo "$(BLUE)Build Configuration$(NC)"
	@echo "  Platform:  linux/amd64"
	@echo "  Registry:  471112576951.dkr.ecr.ap-northeast-1.amazonaws.com"
	@echo "  Repo:      weightwave/skill"
	@echo "  Region:    ap-northeast-1"
	@echo "  Tag:       $(YELLOW)$(TAG)$(NC)"
	@echo ""
	@echo "$(BLUE)Available Skills:$(NC)"
	@echo "  - ascii-image-converter"
	@echo "  - ffmpeg"
	@echo "  - imagemagick"

summary: ## Show BUILD_SUMMARY.md
	@cat BUILD_SUMMARY.md

test-all: ## Run all image tests
	@echo "$(BLUE)Running all image tests...$(NC)"
	@./examples/test-images.sh

test-network: ## Test network connectivity to Docker Hub and mirrors
	@./test-network.sh

setup-mirrors: ## Configure registry mirrors for China network
	@echo "$(YELLOW)Setting up registry mirrors...$(NC)"
	@./setup-mirrors.sh

fix-network: ## Quick fix for network issues (setup mirrors + test)
	@echo "$(BLUE)Fixing network issues...$(NC)"
	@./setup-mirrors.sh
	@echo ""
	@./test-network.sh
