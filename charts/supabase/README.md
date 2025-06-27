# Supabase Helm Chart

这是一个用于在 Kubernetes 上部署 Supabase 的 Helm chart。该 chart 将 Supabase 的所有组件拆分为独立的服务，支持 MinIO/S3 存储后端。

## 组件架构

该 Helm chart 包含以下 Supabase 组件：

### 核心服务
- **Studio** - Supabase 管理界面
- **Kong** - API 网关
- **Auth** - 认证服务 (GoTrue)
- **Rest** - REST API 服务 (PostgREST)
- **Realtime** - 实时数据服务
- **Storage** - 文件存储服务
- **Imgproxy** - 图片处理服务
- **Meta** - 数据库元数据服务
- **Functions** - Edge Functions 服务

### 数据和分析服务
- **Analytics** - 日志和分析服务
- **Database** - PostgreSQL 数据库
- **Pooler** - 连接池服务 (Supavisor)

## 存储支持

### 文件存储 (默认)
- 使用 Kubernetes PersistentVolumeClaim
- 支持本地存储和网络存储

### S3 兼容存储
- 支持 AWS S3、MinIO 等 S3 兼容存储
- 通过 `storage.backend: "s3"` 启用
- 配置 S3 连接参数

## 快速开始

### 1. 安装依赖

确保你的 Kubernetes 集群已安装：
- Helm 3.x
- 支持 PersistentVolumeClaim 的存储类

### 2. 配置 secrets

创建自定义 values 文件 `my-values.yaml`：

```yaml
secrets:
  postgresPassword: "your-secure-postgres-password"
  jwtSecret: "your-super-secret-jwt-token-with-at-least-32-characters-long"
  anonKey: "your-anon-key"
  serviceRoleKey: "your-service-role-key"
  dashboardUsername: "supabase"
  dashboardPassword: "your-dashboard-password"
  secretKeyBase: "your-secret-key-base"
  vaultEncKey: "your-vault-encryption-key"
  logflarePublicAccessToken: "your-logflare-public-access-token"
  logflarePrivateAccessToken: "your-logflare-private-access-token"
```

### 3. 安装 chart

```bash
helm install supabase ./charts/supabase -f my-values.yaml
```

### 4. 访问服务

安装完成后，你可以通过以下方式访问：

- **Studio**: 通过 Kong 网关访问
- **API**: 通过 Kong 网关访问
- **Database**: 通过 Pooler 服务访问

## S3/MinIO 存储配置

### 使用 MinIO

如果你想要使用 MinIO 作为 S3 兼容存储，需要先部署 MinIO：

#### 方法 1: 使用官方 MinIO Helm Chart

```bash
# 添加 MinIO Helm 仓库
helm repo add minio https://charts.min.io/
helm repo update

# 安装 MinIO
helm install minio minio/minio \
  --set auth.rootUser=minioadmin \
  --set auth.rootPassword=minioadmin \
  --set persistence.size=10Gi
```

#### 方法 2: 使用 Docker Compose (开发环境)

```bash
# 创建 docker-compose.minio.yml
cat << EOF > docker-compose.minio.yml
version: '3.8'
services:
  minio:
    image: minio/minio
    ports:
      - '9000:9000'
      - '9001:9001'
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    command: server --console-address ":9001" /data
    volumes:
      - minio_data:/data

volumes:
  minio_data:
EOF

# 启动 MinIO
docker-compose -f docker-compose.minio.yml up -d
```

### 配置 Supabase 使用 S3 存储

创建 `my-values-s3.yaml`：

```yaml
# 基础 secrets 配置
secrets:
  postgresPassword: "your-secure-postgres-password"
  jwtSecret: "your-super-secret-jwt-token-with-at-least-32-characters-long"
  anonKey: "your-anon-key"
  serviceRoleKey: "your-service-role-key"
  dashboardUsername: "supabase"
  dashboardPassword: "your-dashboard-password"
  secretKeyBase: "your-secret-key-base"
  vaultEncKey: "your-vault-encryption-key"
  logflarePublicAccessToken: "your-logflare-public-access-token"
  logflarePrivateAccessToken: "your-logflare-private-access-token"
  # S3/MinIO 存储密钥
  s3AccessKey: "minioadmin"
  s3SecretKey: "minioadmin"

# S3 存储配置
storage:
  backend: "s3"
  persistence:
    enabled: false  # 使用 S3 时不需要本地持久化
  s3:
    bucket: "supabase-storage"
    region: "us-east-1"
    endpoint: "http://minio:9000"  # MinIO 服务地址
    protocol: "http"  # MinIO 使用 http，AWS S3 使用 https
    forcePathStyle: true  # MinIO 需要设置为 true
    defaultRegion: "us-east-1"
```

### 安装带 S3 存储的 Supabase

```bash
helm install supabase ./charts/supabase -f my-values-s3.yaml
```

## 配置选项

### 全局配置

```yaml
global:
  imageRegistry: ""  # 自定义镜像仓库
  imagePullSecrets: []  # 镜像拉取密钥
  storageClass: ""  # 默认存储类
```

### 数据库配置

```yaml
database:
  persistence:
    enabled: true
    size: 20Gi
    storageClass: "fast-ssd"
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
    limits:
      memory: "2Gi"
      cpu: "1000m"
```

### 存储配置

```yaml
storage:
  backend: "file"  # "file" 或 "s3"
  persistence:
    enabled: true
    size: 10Gi
  s3:
    bucket: "supabase-storage"
    region: "us-east-1"
    endpoint: ""  # MinIO 端点
    protocol: "https"  # "http" 或 "https"
    forcePathStyle: true  # MinIO 需要设置为 true
    accessKey: ""
    secretKey: ""
    defaultRegion: "us-east-1"
```

### 服务配置

每个服务都支持以下配置：

```yaml
serviceName:
  replicaCount: 1
  image:
    repository: "image-repo"
    tag: "image-tag"
    pullPolicy: IfNotPresent
  resources:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  # 健康检查配置
  livenessProbe:
    httpGet:
      path: /health
      port: http
    initialDelaySeconds: 30
    periodSeconds: 10
  readinessProbe:
    httpGet:
      path: /health
      port: http
    initialDelaySeconds: 5
    periodSeconds: 5
```

### 镜像配置

所有组件的镜像都可以通过 values 文件自定义：

```yaml
# 全局镜像仓库配置
global:
  imageRegistry: "your-registry.com"
  imagePullSecrets:
    - name: "your-pull-secret"

# 各组件镜像配置
studio:
  image:
    repository: supabase/studio
    tag: "2025.06.02-sha-8f2993d"
    pullPolicy: IfNotPresent

kong:
  image:
    repository: kong
    tag: "2.8.1"
    pullPolicy: IfNotPresent

auth:
  image:
    repository: supabase/gotrue
    tag: "v2.174.0"
    pullPolicy: IfNotPresent

# ... 其他组件类似
```

#### 镜像拉取策略

- `IfNotPresent`: 默认值，如果本地存在镜像则使用本地镜像
- `Always`: 总是从仓库拉取镜像
- `Never`: 只使用本地镜像，不拉取

### 环境变量配置

每个服务都支持灵活的环境变量配置：

#### 方式1：环境变量覆盖（envOverrides）

如果你想覆盖特定的环境变量，可以使用 `envOverrides` 字段：

```yaml
studio:
  envOverrides:
    TZ: "Asia/Shanghai"
    STUDIO_PG_META_URL: "http://custom-meta:8080"

kong:
  envOverrides:
    KONG_DATABASE: "postgres"
    TZ: "Asia/Shanghai"
```

**特点：**
- 支持同名环境变量覆盖
- 使用简单的 key-value 格式
- 会覆盖默认的环境变量值

#### 方式2：额外添加环境变量（extraEnv）

如果你想在默认环境变量的基础上添加额外的变量，可以使用 `extraEnv` 字段：

```yaml
studio:
  extraEnv:
    - name: DEBUG
      value: "true"
    - name: CUSTOM_FEATURE
      value: "enabled"
```

**特点：**
- 追加到现有环境变量列表末尾
- 使用标准的 Kubernetes 环境变量格式
- 不会覆盖现有的环境变量

#### 方式3：混合使用

你可以同时使用两种方式：

```yaml
studio:
  envOverrides:
    TZ: "Asia/Shanghai"  # 覆盖默认的时区设置
  extraEnv:
    - name: DEBUG
      value: "true"  # 添加新的调试变量
```

#### 优先级说明

1. **默认环境变量**：首先应用模板中定义的默认环境变量
2. **envOverrides**：然后应用覆盖的环境变量（同名变量会被覆盖）
3. **extraEnv**：最后添加额外的环境变量

#### 使用示例

```yaml
# 完全自定义 Kong 的数据库配置
kong:
  envOverrides:
    KONG_DATABASE: "postgres"
    KONG_DATABASE_HOST: "my-postgres:5432"
    KONG_DATABASE_USER: "kong"
    KONG_DATABASE_PASSWORD: "kong_password"

# 为 Studio 添加调试信息
studio:
  envOverrides:
    TZ: "Asia/Shanghai"
  extraEnv:
    - name: DEBUG
      value: "true"
    - name: NODE_ENV
      value: "development"
```

## 持久化存储

该 chart 支持以下组件的持久化存储：

- **Database**: PostgreSQL 数据
- **Storage**: 文件存储数据 (仅 file 模式)
- **Functions**: Edge Functions 代码

## 安全配置

### 必需的 Secrets

确保配置以下必需的 secrets：

- `postgresPassword`: PostgreSQL 密码
- `jwtSecret`: JWT 签名密钥
- `anonKey`: 匿名访问密钥
- `serviceRoleKey`: 服务角色密钥
- `dashboardUsername`: 仪表板用户名
- `dashboardPassword`: 仪表板密码

### S3 存储 Secrets

如果使用 S3 存储，还需要配置：

- `accessKey`: S3 访问密钥
- `secretKey`: S3 秘密密钥

## 故障排除

### 常见问题

1. **数据库连接失败**
   - 检查 PostgreSQL 服务是否正常运行
   - 验证数据库密码配置

2. **存储服务无法启动**
   - 检查 PVC 是否成功创建
   - 验证存储类配置

3. **S3 存储配置错误**
   - 验证 S3 端点配置
   - 检查访问密钥和秘密密钥
   - 确保 MinIO 服务正常运行

### 日志查看

```bash
# 查看特定服务的日志
kubectl logs -f deployment/supabase-kong
kubectl logs -f deployment/supabase-auth
kubectl logs -f deployment/supabase-db
kubectl logs -f deployment/supabase-storage
```

## 升级

```bash
helm upgrade supabase ./charts/supabase -f my-values.yaml
```

## 卸载

```bash
helm uninstall supabase
```

注意：卸载 chart 不会删除持久化数据。如果需要删除数据，请手动删除相关的 PVC。

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个 Helm chart。 