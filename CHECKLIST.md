# 部署检查清单

在部署到生产环境之前，请确保完成以下检查项。

## 📋 构建前检查

- [ ] Podman 已安装并运行
  ```bash
  podman version
  podman machine list
  ```

- [ ] AWS CLI 已配置
  ```bash
  aws configure list
  aws sts get-caller-identity
  ```

- [ ] 有 ECR 仓库的访问权限
  ```bash
  aws ecr describe-repositories --region ap-northeast-1 --repository-names weightwave/skill
  ```

## 🔨 构建检查

- [ ] 所有 Dockerfile 都指定了正确的平台 (linux/amd64)
- [ ] wrapper.sh 已复制到每个 skill 目录
- [ ] 构建脚本有执行权限
  ```bash
  ls -la scripts/*.sh
  ```

- [ ] 测试本地构建
  ```bash
  make build
  ```

- [ ] 查看构建的镜像
  ```bash
  make images
  ```

## 🧪 测试检查

- [ ] 运行镜像测试
  ```bash
  make test-all
  # 或
  ./examples/test-images.sh
  ```

- [ ] 验证每个 skill 的版本命令
  ```bash
  # ascii-image-converter
  podman run --rm \
    471112576951.dkr.ecr.ap-northeast-1.amazonaws.com/weightwave/skill:ascii-image-converter-latest \
    --version

  # ffmpeg
  podman run --rm \
    471112576951.dkr.ecr.ap-northeast-1.amazonaws.com/weightwave/skill:ffmpeg-latest \
    -version

  # imagemagick
  podman run --rm \
    471112576951.dkr.ecr.ap-northeast-1.amazonaws.com/weightwave/skill:imagemagick-latest \
    -version
  ```

- [ ] 检查镜像大小是否合理
  ```bash
  podman images | grep weightwave/skill
  ```

## 🚀 推送检查

- [ ] ECR 登录成功
  ```bash
  make login
  ```

- [ ] 推送镜像到 ECR
  ```bash
  make push TAG=$(date +%Y%m%d-%H%M%S)
  ```

- [ ] 验证 ECR 中的镜像
  ```bash
  aws ecr list-images \
    --region ap-northeast-1 \
    --repository-name weightwave/skill \
    --output table
  ```

## 📝 配置检查

- [ ] [src/services/registry.ts](src/services/registry.ts) 中的镜像地址正确
- [ ] 镜像 tag 与实际推送的 tag 一致
- [ ] 环境变量配置正确
  - `FLY_API_TOKEN`
  - `INTERNAL_SECRET`
  - 其他必需的环境变量

## 🔍 运行时检查

- [ ] API 服务正常启动
  ```bash
  pnpm run dev
  ```

- [ ] 健康检查端点正常
  ```bash
  curl http://localhost:3000/health
  ```

- [ ] API 文档可访问
  ```bash
  open http://localhost:3000/scalar
  ```

- [ ] 测试一个简单的 skill 执行
  ```bash
  # 使用 API 测试工具或 curl 测试
  ```

## 🌐 生产部署检查

- [ ] 生产环境的 ECR 访问权限配置
- [ ] Fly.io 或其他云平台的镜像拉取权限
- [ ] 网络策略允许访问 ECR
- [ ] 监控和日志配置完成
- [ ] 备份和回滚计划就绪

## 📊 性能检查

- [ ] 镜像拉取时间可接受 (< 30秒)
- [ ] 容器启动时间可接受 (< 5秒)
- [ ] 第一次执行时间可接受
- [ ] 后续执行利用缓存加速

## 🔐 安全检查

- [ ] wrapper.sh 没有硬编码的敏感信息
- [ ] INTERNAL_SECRET 足够强
- [ ] ECR 仓库访问控制配置正确
- [ ] 容器以非 root 用户运行（如果需要）

## 📚 文档检查

- [ ] README.md 更新完整
- [ ] PODMAN_GUIDE.md 准确
- [ ] BUILD_SUMMARY.md 反映当前状态
- [ ] API 文档与实际 API 一致

## ✅ 最终验证

- [ ] 在本地完整测试一次完整流程
- [ ] 在测试环境验证部署
- [ ] 代码审查完成
- [ ] 所有测试通过
- [ ] 准备好回滚方案

---

## 快速命令

```bash
# 完整流程（开发环境）
make build          # 构建
make test-all       # 测试
make images         # 查看镜像

# 生产部署
make login          # 登录 ECR
make build-push     # 构建并推送
make info           # 查看配置信息

# 验证部署
aws ecr list-images --repository-name weightwave/skill --region ap-northeast-1
```

## 问题排查

如果遇到问题，请参考：
- [PODMAN_GUIDE.md](PODMAN_GUIDE.md) - Podman 相关问题
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - 常见命令
- [container/README.md](container/README.md) - 容器配置问题

---

**完成所有检查项后，你就可以安全地部署到生产环境了！** 🎉
