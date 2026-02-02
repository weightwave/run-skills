# 构建配置总结

## 📦 已创建的文件

### Docker 配置
- [container/ascii-image-converter/Dockerfile](container/ascii-image-converter/Dockerfile)
- [container/ascii-image-converter/wrapper.sh](container/ascii-image-converter/wrapper.sh)
- [container/ffmpeg/Dockerfile](container/ffmpeg/Dockerfile)
- [container/ffmpeg/wrapper.sh](container/ffmpeg/wrapper.sh)
- [container/imagemagick/Dockerfile](container/imagemagick/Dockerfile)
- [container/imagemagick/wrapper.sh](container/imagemagick/wrapper.sh)
- [docker-compose.yml](docker-compose.yml) - 运行时配置
- [docker-compose.build.yml](docker-compose.build.yml) - 构建配置（支持 podman-compose）

### Podman 构建脚本
- [scripts/podman-build.sh](scripts/podman-build.sh) - 使用 podman 构建所有镜像
- [scripts/podman-build-compose.sh](scripts/podman-build-compose.sh) - 使用 podman-compose 构建
- [scripts/podman-push.sh](scripts/podman-push.sh) - 推送镜像到 ECR
- [scripts/podman-build-and-push.sh](scripts/podman-build-and-push.sh) - 一键构建并推送

### Docker 构建脚本
- [scripts/build-images.sh](scripts/build-images.sh) - 使用 docker 构建
- [scripts/push-images.sh](scripts/push-images.sh) - 使用 docker 推送
- [scripts/build-and-push.sh](scripts/build-and-push.sh) - docker 一键构建推送

### 工具和文档
- [Makefile](Makefile) - 便捷的构建命令
- [PODMAN_GUIDE.md](PODMAN_GUIDE.md) - Podman 详细使用指南
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - 快速命令参考
- [container/README.md](container/README.md) - 容器配置说明
- [examples/test-images.sh](examples/test-images.sh) - 镜像测试脚本
- [.dockerignore](.dockerignore) - Docker 忽略文件

## 🔧 已修改的文件

- [src/services/registry.ts](src/services/registry.ts) - 更新为 ECR 镜像地址
- [README.md](README.md) - 添加构建文档链接
- [.gitignore](.gitignore) - 添加构建产物忽略

## 🎯 镜像配置

### ECR 仓库信息
- **Registry**: `471112576951.dkr.ecr.ap-northeast-1.amazonaws.com`
- **Repository**: `weightwave/skill`
- **Region**: `ap-northeast-1`

### 镜像 Tags
每个 skill 有两个 tag：
1. **时间戳 tag**: `{skill}-YYYYMMDD-HHMMSS`
2. **Latest tag**: `{skill}-latest`

### 平台
所有镜像都构建为 **linux/amd64** 平台，确保在云端正确运行。

## 🚀 快速开始

### 使用 Makefile（推荐）

```bash
# 查看所有命令
make help

# 构建所有镜像
make build

# 构建并推送
make build-push

# 自定义 tag
make build TAG=v1.0.0
```

### 使用 Podman 脚本

```bash
# 构建（自动时间戳）
./scripts/podman-build.sh

# 构建（自定义 tag）
./scripts/podman-build.sh v1.0.0

# 推送
./scripts/podman-push.sh v1.0.0

# 一键构建并推送
./scripts/podman-build-and-push.sh
```

### 使用 Docker 脚本

```bash
# 构建
./scripts/build-images.sh

# 推送
./scripts/push-images.sh

# 一键构建并推送
./scripts/build-and-push.sh
```

## 📋 构建流程

### 标准发布流程

1. **构建镜像**
   ```bash
   make build
   # 或
   ./scripts/podman-build.sh
   ```

2. **测试镜像**
   ```bash
   ./examples/test-images.sh
   # 或
   make verify
   ```

3. **推送到 ECR**
   ```bash
   make push TAG=20260130-143022
   # 或
   ./scripts/podman-push.sh 20260130-143022
   ```

### 快速发布流程

```bash
# 一条命令完成构建、测试、推送
make build-push
```

## 🔍 验证构建

### 查看本地镜像

```bash
make images
# 或
podman images | grep weightwave/skill
```

### 测试镜像

```bash
# 测试所有镜像
./examples/test-images.sh

# 测试特定镜像
podman run --rm \
  471112576951.dkr.ecr.ap-northeast-1.amazonaws.com/weightwave/skill:ffmpeg-latest \
  -version
```

## 📚 详细文档

- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - 常用命令速查表
- [PODMAN_GUIDE.md](PODMAN_GUIDE.md) - Podman 完整使用指南
- [container/README.md](container/README.md) - 容器技术细节

## 🛠️ 技术栈

- **容器引擎**: Podman / Docker
- **基础镜像**: Alpine Linux 3.19
- **平台**: linux/amd64
- **仓库**: AWS ECR
- **工具**:
  - ascii-image-converter (Go)
  - ffmpeg
  - imagemagick

## ⚙️ 环境要求

### 本地开发
- Podman 或 Docker
- AWS CLI（用于推送到 ECR）
- Bash 4.0+

### 云端运行
- 支持 linux/amd64 的容器运行时
- 访问 AWS ECR 的权限
- Fly.io Machines API（或其他容器编排平台）

## 🔐 认证

### ECR 登录

```bash
# 使用 Makefile
make login

# 手动登录
aws ecr get-login-password --region ap-northeast-1 | \
  podman login --username AWS --password-stdin \
  471112576951.dkr.ecr.ap-northeast-1.amazonaws.com
```

## 📊 镜像大小预估

- ascii-image-converter: ~50MB
- ffmpeg: ~100MB
- imagemagick: ~80MB

所有镜像都基于 Alpine Linux，保持轻量化。

## 🐛 故障排查

### Podman Machine 未启动
```bash
podman machine init
podman machine start
```

### 跨平台构建慢
这是正常的，因为需要模拟 x86_64 架构。首次构建会较慢，后续会有缓存加速。

### AWS 凭证问题
```bash
aws configure
aws sts get-caller-identity
```

## 📝 下一步

1. 构建镜像: `make build`
2. 测试镜像: `make verify`
3. 推送到 ECR: `make push TAG=$(date +%Y%m%d-%H%M%S)`
4. 更新应用配置使用新镜像
5. 部署应用

---

Created: 2026-01-30
Platform: linux/amd64
Registry: AWS ECR ap-northeast-1
