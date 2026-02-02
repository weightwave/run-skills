# 快速参考

## ⚠️ 首次使用？遇到网络问题？

如果构建时遇到 Docker Hub 连接超时：

```bash
# 一键配置镜像加速器
./setup-mirrors.sh

# 然后开始构建
make build
```

详细说明请查看 [NETWORK_TROUBLESHOOTING.md](NETWORK_TROUBLESHOOTING.md)

## 🚀 最常用命令

```bash
# 构建所有镜像（自动时间戳）
make build

# 构建并推送到 ECR
make build-push

# 查看构建的镜像
make images

# 查看所有可用命令
make help
```

## 📦 构建命令对照表

| 需求 | Makefile | 直接脚本 |
|------|----------|----------|
| 构建所有镜像 | `make build` | `./scripts/podman-build.sh` |
| 使用 compose 构建 | `make build-compose` | `./scripts/podman-build-compose.sh` |
| 推送到 ECR | `make push TAG=xxx` | `./scripts/podman-push.sh xxx` |
| 构建+推送 | `make build-push` | `./scripts/podman-build-and-push.sh` |
| 查看镜像 | `make images` | `podman images \| grep weightwave` |
| 清理镜像 | `make clean` | `podman rmi ...` |

## 🏷️ Tag 使用

```bash
# 默认：时间戳 (20260130-143022)
make build

# 自定义 tag
make build TAG=v1.0.0

# 多个 tag
./scripts/podman-build.sh production
./scripts/podman-build.sh v2.0.0
```

## 🎯 单个镜像操作

```bash
# 构建单个镜像
podman build \
  -t 471112576951.dkr.ecr.ap-northeast-1.amazonaws.com/weightwave/skill:ffmpeg-$(date +%Y%m%d-%H%M%S) \
  -f container/ffmpeg/Dockerfile \
  container/ffmpeg

# 推送单个镜像
podman push 471112576951.dkr.ecr.ap-northeast-1.amazonaws.com/weightwave/skill:ffmpeg-20260130-143022
```

## 🔐 ECR 登录

```bash
# 使用 Makefile
make login

# 手动登录
aws ecr get-login-password --region ap-northeast-1 | \
  podman login --username AWS --password-stdin \
  471112576951.dkr.ecr.ap-northeast-1.amazonaws.com
```

## 🧪 测试镜像

```bash
# 验证镜像可运行
make verify

# 手动测试
podman run --rm \
  -e CALLBACK_URL=http://localhost:3000/callback \
  -e INTERNAL_SECRET=test \
  -e COMMAND=/usr/bin/ffmpeg \
  -e USER_ID=test \
  471112576951.dkr.ecr.ap-northeast-1.amazonaws.com/weightwave/skill:ffmpeg-latest \
  -version
```

## 📊 常见工作流

### 开发流程

```bash
# 1. 开发代码
pnpm run dev

# 2. 修改 Dockerfile
vim container/ffmpeg/Dockerfile

# 3. 本地构建测试
make build

# 4. 验证镜像
make verify

# 5. 推送到 ECR
make push TAG=$(date +%Y%m%d-%H%M%S)
```

### 生产发布流程

```bash
# 1. 构建生产镜像
make build TAG=prod-$(date +%Y%m%d-%H%M%S)

# 2. 测试镜像
make verify

# 3. 推送到 ECR
make push TAG=prod-$(date +%Y%m%d-%H%M%S)

# 4. 更新 registry.ts 中的镜像 tag（如果需要）
```

## 🗂️ 镜像命名规范

```
格式: {registry}/{repository}:{skill}-{tag}

示例:
471112576951.dkr.ecr.ap-northeast-1.amazonaws.com/weightwave/skill:ascii-image-converter-20260130-143022
471112576951.dkr.ecr.ap-northeast-1.amazonaws.com/weightwave/skill:ffmpeg-latest
471112576951.dkr.ecr.ap-northeast-1.amazonaws.com/weightwave/skill:imagemagick-v1.0.0
```

## 🔧 故障排查

```bash
# 检查 podman 状态
podman info

# 启动 podman machine
podman machine start

# 检查 AWS 凭证
aws sts get-caller-identity

# 查看容器日志
podman logs <container-id>

# 进入容器调试
podman run -it --entrypoint /bin/bash <image-name>
```

## 📝 环境变量

容器运行时需要的环境变量：

```bash
CALLBACK_URL      # 回调 API 地址
INTERNAL_SECRET   # 内部认证密钥
COMMAND           # 要执行的命令（Dockerfile 中设置）
ARGS              # 命令参数（null-byte 分隔）
USER_ID           # 用户 ID
```

## 🌐 资源链接

- ECR 仓库: https://console.aws.amazon.com/ecr/repositories
- API 文档: http://localhost:3000/scalar
- Podman 文档: https://podman.io/
