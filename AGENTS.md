# RuoQi-v 项目文档

## 项目概述

**RuoQi-v** 是一个基于 V 语言开发的现代化后端框架，采用 Clean Architecture（整洁架构）设计模式，支持多租户、RBAC 权限控制和微服务架构。

### 核心特性

- ✅ **多租户架构** - 完整的多租户支持，支持租户隔离和数据权限控制
- ✅ **RBAC 权限系统** - 基于角色的访问控制，支持细粒度权限管理
- ✅ **多数据库支持** - MySQL、PostgreSQL、TiDB 等数据库连接池
- ✅ **缓存系统** - Redis 缓存支持，可选 ReadySet 热点表缓存
- ✅ **国际化** - 完整的 i18n 支持，多语言切换
- ✅ **消息队列** - 支持消息队列集成
- ✅ **文件存储** - FMS 文件管理系统
- ✅ **任务调度** - Job 任务调度系统
- ✅ **API 网关** - 统一的 API 管理和路由
- ✅ **Docker 容器化** - 完整的 Docker 和 Podman 部署支持

## 技术栈

### 核心技术

- **语言**: V 0.5.0
- **Web 框架**: veb (V 标准库)
- **ORM**: V 标准库 ORM
- **配置管理**: TOML 配置文件
- **日志**: 自定义日志系统
- **JWT**: JSON Web Token 认证

### 数据库支持

- **MySQL**: 连接池管理
- **PostgreSQL**: 连接池管理
- **TiDB**: 分布式数据库支持
- **Redis**: 缓存和会话存储

### 部署支持

- **Docker**: 容器化部署
- **Podman**: 容器化部署（替代 Docker）
- **Vercel**: 云原生部署配置

## 项目架构

### Clean Architecture 分层

```
RuoQi-v/
├── main/                           # 程序入口层（Composition Root）
│   └── main.v                      # 程序启动、依赖注入、初始化模块
│
├── route/                          # 路由注册层（HTTP / gRPC / CLI 映射）
│   ├── route.v                     # 路由基类和中间件设置
│   ├── route_sys_admin.v           # 系统管理路由
│   ├── route_core_admin.v          # 核心管理路由
│   ├── route_core_tenant.v         # 租户路由
│   └── ...                         # 其他业务路由
│
├── handler/                        # 接口适配层（Interface Adapter）
│   ├── rest/                       # REST API 处理器
│   │   ├── sys_admin_handler.v     # 系统管理处理器
│   │   ├── core_admin_handler.v    # 核心管理处理器
│   │   └── ...                     # 其他业务处理器
│   └── rpc/                        # RPC 处理器
│
├── service/                        # 应用用例层（Application Use Cases）
│   ├── base_api/                   # 基础 API 服务
│   ├── sys_admin_api/              # 系统管理 API
│   ├── core_admin_api/             # 核心管理 API
│   ├── core_tenant_api/            # 租户 API
│   ├── fms_api/                    # 文件管理 API
│   ├── job_api/                    # 任务调度 API
│   ├── msg_api/                    # 消息 API
│   └── pay_api/                    # 支付 API
│
├── domain/                         # 领域层（Domain Layer）
│   ├── core_admin/                 # 核心管理领域
│   ├── core_tenant/                # 租户领域
│   └── sys_admin/                  # 系统管理领域
│
├── dto/                            # 数据传输对象（Data Transfer Objects）
│   ├── core_admin/                 # 核心管理 DTO
│   ├── core_tenant/                # 租户 DTO
│   └── sys_admin/                  # 系统管理 DTO
│
├── structs/                        # 数据结构定义
│   ├── schema_base/                # 基础模式
│   ├── schema_core/                # 核心模式
│   ├── schema_sys/                 # 系统模式
│   └── ...                         # 其他模式
│
├── adapter/                        # 适配器层（Infrastructure）
│   ├── repository/                 # 仓储模式实现
│   │   └── user/                   # 用户仓储
│   ├── dbpool/                     # 数据库连接池
│   │   ├── mysql.v                 # MySQL 连接池
│   │   └── pgsql.v                 # PostgreSQL 连接池
│   ├── redis_pool/                 # Redis 连接池
│   ├── mq/                         # 消息队列
│   └── ...                         # 其他适配器
│
├── middleware/                     # 中间件层
│   ├── authority_middleware_sys.v  # 系统权限中间件
│   ├── authority_middleware_core.v # 核心权限中间件
│   ├── config_middleware.v         # 配置中间件
│   ├── dbpool_middleware.v         # 数据库中间件
│   ├── i18n_middleware.v           # 国际化中间件
│   └── logger_middleware.v         # 日志中间件
│
├── config/                         # 配置层
│   ├── conf.v                      # 配置加载器
│   └── conf_struct.v               # 配置结构体
│
├── common/                         # 通用工具层
│   ├── api/                        # API 响应构建器
│   ├── captcha/                    # 验证码工具
│   ├── encrypt/                    # 加密工具
│   ├── jwt/                        # JWT 工具
│   ├── utils/                      # 基础工具函数
│   └── opt/                        # 业务操作工具
│
├── i18n/                           # 国际化资源
│   └── locale_bak/                 # 语言包备份
│
├── usecase/                        # 用例层
│   └── sys_admin_api/              # 系统管理用例
│
├── static/                         # 静态资源
│   ├── index.html                  # 首页
│   ├── 403.html                    # 403 页面
│   ├── 404.html                    # 404 页面
│   └── 500.html                    # 500 页面
│
└── etc/                            # 配置文件目录
    ├── config.toml                 # 主配置文件
    ├── config_dev.toml             # 开发环境配置
    ├── config_template.toml        # 配置模板
    └── locales/                    # 语言资源目录
```

## 开发指南

### 环境要求

- **V 语言**: 0.5.0 或更高版本
- **Docker**: 用于容器化部署（可选）
- **Git**: 版本控制

### 快速开始

#### 1. 克隆项目

```bash
git clone https://codeberg.org/RuoQi/RuoQi-v.git
cd RuoQi-v
```

#### 2. 开发环境运行

```bash
# 进入 backend 目录
cd backend

# 启动开发服务器
v run main/main.v
```

#### 3. 构建项目

```bash
# 在 backend 目录下构建
v build main/main.v

# 运行构建后的程序
./app
```

### Example 文件夹调试说明

`example` 目录用于存放临时调试代码和案例示例。在调试 `example` 文件夹中的内容时，**不需要与 `backend` 产生交集**，即：

- `example` 目录中的代码可以独立运行，不依赖 `backend` 模块
- 调试时可以直接在 `example` 目录下运行 V 程序
- 不需要将 `example` 中的代码移动到 `backend` 目录中

#### Example 目录结构

```
example/
├── temp/                    # 临时调试目录
│   ├── dbpool_test.v        # 数据库连接池测试
│   ├── dbpool.v             # 数据库连接池示例
│   └── temp.vsh             # 临时脚本
├── captcha/                 # 验证码示例
├── config/                  # 配置示例
├── dataperm/                # 数据权限示例
├── i18n/                    # 国际化示例
├── logger/                  # 日志示例
├── utils/                   # 工具函数示例
├── vdb/                     # V 数据库示例
├── vorm/                    # V ORM 示例
└── vsync/                   # 同步示例
```

#### Example 调试示例

```bash
# 在 example 目录下直接运行
cd example/temp
v run dbpool_test.v

# 或者使用完整路径
v run example/temp/dbpool_test.v
```

### V 源码路径

- **V 语言最新版本源码路径**: `/home/Jengro/.vmr/versions/v_versions/v_latest`
- **用途**: 当需要检查 V 语言标准库的实现、调试 V 语言相关问题或查看标准库源码时，可以访问此路径

#### 查看 V 标准库源码示例

```bash
# 查看 db.redis 模块源码
ls /home/Jengro/.vmr/versions/v_versions/v_latest/vlib/db/redis/

# 查看 veb 模块源码
ls /home/Jengro/.vmr/versions/v_versions/v_latest/vlib/veb/

# 查看 pool 模块源码
ls /home/Jengro/.vmr/versions/v_versions/v_latest/vlib/pool/
```

#### 调试和开发提示

- **源码位置**: `/home/Jengro/.vmr/versions/v_versions/v_latest/vlib/`
- **模块结构**: V 标准库模块通常位于 `vlib/模块名/` 目录下
- **常用模块**:
  - `db/` - 数据库相关
  - `veb/` - Web 框架
  - `pool/` - 连接池
  - `time/` - 时间处理
  - `os/` - 操作系统接口

### 配置说明

项目使用 TOML 格式的配置文件，主要配置项：

```toml
[web]
port = 9009
timeout = 30

[database]
type = "mysql"
host = "127.0.0.1"
port = 3306
user = "root"
password = "mysql_123456"
name = "ruoqi_v"
```

#### 数据库连接配置示例

<!--
  SECURITY: 以下是公开测试环境的示例凭证，非生产环境密钥
  这些是公开可用的测试数据库，无需保护
-->

```v
// MySQL 配置
  type: "mysql"
	host:     'mysql2.sqlpub.com'
	port:     3307
	username: 'vcore_test'
	password: 'wfo8wS7CylT0qIMg'
	dbname:   'vcore_test'

	//本地测试使用
	host:     '127.0.0.1'
	port:     3306
	username: 'root'
	password: 'mysql_123456'
	dbname:   'vcore'

// PostgreSQL 配置
  type: "pgsql"
	host:     'ep-wandering-king-akw206lc-pooler.c-3.us-west-2.aws.neon.tech'
	port:     5432
	username: 'neondb_owner'
	password: 'npg_U4j7sqBcgIMO'
	dbname:   'vcore_test'

  //本地测试使用
	host:     '127.0.0.1'
	port:     5432
	username: 'root'
	password: 'pg_123456'
	dbname:   'vcore'
```

### 命名规范

#### Handler 命名

- `xxx_handler` - 业务处理器

#### 用例命名

- `get_xxx_usecase` - 获取数据用例
- `find_xxx_usecase` - 查询数据用例
- `save_xxx_usecase` - 保存数据用例
- `delete_xxx_usecase` - 删除数据用例
- `update_xxx_usecase` - 更新数据用例

#### 领域命名

- `validate_xxx` - 验证业务规则
- `process_xxx` - 处理业务逻辑
- `calculate_xxx` - 计算业务属性
- `apply_xxx` - 应用业务操作

#### DTO 命名

| 类型     | 命名方式       | 说明                    |
| -------- | -------------- | ----------------------- |
| 请求对象 | `XxxReq`       | 用于请求的输入对象      |
| 响应对象 | `XxxResp`      | 用于响应的输出对象      |
| 创建对象 | `CreateXxxReq` | 用于创建操作的请求对象  |
| 更新对象 | `UpdateXxxReq` | 用于更新操作的请求对象  |
| 分页请求 | `XxxReq`       | 带有分页参数的请求对象  |
| 查询对象 | `XxxReq`       | 用于筛选/查询的请求对象 |

## API 文档

### 路由结构

项目支持多层级路由，根据权限类型分为：

1. **无认证路由** - 无需登录即可访问
2. **系统管理路由** - 系统管理员权限
3. **核心管理路由** - 核心业务权限
4. **租户路由** - 租户级业务权限

### 常用 API 端点

```
# 系统管理
/sys/admin/...      # 系统管理接口
/core/admin/...     # 核心管理接口
/core/tenant/...    # 租户接口

# 文件管理
/fms/...            # 文件管理系统

# 任务调度
/job/...            # 任务调度系统

# 消息系统
/msg/...            # 消息系统

# 支付系统
/pay/...            # 支付系统
```

## 部署指南

### Docker 部署

```bash
# 构建镜像
cd deploy/docker
./docker_build.sh

# 运行容器
./docker_run.sh
```

### Podman 部署

```bash
# 构建镜像
cd deploy/podman
./podman_build.sh

# 运行容器
./podman_run.sh
```

### 环境变量配置

```bash

# JWT 密钥
JWT_SECRET=******

# 服务器端口
SERVER_PORT=9009

# Docker Hub 配置
DOCKER_USERNAME=your_docker_username
DOCKER_TOKEN=your_docker_token_here

```

## 开发规范

### Git 提交规范

参考 [Angular 提交规范](https://github.com/conventional-changelog/conventional-changelog/tree/master/packages/conventional-changelog-angular)

- `feat` - 新功能
- `fix` - 修复问题
- `docs` - 文档更新
- `style` - 代码格式调整
- `refactor` - 重构
- `perf` - 性能优化
- `test` - 测试相关
- `chore` - 构建工具或辅助工具的变动

### 代码风格

- 使用 V 语言标准代码风格
- 遵循 Clean Architecture 分层原则
- 保持函数简洁，单一职责
- 充分的错误处理
- 详细的注释说明

### 测试规范

```bash
# 运行测试
v test ./...

# 运行特定测试
v test ./backend/service/xxx_api/
```

### 测试文件命名规则

- **测试文件命名**：原文件名称 + `_test` 后缀
  - 示例：`redis_pool.v` → `redis_pool_test.v`
  - 示例：`user_service.v` → `user_service_test.v`
  - 示例：`config_loader.v` → `config_loader_test.v`

- **测试函数命名**：
  - 测试用例：`test_xxx()` - 例如 `test_new_redis_pool()`
  - 辅助测试：`test_xxx_helper()` - 例如 `test_connection_helper()`

- **测试目录组织**：
  - 测试文件与被测试文件放在同一目录
  - 示例：`backend/adapter/redis_pool/redis_pool_test.v`
  - 示例：`backend/service/sys_admin_api/sys_admin_api_test.v`

- **测试文件结构**：

  ```v
  module xxx

  fn test_xxx() {
      // 测试代码
  }

  ```

- **测试命令**：

  ```v
  v -stats test . //运行当前目录以及子目录下的测试文件
  v -stats test xx.v //运行指定测试文件
  ```

### Git 忽略配置

在 `.gitignore` 文件中添加以下配置以忽略特定文件夹：

```gitignore
# 忽略编译生成的可执行文件
/app

# 忽略构建缓存和临时文件
*.tmp
*.temp
build/

# 忽略日志文件
*.log
logs/

# 忽略配置文件（保留模板）
!etc/config_template.toml
etc/config.toml

# 忽略 IDE 配置
.vscode/
.idea/
*.swp
*.swo

# 忽略系统文件
.DS_Store
Thumbs.db

# 忽略文档生成目录
vdoc/

# 忽略部署相关文件
deploy/docker/*.log
deploy/podman/*.log
```

**需要特别忽略的文件夹：一定不要修改和使用这些文件夹以及内容，也不需要分析**

- `backend/adapter/repository/` - 仓储实现，通常不需要提交
- `backend/handler/` - 处理器层，属于基础设施层
- `backend/dto/` - 数据传输对象，通常由代码生成
- `backend/parts/` - 接口定义，属于领域层
- `backend/usecase/` - 用例层，业务逻辑实现

这些文件夹通常由代码生成工具维护，或者在不同环境中需要重新生成。

## 性能优化

### 缓存策略

1. **Redis 缓存** - 会话存储、热点数据
2. **ReadySet** - 热点表缓存（百万级用户推荐）
3. **连接池** - 数据库连接复用

### 监控指标

- 请求响应时间
- 错误率统计
- 数据库连接池使用率
- 缓存命中率

## 安全指南

### 认证授权

- JWT Token 认证
- RBAC 权限控制
- 租户数据隔离

### 数据安全

- 密码加密存储
- SQL 注入防护
- XSS 攻击防护

### 网络安全

- HTTPS 支持
- API 限流
- 安全头设置

## 故障排查

### 常见问题

1. **数据库连接失败**
   - 检查数据库服务状态
   - 验证连接配置
   - 确认网络连通性

2. **权限不足**
   - 检查用户权限配置
   - 验证 JWT Token
   - 确认 RBAC 规则

3. **缓存异常**
   - 检查 Redis 服务
   - 验证缓存配置
   - 清理缓存数据

### 日志查看

```bash
# 查看应用日志
tail -f backend/app.log

# 查看 Docker 日志
docker logs ruoqi-v

# 查看 Podman 日志
podman logs ruoqi-v
```

## 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 更新日志

### v0.5.0

- 优化性能和架构
- 增强多租户支持
- 完善 RBAC 权限系统
- 添加更多部署选项

### 历史版本

- 支持 Redis 缓存集成
- 添加 PostgreSQL 连接池
- 完善 Docker 容器化部署
- 增强国际化支持

---

**最后更新**: 2026年2月5日  
**项目状态**: 活跃开发中
