# Run-Skills

API for executing skills via ephemeral containers with real-time output streaming.

## Quick Start

```bash
npm install
npm run dev
```

```bash
open http://localhost:3000
```

## Building Container Images

### Interactive Quick Start

```bash
./quick-start.sh
```

这个脚本会引导你完成构建和部署流程。

### Using Podman (Recommended)

详细文档请查看 [PODMAN_GUIDE.md](PODMAN_GUIDE.md)

**⚠️ 国内网络问题？** 如果遇到镜像拉取超时，先运行：
```bash
./setup-mirrors.sh
```

然后开始构建：

```bash
# 快速构建（自动使用时间戳）
make build

# 构建并推送到 ECR
make build-push

# 自定义 tag
make build TAG=v1.0.0

# 查看所有可用命令
make help
```

### Using Docker

```bash
./scripts/build-images.sh
./scripts/push-images.sh
```

## Available Skills

- `ascii-image-converter` - Convert images to ASCII art
- `ffmpeg` - Media processing and conversion
- `imagemagick` - Image manipulation and conversion

## Documentation

- [Quick Reference](QUICK_REFERENCE.md) - 🚀 常用命令速查
- [Network Troubleshooting](NETWORK_TROUBLESHOOTING.md) - 🌐 网络问题排查（Docker Hub 超时等）
- [Build Summary](BUILD_SUMMARY.md) - 📦 构建配置总结
- [Deployment Checklist](CHECKLIST.md) - ✅ 部署前检查清单
- [Podman Build Guide](PODMAN_GUIDE.md) - 使用 Podman 构建镜像
- [Container README](container/README.md) - 容器配置详细说明
- [Agent Instructions](agent.md) - Agent 使用说明

## API Documentation

Visit `http://localhost:3000/scalar` for interactive API documentation.
