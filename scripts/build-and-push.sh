#!/usr/bin/env bash
set -euo pipefail

# Build and push in one go
./scripts/build-images.sh
./scripts/push-images.sh
