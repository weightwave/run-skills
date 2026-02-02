# Podman 构建指南

本项目支持使用 Podman 构建和推送容器镜像，镜像会自动使用时间戳作为 tag。

## ⚠️ 重要：跨平台构建

**所有镜像都会构建为 `linux/amd64` 平台**，以确保在云端（AWS/Fly.io）正确运行。

- 如果你在 Mac（ARM64）上构建，Podman 会自动处理跨平台编译
- 所有构建脚本都已配置 `--platform=linux/amd64`
- docker-compose.build.yml 也已指定平台为 `linux/amd64`

这确保了即使在 Apple Silicon (M1/M2/M3) Mac 上构建，镜像也能在 x86_64 服务器上运行。

## 前置要求

```bash
# 安装 podman
brew install podman

# 安装 podman-compose（可选，用于 compose 方式构建）
pip install podman-compose

# 配置 AWS CLI
aws configure
```

## 快速开始

### 方式一：使用 podman-compose（推荐）

```bash
# 使用时间戳自动构建所有镜像
./scripts/podman-build-compose.sh

# 或指定自定义 tag
./scripts/podman-build-compose.sh v1.0.0
```

### 方式二：使用原生脚本

```bash
# 使用时间戳自动构建
./scripts/podman-build.sh

# 或指定自定义 tag
./scripts/podman-build.sh v1.0.0
```

## 构建 + 推送

### 一键构建并推送

```bash
# 使用时间戳
./scripts/podman-build-and-push.sh

# 或指定 tag
./scripts/podman-build-and-push.sh v1.0.0
```

### 分步执行

```bash
# 1. 构建镜像
./scripts/podman-build.sh

# 2. 推送到 ECR
./scripts/podman-push.sh 20260130-143022
```

## 镜像 Tag 策略

每次构建会生成两个 tag：

1. **时间戳 tag**（主要）: `{skill}-{timestamp}`
   - 例如: `ascii-image-converter-20260130-143022`
   - 格式: `YYYYMMDD-HHMMSS`

2. **latest tag**（备用）: `{skill}-latest`
   - 例如: `ascii-image-converter-latest`

### 示例

```bash
# 构建时会生成:
# - 471112576951.dkr.ecr.ap-northeast-1.amazonaws.com/weightwave/skill:ascii-image-converter-20260130-143022
# - 471112576951.dkr.ecr.ap-northeast-1.amazonaws.com/weightwave/skill:ascii-image-converter-latest
```

## 可用脚本

| 脚本 | 说明 | 用法 |
|------|------|------|
| `podman-build-compose.sh` | 使用 podman-compose 构建 | `./scripts/podman-build-compose.sh [tag]` |
| `podman-build.sh` | 使用原生 podman 构建 | `./scripts/podman-build.sh [tag]` |
| `podman-push.sh` | 推送镜像到 ECR | `./scripts/podman-push.sh [tag]` |
| `podman-build-and-push.sh` | 一键构建并推送 | `./scripts/podman-build-and-push.sh [tag]` |

## 手动构建单个镜像

```bash
# 设置变量
TAG=$(date +%Y%m%d-%H%M%S)
ECR_REGISTRY="471112576951.dkr.ecr.ap-northeast-1.amazonaws.com"
SKILL="ascii-image-converter"

# 构建
podman build \
  -t "${ECR_REGISTRY}/weightwave/skill:${SKILL}-${TAG}" \
  -t "${ECR_REGISTRY}/weightwave/skill:${SKILL}-latest" \
  -f "container/${SKILL}/Dockerfile" \
  "container/${SKILL}"

# 推送
podman push "${ECR_REGISTRY}/weightwave/skill:${SKILL}-${TAG}"
podman push "${ECR_REGISTRY}/weightwave/skill:${SKILL}-latest"
```

## 使用 docker-compose.build.yml

如果你想使用 podman-compose 并自定义配置：

```bash
# 设置 tag 环境变量
export TAG=$(date +%Y%m%d-%H%M%S)

# 构建所有服务
podman-compose -f docker-compose.build.yml build

# 构建特定服务
podman-compose -f docker-compose.build.yml build ffmpeg

# 查看构建的镜像
podman images | grep weightwave/skill
```

## ECR 登录

脚本会自动处理 ECR 登录，但你也可以手动登录：

```bash
aws ecr get-login-password --region ap-northeast-1 | \
  podman login --username AWS --password-stdin \
  471112576951.dkr.ecr.ap-northeast-1.amazonaws.com
```

## 验证镜像

```bash
# 查看本地镜像
podman images | grep weightwave/skill

# 测试运行
podman run --rm \
  -e CALLBACK_URL=http://localhost:3000/callback \
  -e INTERNAL_SECRET=test \
  -e COMMAND=/usr/local/bin/ascii-image-converter \
  -e ARGS="" \
  -e USER_ID=test \
  471112576951.dkr.ecr.ap-northeast-1.amazonaws.com/weightwave/skill:ascii-image-converter-latest \
  --version
```

## 清理镜像

```bash
# 删除所有本地镜像
podman rmi $(podman images | grep weightwave/skill | awk '{print $3}')

# 或使用 prune
podman image prune -a
```

## 故障排查

### Podman Machine 未启动

```bash
podman machine init
podman machine start
```

### 权限问题

```bash
# 确保脚本有执行权限
chmod +x scripts/podman-*.sh
```

### AWS 凭证问题

```bash
# 检查 AWS 配置
aws configure list
aws sts get-caller-identity

# 检查 ECR 访问权限
aws ecr describe-repositories --region ap-northeast-1
```

## 与 Docker 的区别

- `docker` → `podman` (命令完全兼容)
- `docker-compose` → `podman-compose`
- Podman 无需 daemon，更加轻量
- 镜像存储位置不同，但使用方式相同
