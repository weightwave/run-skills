# 网络问题排查指南

## 🌐 常见网络问题

### 问题：Docker Hub 连接超时

**错误信息：**
```
Error: creating build container: unable to copy from source docker://golang:1.21-alpine:
initializing source docker://golang:1.21-alpine: pinging container registry
registry-1.docker.io: Get "https://registry-1.docker.io/v2/": dial tcp 69.63.176.59:443:
i/o timeout
```

**原因：** 在国内访问 Docker Hub (registry-1.docker.io) 可能会超时或速度很慢。

## 🚀 解决方案

### 方案 1：配置镜像加速器（推荐）

运行自动配置脚本：

```bash
./setup-mirrors.sh
```

这个脚本会自动：
1. 检测你的操作系统
2. 配置国内镜像源（中科大、网易等）
3. 重启 Podman machine（macOS）
4. 测试镜像拉取

**配置的镜像源：**
- 中科大镜像：`docker.mirrors.ustc.edu.cn`
- 网易镜像：`hub-mirror.c.163.com`
- Docker 中国：`registry.docker-cn.com`

### 方案 2：手动配置镜像加速器

#### macOS (Podman)

1. 找到你的 Podman machine 名称：
   ```bash
   podman machine list
   ```

2. SSH 到 Podman machine：
   ```bash
   podman machine ssh <machine-name>
   ```

3. 创建配置文件：
   ```bash
   sudo mkdir -p /etc/containers/registries.conf.d
   sudo vi /etc/containers/registries.conf.d/mirrors.conf
   ```

4. 添加以下内容：
   ```toml
   unqualified-search-registries = ["docker.io"]

   [[registry]]
   prefix = "docker.io"
   location = "docker.io"

   [[registry.mirror]]
   location = "docker.mirrors.ustc.edu.cn"
   insecure = false

   [[registry.mirror]]
   location = "hub-mirror.c.163.com"
   insecure = false
   ```

5. 退出并重启：
   ```bash
   exit
   podman machine stop
   podman machine start
   ```

#### Linux (Podman)

```bash
sudo mkdir -p /etc/containers/registries.conf.d
sudo vi /etc/containers/registries.conf.d/mirrors.conf
```

添加上述配置内容，然后重启 Podman 服务。

### 方案 3：使用代理

如果你有代理服务，可以配置 Podman 使用代理。

#### macOS (Podman)

编辑 Podman machine 配置：

```bash
podman machine ssh
sudo vi /etc/systemd/system/podman.service.d/http-proxy.conf
```

添加：
```ini
[Service]
Environment="HTTP_PROXY=http://your-proxy:port"
Environment="HTTPS_PROXY=http://your-proxy:port"
Environment="NO_PROXY=localhost,127.0.0.1"
```

重启：
```bash
sudo systemctl daemon-reload
sudo systemctl restart podman
```

### 方案 4：使用阿里云镜像加速（需要账号）

如果你有阿里云账号，可以使用个人专属加速地址：

1. 访问：https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors
2. 获取你的专属加速地址
3. 配置到 registries.conf：

```toml
[[registry.mirror]]
location = "your-id.mirror.aliyuncs.com"
insecure = false
```

## 🧪 测试配置

### 测试镜像拉取

```bash
# 清除缓存
podman system reset

# 测试拉取
podman pull docker.io/library/alpine:3.19

# 查看拉取日志
podman pull --log-level=debug docker.io/library/alpine:3.19
```

### 验证镜像源

```bash
# 查看配置
podman machine ssh cat /etc/containers/registries.conf.d/mirrors.conf

# 查看实际使用的镜像源（通过日志）
podman pull --log-level=debug alpine:3.19 2>&1 | grep "Trying to access"
```

## 📋 完整构建流程（配置镜像加速后）

```bash
# 1. 配置镜像加速器
./setup-mirrors.sh

# 2. 验证配置
podman pull alpine:3.19

# 3. 开始构建
make build

# 4. 如果还有问题，使用调试模式
podman build --log-level=debug \
  --platform=linux/amd64 \
  -t test \
  -f container/ffmpeg/Dockerfile \
  container/ffmpeg
```

## 🔍 诊断工具

### 检查网络连接

```bash
# 测试 Docker Hub 连接
curl -I https://registry-1.docker.io/v2/

# 测试中科大镜像
curl -I https://docker.mirrors.ustc.edu.cn/v2/

# 测试网易镜像
curl -I https://hub-mirror.c.163.com/v2/

# DNS 解析测试
nslookup registry-1.docker.io
```

### 查看 Podman 配置

```bash
# 查看所有注册表配置
podman machine ssh cat /etc/containers/registries.conf

# 查看镜像源配置
podman machine ssh cat /etc/containers/registries.conf.d/mirrors.conf

# 查看 Podman 信息
podman info
```

## 💡 其他建议

### 1. 预拉取基础镜像

在构建前先手动拉取基础镜像：

```bash
podman pull docker.io/library/golang:1.21-alpine
podman pull docker.io/library/alpine:3.19
```

### 2. 使用本地缓存

如果已经构建过一次，Podman 会使用缓存，速度会快很多。

### 3. 分阶段构建

可以先单独构建和测试一个镜像：

```bash
# 只构建 ffmpeg（不需要拉取 golang 镜像）
podman build \
  --platform=linux/amd64 \
  -t 471112576951.dkr.ecr.ap-northeast-1.amazonaws.com/weightwave/skill:ffmpeg-test \
  -f container/ffmpeg/Dockerfile \
  container/ffmpeg
```

### 4. 离线构建

如果网络实在不行，可以考虑：
- 在网络好的环境预先拉取镜像并导出
- 使用 `podman save` 和 `podman load` 传输镜像

## 🆘 仍然无法解决？

如果以上方案都不行，可以尝试：

1. **使用云服务器构建**
   - 在 AWS/阿里云等服务器上构建
   - 网络环境更稳定

2. **使用 GitHub Actions**
   - 配置 CI/CD 自动构建
   - GitHub 服务器网络通常没问题

3. **联系网络管理员**
   - 检查公司/学校防火墙设置
   - 申请开放 Docker Hub 访问

## 📚 相关文档

- [Podman 镜像配置文档](https://docs.podman.io/en/latest/markdown/podman-pull.1.html)
- [国内 Docker 镜像加速指南](https://yeasy.gitbook.io/docker_practice/install/mirror)
- [阿里云镜像加速](https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors)

---

**快速修复命令：**
```bash
./setup-mirrors.sh && make build
```
