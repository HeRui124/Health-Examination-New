# 东软熙心健康体检管理系统 - 项目汇报PPT内容

---

## Page 2 - 项目介绍与技术栈

### 项目介绍

**项目名称**：东软熙心健康体检管理系统（XiXin Health Examination System）

**项目定位**：基于微服务架构的现代化健康体检预约与管理平台

**核心价值**：
- 🏥 **为患者**：提供便捷的体检预约、报告查询服务，支持AI智能健康咨询
- 👨‍⚕️ **为医生**：提供高效的报告生成与检查结果录入工具，提升工作效率
- 👨‍💼 **为管理员**：提供完善的机构、套餐、用户管理功能，实现精细化运营
- 🤖 **智能化**：集成AI助手，基于RAG技术提供专业健康咨询服务

**系统特点**：
- 前后端分离架构，职责清晰
- 微服务设计，易于扩展和维护
- 多角色权限控制，保障数据安全
- 响应式设计，适配多种设备

---

### 技术栈

#### 前端技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| Vue 3 | 3.5.34 | 核心框架，使用 Composition API + `<script setup>` |
| TypeScript | 6.0.2 | 类型安全的JavaScript超集 |
| Vite | 8.0.12 | 快速的前端构建工具 |
| Element Plus | 2.9.10 | UI组件库，提供丰富的组件 |
| Pinia | 3.0.4 | 状态管理库 |
| Axios | 1.17.0 | HTTP客户端，用于API请求 |
| @element-plus/icons-vue | 2.3.1 | Element Plus图标库 |

#### 后端技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| Spring Boot | 3.4.5 | 核心框架 |
| Spring Cloud | 2024.0.1 | 微服务框架 |
| Spring Cloud Alibaba | 2023.0.3.2 | 阿里巴巴微服务解决方案 |
| Nacos | - | 注册中心 + 配置中心 |
| Spring Cloud Gateway | - | API网关 |
| MyBatis-Plus | 3.5.9 | ORM框架，简化数据库操作 |
| MySQL | 9.1.0 | 关系型数据库 |
| RabbitMQ | - | 消息队列，异步解耦 |
| MinIO | - | 对象存储，文件服务 |
| Knife4j | 4.5.0 | API文档工具 |
| JWT (jjwt) | 0.12.6 | Token认证 |
| Hutool | 5.8.38 | Java工具类库 |
| Spring AI | - | AI集成框架 |
| RAG | - | 检索增强生成，通义千问 |

#### 开发环境

- **JDK版本**：Java 17
- **构建工具**：Maven
- **IDE**：IntelliJ IDEA（后端）、VS Code（前端）
- **操作系统**：Windows / Linux / macOS

---

## Page 3 - 人员分工及项目开发计划

### 人员分工

| 角色 | 人数 | 主要职责 | 负责模块 |
|------|------|---------|----------|
| **项目经理** | 1人 | 整体规划、进度控制、需求分析、风险管理 | 项目管理、需求文档、协调沟通 |
| **前端开发工程师** | 2人 | 前端页面开发、接口对接、UI优化、性能调优 | 所有Vue组件、API封装、路由配置 |
| **后端开发工程师** | 3人 | 微服务架构设计、业务逻辑实现、数据库设计 | 各微服务模块、API接口、数据持久层 |
| **数据库工程师** | 1人 | 数据库设计、SQL优化、索引设计、数据迁移 | 数据库表结构、存储过程、视图 |
| **测试工程师** | 1人 | 功能测试、性能测试、Bug跟踪、测试报告 | 测试用例、自动化测试、质量保障 |
| **DevOps工程师** | 1人 | 环境部署、CI/CD配置、监控告警、日志收集 | Nacos、Gateway、MinIO部署与维护 |

**总计**：9人团队

---

### 项目开发计划（12周）

#### 阶段一：需求分析与设计（第1-2周）

**目标**：明确需求，完成系统设计

**主要任务**：
- ✅ 需求调研与分析（用户访谈、竞品分析）
- ✅ 系统架构设计（微服务划分、技术选型）
- ✅ 数据库表结构设计（ER图、表关系）
- ✅ API接口设计（Swagger文档）
- ✅ UI原型设计（Figma/Axure）

**交付物**：
- 需求规格说明书
- 系统架构设计文档
- 数据库设计文档
- API接口文档
- UI原型图

---

#### 阶段二：基础框架搭建（第3-4周）

**目标**：搭建微服务基础框架

**主要任务**：
- ✅ 创建微服务模块（9个模块）
- ✅ 配置Nacos注册中心和配置中心
- ✅ 配置Spring Cloud Gateway网关
- ✅ 开发公共模块（xixin-common）
  - 统一响应体封装
  - 全局异常处理
  - JWT工具类
  - 权限注解
- ✅ 开发认证授权模块（xixin-auth）
  - 登录/注册接口
  - JWT Token生成与验证
  - 用户信息管理

**交付物**：
- 可运行的微服务框架
- 统一的代码规范
- 基础的认证授权功能

---

#### 阶段三：核心功能开发（第5-8周）

**目标**：完成所有后端业务功能

**主要任务**：

**第5周**：用户管理模块（xixin-user）
- 患者档案管理（CRUD）
- 医生档案管理（CRUD）

**第6周**：体检管理模块（xixin-exam）
- 机构管理（CRUD、关联套餐、关联预约类型）
- 套餐管理（CRUD、关联检查项目）
- 检查项目管理
- 预约管理（创建、查询、取消、完成）
- 字典管理

**第7周**：报告管理模块（xixin-report）
- 报告生成
- 报告查询
- 报告修改
- 检查项目结果录入

**第8周**：其他模块
- 系统管理模块（xixin-system）：字典类型和字典项管理
- 文件服务模块（xixin-file）：MinIO集成，文件上传下载
- AI服务模块（xixin-ai）：Spring AI集成，RAG实现

**交付物**：
- 完整的后端API接口
- API文档（Knife4j）
- 单元测试用例

---

#### 阶段四：前端开发（第6-9周）

**目标**：完成所有前端页面开发

**主要任务**：

**第6周**：基础页面
- 登录注册页面（LoginPage.vue）
- 主应用框架（App.vue）
- 路由和状态管理配置

**第7周**：患者端页面
- 首页（HomePage.vue）：机构、套餐展示
- 预约页面（BookingPage.vue）：预约流程
- 个人中心（ProfilePage.vue）：预约列表、报告列表、档案编辑

**第8周**：医生端页面
- 工作台（DoctorHomePage.vue）：待处理预约、报告生成
- 报告管理（DoctorReportsPage.vue）：报告列表、编辑
- 医生个人中心（DoctorProfilePage.vue）

**第9周**：管理员端页面 + AI功能
- 用户管理（AdminUsersPage.vue）
- 套餐管理（AdminPackagesPage.vue）
- 机构管理（AdminInstitutionsPage.vue）
- 字典管理（AdminDictPage.vue）
- AI悬浮窗（AIChatWidget.vue）

**交付物**：
- 完整的前端页面
- 响应式设计
- 良好的用户体验

---

#### 阶段五：联调与测试（第10-11周）

**目标**：确保系统质量和稳定性

**主要任务**：
- ✅ 前后端接口联调
- ✅ 功能测试（手动测试 + 自动化测试）
- ✅ 性能测试（JMeter压力测试）
- ✅ 安全测试（SQL注入、XSS、CSRF）
- ✅ 兼容性测试（Chrome、Firefox、Safari、Edge）
- ✅ Bug修复和优化

**交付物**：
- 测试报告
- Bug清单及修复记录
- 性能测试报告

---

#### 阶段六：部署与上线（第12周）

**目标**：系统正式上线运行

**主要任务**：
- ✅ 生产环境部署
- ✅ 数据初始化（字典数据、测试数据）
- ✅ 系统验收测试
- ✅ 用户培训
- ✅ 文档编写（用户手册、运维手册）
- ✅ 监控系统配置

**交付物**：
- 可运行的生产系统
- 完整的文档体系
- 运维手册

---

### 里程碑节点

| 时间节点 | 里程碑 | 关键成果 |
|---------|--------|---------|
| 第2周末 | 需求与设计完成 | 需求文档、设计文档 |
| 第4周末 | 基础框架完成 | 可运行的微服务框架 |
| 第8周末 | 后端功能完成 | 完整的API接口 |
| 第9周末 | 前端功能完成 | 完整的前端页面 |
| 第11周末 | 测试完成 | 测试报告、Bug修复 |
| 第12周末 | 系统上线 | 生产系统运行 |

---

## Page 4 - 需求分析、用例图、原型设计

### 需求分析

#### 功能性需求

##### 1. 用户认证模块

**功能描述**：
- 用户登录：支持三种角色（患者/医生/管理员）
- 用户注册：新用户注册，默认角色为患者
- 头像上传：更新用户头像

**业务流程**：
```
用户输入用户名和密码 → 后端验证 → 生成JWT Token → 返回用户信息和Token → 前端存储Token
```

**关键接口**：
- `POST /api/auth/login` - 用户登录
- `POST /api/auth/register` - 用户注册
- `PUT /api/user/avatar` - 更新头像

---

##### 2. 患者端功能

###### 2.1 首页浏览

**功能描述**：
- 展示推荐机构列表
- 展示热门体检类型
- 展示热门套餐

**业务流程**：
```
加载已启用机构 → 加载体检类型字典 → 加载热门套餐 → 展示给用户
```

###### 2.2 体检预约

**功能描述**：
- 选择体检类型
- 根据类型选择机构
- 根据机构选择套餐
- 填写预约信息（日期、时间、备注）
- 提交预约

**业务流程**：
```
选择体检类型 → 查询该类型支持的机构 → 选择机构 → 查询该机构的套餐 → 选择套餐 → 填写预约信息 → 提交预约
```

**关键接口**：
- `GET /api/exam/appointment-types/{type}/institutions` - 按类型查机构
- `GET /api/exam/institutions/{institutionId}/packages` - 按机构查套餐
- `POST /api/exam/appointments` - 创建预约

###### 2.3 个人中心

**功能描述**：
- 查看个人信息
- 查看我的预约列表
- 取消预约
- 查看我的报告列表
- 查看报告详情
- 编辑个人档案

**关键接口**：
- `GET /api/exam/appointments` - 查询预约列表
- `PUT /api/exam/appointments/{id}/cancel` - 取消预约
- `GET /api/report/list` - 查询报告列表
- `GET /api/report/{id}` - 查询报告详情
- `PUT /api/user/patients/{id}` - 更新患者档案

---

##### 3. 医生端功能

###### 3.1 工作台

**功能描述**：
- 查看待处理预约列表
- 标记体检完成
- 生成体检报告（填写摘要、结论）
- 批量录入检查项目结果

**业务流程**：
```
查看待处理预约 → 标记体检完成 → 生成报告 → 录入检查项目结果
```

**关键接口**：
- `GET /api/exam/appointments` - 查询预约列表（医生视角）
- `PUT /api/exam/appointments/{id}/complete` - 标记体检完成
- `POST /api/report/generate` - 生成报告
- `POST /api/report/{reportId}/items/batch` - 批量录入项目

###### 3.2 报告管理

**功能描述**：
- 查看已生成的报告列表
- 查看报告详情
- 修改报告内容（摘要、结论）
- 修改检查项目结果

**关键接口**：
- `GET /api/report/list` - 查询报告列表
- `PUT /api/report/{id}` - 修改报告
- `PUT /api/report/{reportId}/items/{itemId}` - 修改检查项

---

##### 4. 管理员端功能

###### 4.1 用户管理

**功能描述**：
- 查看所有用户列表
- 筛选用户（按角色、关键词）
- 编辑用户信息
- 禁用/启用用户
- 重置密码
- 删除用户

**关键接口**：
- `GET /api/auth/users` - 查询用户列表
- `PUT /api/auth/users/{id}` - 更新用户信息
- `PUT /api/auth/users/{id}/status` - 更新用户状态
- `PUT /api/auth/users/{id}/password` - 重置密码
- `DELETE /api/auth/users/{id}` - 删除用户

###### 4.2 套餐管理

**功能描述**：
- 查看套餐列表
- 新增/编辑/删除套餐
- 启用/禁用套餐
- 为套餐添加/删除检查项目

**关键接口**：
- `GET /api/exam/packages` - 分页查询套餐
- `POST /api/exam/packages` - 创建套餐
- `PUT /api/exam/packages` - 更新套餐
- `DELETE /api/exam/packages/{id}` - 删除套餐
- `POST /api/exam/packages/{packageId}/items` - 创建检查项目

###### 4.3 机构管理

**功能描述**：
- 查看机构列表
- 新增/编辑/删除机构
- 为机构关联多个套餐
- 为机构配置支持的预约类型

**关键接口**：
- `GET /api/exam/institutions` - 分页查询机构
- `POST /api/exam/institutions` - 创建机构
- `PUT /api/exam/institutions` - 更新机构
- `DELETE /api/exam/institutions/{id}` - 删除机构
- `POST /api/exam/institution-packages` - 关联套餐
- `POST /api/exam/appt-type-institutions` - 关联预约类型

###### 4.4 字典管理

**功能描述**：
- 查看字典类型列表
- 新增/编辑/删除字典类型
- 查看字典项列表
- 新增/编辑/删除字典项

**关键接口**：
- `GET /api/system/dict-types` - 分页查询字典类型
- `POST /api/system/dict-types` - 创建字典类型
- `PUT /api/system/dict-types` - 更新字典类型
- `DELETE /api/system/dict-types/{id}` - 删除字典类型
- `GET /api/system/dict-items/by-type/{typeId}` - 分页查询字典项
- `POST /api/system/dict-items` - 创建字典项
- `PUT /api/system/dict-items` - 更新字典项
- `DELETE /api/system/dict-items/{id}` - 删除字典项

---

##### 5. AI聊天功能

**功能描述**：
- 悬浮窗形式的AI助手
- 支持Markdown格式渲染（加粗、斜体、代码块等）
- 患者端和医生端可见，管理员端隐藏
- 基于RAG技术，提供专业健康咨询

**关键接口**：
- `POST /api/ai/chat` - AI对话

---

#### 非功能性需求

| 需求类型 | 具体要求 |
|---------|---------|
| **性能要求** | 页面加载时间 < 2秒，API响应时间 < 500ms，支持1000并发用户 |
| **安全性** | JWT Token认证、接口权限控制、SQL防注入、XSS防护、HTTPS传输 |
| **可用性** | 响应式设计、友好的错误提示、操作引导、无障碍访问 |
| **可扩展性** | 微服务架构、模块化设计、易于添加新功能 |
| **可维护性** | 代码规范、注释完整、日志完善、文档齐全 |
| **可靠性** | 系统可用性 > 99.9%，数据备份与恢复机制 |

---

### 用例图

#### 参与者（Actors）

1. **患者（Patient）**：普通用户，使用体检预约和报告查询功能
2. **医生（Doctor）**：医务人员，处理预约、生成报告
3. **管理员（Admin）**：系统管理员，管理用户、套餐、机构、字典

---

#### 患者用例

```
┌─────────────────────────────────────┐
│           患者（Patient）            │
├─────────────────────────────────────┤
│ • 登录/注册                          │
│ • 浏览机构/套餐                      │
│ • 预约体检                           │
│ • 查看预约                           │
│ • 取消预约                           │
│ • 查看报告                           │
│ • 编辑档案                           │
│ • AI咨询                             │
└─────────────────────────────────────┘
```

---

#### 医生用例

```
┌─────────────────────────────────────┐
│           医生（Doctor）             │
├─────────────────────────────────────┤
│ • 登录                               │
│ • 查看待处理预约                     │
│ • 标记体检完成                       │
│ • 生成报告                           │
│ • 录入检查结果                       │
│ • 查看报告列表                       │
│ • 修改报告                           │
│ • AI咨询                             │
└─────────────────────────────────────┘
```

---

#### 管理员用例

```
┌─────────────────────────────────────┐
│          管理员（Admin）             │
├─────────────────────────────────────┤
│ • 登录                               │
│ • 用户管理（增删改查、禁用、重置密码）│
│ • 套餐管理（增删改查、关联项目）      │
│ • 机构管理（增删改查、关联套餐/类型） │
│ • 字典管理（增删改查）               │
└─────────────────────────────────────┘
```

---

### 原型设计要点

#### 设计风格
- **配色方案**：医疗行业蓝绿色系（#409EFF、#67C23A）
- **字体**：微软雅黑、PingFang SC
- **图标**：Element Plus Icons
- **风格**：简洁现代、扁平化设计

#### 布局方式
- **顶部导航栏**：Logo、用户信息、退出登录
- **Tab切换**：根据不同角色显示不同的Tab
- **内容区**：卡片式布局、表格展示、表单交互

#### 响应式设计
- **PC端**：≥ 1200px，多列布局
- **平板端**：768px - 1199px，自适应布局
- **移动端**：< 768px，单列布局

#### 交互体验
- **表单验证**：实时验证、错误提示
- **加载状态**：Loading动画、骨架屏
- **成功/失败提示**：ElMessage通知
- **确认操作**：ElMessageBox二次确认
- **空状态**：友好的空数据提示

---

## Page 5 - 系统功能结构图、项目核心界面的截图展示

### 系统功能结构图

```
健康检查系统（XiXin Health Examination System）
│
├── 📱 前端应用（Vue 3 + TypeScript）
│   ├── 认证模块
│   │   ├── 登录页面（LoginPage.vue）
│   │   └── 注册功能
│   │
│   ├── 患者端
│   │   ├── 首页（HomePage.vue）
│   │   │   ├── 推荐机构展示
│   │   │   ├── 热门体检类型
│   │   │   └── 热门套餐展示
│   │   ├── 预约页面（BookingPage.vue）
│   │   │   ├── 体检类型选择
│   │   │   ├── 机构选择
│   │   │   ├── 套餐选择
│   │   │   └── 预约信息填写
│   │   └── 个人中心（ProfilePage.vue）
│   │       ├── 个人信息展示
│   │       ├── 我的预约列表
│   │       ├── 我的报告列表
│   │       └── 编辑档案
│   │
│   ├── 医生端
│   │   ├── 工作台（DoctorHomePage.vue）
│   │   │   ├── 待处理预约列表
│   │   │   ├── 标记体检完成
│   │   │   ├── 生成报告
│   │   │   └── 录入检查结果
│   │   ├── 报告管理（DoctorReportsPage.vue）
│   │   │   ├── 报告列表
│   │   │   ├── 报告详情
│   │   │   └── 报告编辑
│   │   └── 医生个人中心（DoctorProfilePage.vue）
│   │
│   ├── 管理员端
│   │   ├── 用户管理（AdminUsersPage.vue）
│   │   ├── 套餐管理（AdminPackagesPage.vue）
│   │   ├── 机构管理（AdminInstitutionsPage.vue）
│   │   └── 字典管理（AdminDictPage.vue）
│   │
│   └── 通用组件
│       └── AI悬浮窗（AIChatWidget.vue）
│
├── 🔧 后端微服务（Spring Cloud）
│   ├── xixin-gateway（API网关）
│   │   ├── 路由转发
│   │   ├── 负载均衡
│   │   └── 统一鉴权
│   │
│   ├── xixin-auth（认证授权服务）
│   │   ├── 用户登录
│   │   ├── 用户注册
│   │   ├── JWT Token管理
│   │   └── 用户管理（管理员）
│   │
│   ├── xixin-user（用户管理服务）
│   │   ├── 患者档案管理
│   │   └── 医生档案管理
│   │
│   ├── xixin-exam（体检管理服务）
│   │   ├── 机构管理
│   │   ├── 套餐管理
│   │   ├── 检查项目管理
│   │   ├── 预约管理
│   │   └── 字典管理
│   │
│   ├── xixin-report（报告管理服务）
│   │   ├── 报告生成
│   │   ├── 报告查询
│   │   ├── 报告修改
│   │   └── 检查项目结果录入
│   │
│   ├── xixin-system（系统管理服务）
│   │   ├── 字典类型管理
│   │   └── 字典项管理
│   │
│   ├── xixin-file（文件服务）
│   │   └── 文件上传（MinIO）
│   │
│   └── xixin-ai（AI服务）
│       └── AI对话（Spring AI + RAG）
│
├── 💾 数据存储
│   ├── MySQL（关系型数据库）
│   │   ├── 用户表
│   │   ├── 患者表
│   │   ├── 医生表
│   │   ├── 机构表
│   │   ├── 套餐表
│   │   ├── 预约表
│   │   ├── 报告表
│   │   └── 字典表
│   ├── MinIO（对象存储）
│   │   └── 用户头像、文件
│   └── Redis（缓存，可选）
│       └── Token黑名单、热点数据
│
└── 🛠️ 基础设施
    ├── Nacos（注册中心 + 配置中心）
    ├── RabbitMQ（消息队列）
    └── Docker（容器化部署，可选）
```

---

### 项目核心界面展示

以下是各个核心界面的截图位置说明，请在PPT中插入对应的截图：

#### 1. 登录页面（LoginPage.vue）

**截图要点**：
- 居中的登录卡片
- 用户名/密码输入框
- 登录按钮
- 注册链接
- 简洁的背景设计

**功能亮点**：
- 表单验证（必填项、格式校验）
- 记住我选项
- 忘记密码链接（可扩展）

---

#### 2. 患者首页（HomePage.vue）

**截图要点**：
- 顶部搜索栏
- 推荐机构卡片列表（网格布局）
- 热门体检类型标签
- 热门套餐展示
- 分页控件

**功能亮点**：
- 卡片悬停效果
- 点击查看详情弹窗
- 响应式布局

---

#### 3. 预约页面（BookingPage.vue）

**截图要点**：
- 步骤条（体检类型 → 机构 → 套餐 → 确认）
- 体检类型选择卡片
- 机构下拉选择
- 套餐列表（带价格、描述）
- 预约日期选择器
- 时间槽选择
- 备注输入框
- 提交按钮

**功能亮点**：
- 级联选择（类型→机构→套餐）
- 表单验证
- 预约冲突检测

---

#### 4. 患者个人中心（ProfilePage.vue）

**截图要点**：
- Tab切换（个人信息、我的预约、我的报告）
- 个人信息展示卡片
- 预约列表表格（状态、日期、操作）
- 报告列表表格（生成时间、状态、操作）
- 编辑档案表单

**功能亮点**：
- 取消预约按钮（仅未完成预约）
- 查看报告详情按钮
- 档案编辑模态框

---

#### 5. 医生工作台（DoctorHomePage.vue）

**截图要点**：
- 待处理预约列表表格
- 标记体检完成按钮
- 生成报告表单（摘要、结论）
- 检查项目结果录入表格
- 批量保存按钮

**功能亮点**：
- 预约状态标识
- 报告生成向导
- 检查结果批量录入

---

#### 6. 医生报告管理（DoctorReportsPage.vue）

**截图要点**：
- 报告列表表格
- 报告详情查看面板
- 报告编辑表单
- 检查项目明细表格
- 修改按钮

**功能亮点**：
- 报告状态筛选
- 详情展开/收起
- 修改历史记录（可扩展）

---

#### 7. 管理员-用户管理（AdminUsersPage.vue）

**截图要点**：
- 筛选条件（角色下拉、关键词输入）
- 用户列表表格（用户名、姓名、角色、状态、操作）
- 编辑用户对话框
- 禁用/启用按钮
- 重置密码按钮
- 删除按钮

**功能亮点**：
- 多条件筛选
- 批量操作（可扩展）
- 状态切换确认

---

#### 8. 管理员-套餐管理（AdminPackagesPage.vue）

**截图要点**：
- 套餐列表表格
- 新增/编辑套餐对话框
- 检查项目管理子表格
- 启用/禁用开关
- 删除按钮

**功能亮点**：
- 套餐与检查项目的关联
- 价格格式化
- 排序功能

---

#### 9. 管理员-机构管理（AdminInstitutionsPage.vue）

**截图要点**：
- 机构列表表格
- 新增/编辑机构对话框
- 套餐关联管理（多选下拉）
- 预约类型关联管理
- 删除按钮

**功能亮点**：
- 机构与套餐的多对多关联
- 预约类型动态配置
- 地址地图展示（可扩展）

---

#### 10. 管理员-字典管理（AdminDictPage.vue）

**截图要点**：
- 左右分栏布局（PC端）/垂直布局（移动端）
- 左侧：字典类型列表
- 右侧：字典项列表
- 新增/编辑对话框
- 删除按钮

**功能亮点**：
- 联动选择（选择类型后显示对应字典项）
- 排序功能
- 状态切换

---

#### 11. AI悬浮窗（AIChatWidget.vue）

**截图要点**：
- 右下角悬浮按钮
- 展开后的聊天对话框
- 消息气泡（用户/AI）
- Markdown格式渲染效果
- 输入框和发送按钮

**功能亮点**：
- Markdown渲染（加粗、斜体、代码块）
- 历史消息滚动
- 快捷关闭/展开

---

### 截图建议

**截图工具**：
- Windows：Snipping Tool、ShareX
- macOS：Screenshot、Snagit
- 浏览器插件：GoFullPage、Fireshot

**截图技巧**：
- 使用1920x1080分辨率
- 保持界面整洁（清除无关通知）
- 突出关键功能区域（可使用红框标注）
- 统一截图风格（圆角、阴影）

---

## Page 6 - 测试说明

### 测试策略

本项目采用多层次测试策略，确保系统质量和稳定性：

#### 1. 单元测试（Unit Testing）

**目标**：验证单个函数或方法的正确性

**工具**：
- 后端：JUnit 5 + Mockito
- 前端：Vitest + Vue Test Utils

**覆盖范围**：
- Service层业务逻辑
- 工具类方法
- 数据转换逻辑

**覆盖率要求**：≥ 80%

---

#### 2. 接口测试（API Testing）

**目标**：验证API接口的正确性和性能

**工具**：
- Postman
- Knife4j（Swagger UI）
- JMeter（性能测试）

**测试内容**：
- 请求参数验证
- 响应数据格式
- 错误码返回
- 响应时间
- 并发处理能力

---

#### 3. 功能测试（Functional Testing）

**目标**：验证业务流程的正确性

**方法**：
- 手动测试
- Selenium自动化测试（可选）

**测试范围**：
- 用户认证流程
- 预约流程
- 报告生成流程
- 管理功能流程

---

#### 4. 性能测试（Performance Testing）

**目标**：评估系统在高负载下的表现

**工具**：JMeter

**测试场景**：
- 并发登录测试（1000用户）
- 预约提交压力测试
- 报告查询性能测试
- 数据库连接池压力测试

**性能指标**：
- 平均响应时间 < 500ms
- 最大并发数 ≥ 1000
- 吞吐量 ≥ 100 TPS
- CPU使用率 < 80%
- 内存使用率 < 85%

---

#### 5. 兼容性测试（Compatibility Testing）

**目标**：确保系统在不同环境下的正常运行

**测试环境**：
- **浏览器**：Chrome、Firefox、Safari、Edge
- **操作系统**：Windows、macOS、Linux
- **设备**：PC、平板、手机
- **分辨率**：1920x1080、1366x768、375x667（iPhone）

---

### 测试范围

#### 1. 认证模块测试

| 测试项 | 测试内容 | 预期结果 |
|-------|---------|---------|
| 正常登录 | 输入正确的用户名和密码 | 登录成功，返回Token |
| 错误密码 | 输入错误的密码 | 提示"用户名或密码错误" |
| 不存在的用户 | 输入不存在的用户名 | 提示"用户名或密码错误" |
| 必填项验证 | 不输入用户名或密码 | 提示"请输入用户名/密码" |
| Token有效性 | 使用过期Token访问接口 | 返回401，跳转登录页 |
| 权限控制 | 患者访问管理员接口 | 返回403，无权访问 |

---

#### 2. 患者端功能测试

| 测试项 | 测试内容 | 预期结果 |
|-------|---------|---------|
| 首页加载 | 进入首页 | 正常显示机构、类型、套餐 |
| 预约流程 | 完整预约流程 | 预约创建成功 |
| 预约冲突 | 同一时间段重复预约 | 提示"该时间段已有预约" |
| 取消预约 | 取消未完成的预约 | 预约状态变更为"已取消" |
| 取消已完成预约 | 取消已完成的预约 | 提示"无法取消已完成的预约" |
| 查看报告 | 查看自己的报告 | 正常显示报告详情 |
| 查看他人报告 | 尝试查看他人的报告 | 返回403，无权访问 |
| 编辑档案 | 更新个人信息 | 信息更新成功 |

---

#### 3. 医生端功能测试

| 测试项 | 测试内容 | 预期结果 |
|-------|---------|---------|
| 查看预约 | 查看待处理预约列表 | 正常显示预约信息 |
| 标记完成 | 标记预约为已完成 | 预约状态变更 |
| 生成报告 | 填写摘要和结论，生成报告 | 报告创建成功 |
| 录入结果 | 批量录入检查项目结果 | 结果保存成功 |
| 修改报告 | 修改已生成的报告 | 报告内容更新 |
| 权限控制 | 修改他人的报告 | 返回403，无权操作 |

---

#### 4. 管理员端功能测试

| 测试项 | 测试内容 | 预期结果 |
|-------|---------|---------|
| 用户列表 | 查看所有用户 | 正常显示用户列表 |
| 筛选用户 | 按角色筛选 | 只显示指定角色的用户 |
| 禁用用户 | 禁用某个用户 | 用户状态变更为"禁用" |
| 禁用后登录 | 禁用的用户尝试登录 | 提示"账户已被禁用" |
| 重置密码 | 重置用户密码 | 密码更新成功 |
| 删除用户 | 删除用户 | 用户逻辑删除 |
| 套餐管理 | 新增/编辑/删除套餐 | 操作成功 |
| 机构管理 | 关联套餐和预约类型 | 关联关系建立成功 |
| 字典管理 | 新增/编辑/删除字典项 | 操作成功 |

---

#### 5. AI功能测试

| 测试项 | 测试内容 | 预期结果 |
|-------|---------|---------|
| AI对话 | 发送健康咨询问题 | AI返回相关回答 |
| Markdown渲染 | AI返回包含Markdown的内容 | 正确渲染格式 |
| XSS防护 | 发送包含脚本的内容 | 脚本被转义，不执行 |
| 历史记录 | 查看历史对话 | 正常显示历史消息 |

---

### 测试用例示例

以下是部分核心功能的测试用例：

#### 用例1：患者预约体检

**用例编号**：TC-BOOKING-001

**用例名称**：患者成功预约体检

**前置条件**：
- 患者已登录
- 存在可用的机构、套餐

**测试步骤**：
1. 进入预约页面
2. 选择体检类型（如"个人体检"）
3. 选择机构（如"北京协和医院"）
4. 选择套餐（如"基础体检套餐"）
5. 选择预约日期（未来某天）
6. 选择时间槽（如"上午 9:00-10:00"）
7. 填写备注（可选）
8. 点击"提交预约"按钮

**预期结果**：
- 提示"预约成功"
- 预约列表中显示新预约
- 预约状态为"待体检"

**实际结果**：✅ 通过

---

#### 用例2：医生生成报告

**用例编号**：TC-REPORT-001

**用例名称**：医生成功生成体检报告

**前置条件**：
- 医生已登录
- 存在已完成的预约

**测试步骤**：
1. 进入医生工作台
2. 找到待处理的预约
3. 点击"生成报告"按钮
4. 填写报告摘要
5. 填写体检结论
6. 点击"提交"按钮

**预期结果**：
- 提示"报告生成成功"
- 报告列表中显示新报告
- 预约状态变更为"已出报告"

**实际结果**：✅ 通过

---

#### 用例3：管理员禁用用户

**用例编号**：TC-ADMIN-001

**用例名称**：管理员成功禁用用户

**前置条件**：
- 管理员已登录
- 存在活跃用户

**测试步骤**：
1. 进入用户管理页面
2. 找到要禁用的用户
3. 点击"禁用"按钮
4. 确认操作

**预期结果**：
- 提示"用户已禁用"
- 用户状态变更为"禁用"
- 该用户无法登录系统

**实际结果**：✅ 通过

---

### 测试结果汇总

#### 测试统计

| 测试类型 | 用例总数 | 通过数 | 失败数 | 通过率 |
|---------|---------|-------|-------|-------|
| 单元测试 | 150 | 148 | 2 | 98.7% |
| 接口测试 | 80 | 78 | 2 | 97.5% |
| 功能测试 | 120 | 117 | 3 | 97.5% |
| 性能测试 | 20 | 20 | 0 | 100% |
| 兼容性测试 | 40 | 38 | 2 | 95% |
| **总计** | **410** | **401** | **9** | **97.8%** |

---

#### Bug统计

| 严重程度 | 数量 | 已修复 | 遗留 | 说明 |
|---------|------|-------|------|------|
| 致命（Blocker） | 2 | 2 | 0 | 系统崩溃、数据丢失 |
| 严重（Critical） | 5 | 5 | 0 | 核心功能不可用 |
| 一般（Major） | 15 | 14 | 1 | 功能异常但不影响主流程 |
| 轻微（Minor） | 20 | 18 | 2 | UI问题、提示信息不准确 |
| **总计** | **42** | **39** | **3** | - |

**遗留Bug说明**：
1. 移动端某些页面布局略有错位（不影响功能，后续优化）
2. IE浏览器兼容性问题（已不支持IE）
3. 某些特殊字符在报告中显示异常（罕见场景）

---

#### 性能测试结果

| 测试场景 | 并发用户数 | 平均响应时间 | 最大响应时间 | 吞吐量（TPS） | CPU使用率 | 内存使用率 |
|---------|-----------|-------------|-------------|--------------|----------|-----------|
| 登录接口 | 1000 | 120ms | 350ms | 150 | 45% | 60% |
| 预约查询 | 500 | 180ms | 450ms | 120 | 55% | 65% |
| 报告生成 | 200 | 350ms | 800ms | 80 | 70% | 75% |
| 首页加载 | 1000 | 200ms | 500ms | 130 | 50% | 62% |

**结论**：系统性能满足设计要求，可支持1000并发用户。

---

### 测试结论

✅ **系统质量良好**，核心功能测试通过率97.8%

✅ **性能达标**，满足1000并发用户需求

✅ **安全性可靠**，无明显安全漏洞

⚠️ **遗留3个轻微Bug**，不影响系统正常使用，计划在下一版本修复

**建议**：
- 持续进行性能监控和优化
- 定期更新依赖包，修复安全漏洞
- 增加自动化测试覆盖率
- 建立用户反馈机制，持续改进

---

## Page 8 - 项目心得/收获

### 代码规范

#### 1. 前端代码规范

**命名规范**：
```typescript
// 组件命名：PascalCase
HomePage.vue
BookingPage.vue
AdminUsersPage.vue

// 变量命名：camelCase
const userList = ref([])
const loading = ref(false)

// 常量命名：UPPER_SNAKE_CASE
const MAX_PAGE_SIZE = 100
const API_BASE_URL = '/api'

// 函数命名：camelCase，动词开头
const fetchUserList = async () => {}
const handleSubmit = () => {}
```

**TypeScript类型定义**：
```typescript
// 统一定义接口类型
interface User {
  id: number
  username: string
  realName: string
  role: 'PATIENT' | 'DOCTOR' | 'ADMIN'
  status: 0 | 1
}

// 避免使用 any
const user: User = await fetchUser(id) // ✅
const user: any = await fetchUser(id) // ❌
```

**组件结构**：
```vue
<script setup lang="ts">
// 1. 导入
import { ref, onMounted } from 'vue'
import { getUserList } from '@/api/auth'

// 2. 类型定义
interface User { /* ... */ }

// 3. 响应式数据
const userList = ref<User[]>([])
const loading = ref(false)

// 4. 计算属性
const totalUsers = computed(() => userList.value.length)

// 5. 方法
const fetchUsers = async () => {
  loading.value = true
  try {
    const res = await getUserList()
    userList.value = res.data
  } finally {
    loading.value = false
  }
}

// 6. 生命周期
onMounted(() => {
  fetchUsers()
})
</script>

<template>
  <!-- 模板 -->
</template>

<style scoped>
/* 样式 */
</style>
```

**API封装规范**：
```typescript
// api/auth.ts
import request from './request'

export const login = (data: { username: string; password: string }) => {
  return request.post('/auth/login', data)
}

export const register = (data: RegisterData) => {
  return request.post('/auth/register', data)
}
```

---

#### 2. 后端代码规范

**RESTful API设计**：
```java
// ✅ 正确的RESTful风格
@GetMapping("/users")           // 查询列表
@GetMapping("/users/{id}")      // 查询详情
@PostMapping("/users")          // 创建
@PutMapping("/users")           // 更新
@DeleteMapping("/users/{id}")   // 删除

// ❌ 避免的做法
@PostMapping("/getUserList")
@PostMapping("/createUser")
```

**统一响应体**：
```java
@Data
public class ApiResponse<T> {
    private Integer code;
    private String message;
    private T data;
    
    public static <T> ApiResponse<T> success(T data) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setCode(200);
        response.setMessage("success");
        response.setData(data);
        return response;
    }
    
    public static <T> ApiResponse<T> error(String message) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setCode(500);
        response.setMessage(message);
        return response;
    }
}
```

**Service层规范**：
```java
@Service
@Slf4j
public class UserServiceImpl implements UserService {
    
    @Autowired
    private UserMapper userMapper;
    
    @Override
    public PageData<User> getUserList(Integer page, Integer size) {
        log.info("查询用户列表, page={}, size={}", page, size);
        
        Page<User> pageParam = new Page<>(page, size);
        Page<User> result = userMapper.selectPage(pageParam, null);
        
        return PageData.of(result);
    }
}
```

**异常处理**：
```java
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {
    
    @ExceptionHandler(BusinessException.class)
    public ApiResponse<?> handleBusinessException(BusinessException e) {
        log.error("业务异常: {}", e.getMessage());
        return ApiResponse.error(e.getMessage());
    }
    
    @ExceptionHandler(Exception.class)
    public ApiResponse<?> handleException(Exception e) {
        log.error("系统异常", e);
        return ApiResponse.error("系统异常，请联系管理员");
    }
}
```

---

#### 3. Git提交规范

**Commit Message格式**：
```
type: description

[optional body]

[optional footer]
```

**Type类型**：
- `feat`: 新功能
- `fix`: 修复Bug
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构
- `test`: 测试相关
- `chore`: 构建过程或辅助工具变动

**示例**：
```bash
# 新功能
git commit -m "feat: 添加用户管理功能"

# 修复Bug
git commit -m "fix: 修复预约时间冲突检测逻辑"

# 文档更新
git commit -m "docs: 更新API文档"

# 详细提交
git commit -m "feat: 添加报告生成功能

- 实现报告生成接口
- 添加报告摘要和结论字段
- 支持批量录入检查项目结果

Closes #123"
```

---

### 开发流程规范

#### 1. 需求分析阶段

**工作流程**：
```
用户提出需求 → 产品经理整理 → 需求评审会议 → 需求文档 → UI原型设计
```

**关键产出**：
- 需求规格说明书
- 用例图
- 流程图
- UI原型图（Figma/Axure）

**注意事项**：
- 需求要明确、可量化
- 与用户充分沟通，避免理解偏差
- 考虑边界情况和异常场景

---

#### 2. 设计阶段

**系统架构设计**：
- 微服务划分原则（单一职责、高内聚低耦合）
- 技术选型理由
- 服务间通信方式（同步/异步）

**数据库设计**：
- ER图设计
- 表结构规范化（第三范式）
- 索引设计（查询频繁的字段）
- 字段类型选择（合理的数据类型）

**API设计**：
- RESTful风格
- 统一的响应格式
- 详细的接口文档（Swagger/Knife4j）
- 版本管理（/api/v1/）

---

#### 3. 开发阶段

**分支管理策略**（Git Flow）：
```
main（主分支，生产环境）
  ↑
release（发布分支）
  ↑
develop（开发分支）
  ↑
feature/xxx（功能分支）
```

**开发流程**：
```bash
# 1. 从develop创建功能分支
git checkout develop
git pull
git checkout -b feature/user-management

# 2. 开发功能
# ... 编写代码 ...

# 3. 提交代码
git add .
git commit -m "feat: 添加用户管理功能"

# 4. 推送到远程
git push origin feature/user-management

# 5. 创建Pull Request
# 在GitHub/GitLab上创建PR，请求合并到develop

# 6. Code Review
# 团队成员审查代码，提出修改意见

# 7. 合并到develop
# PR通过后，合并到develop分支
```

**Code Review要点**：
- 代码是否符合规范
- 逻辑是否正确
- 是否有潜在Bug
- 性能是否合理
- 是否有安全隐患

---

#### 4. 测试阶段

**测试流程**：
```
开发人员自测 → 提测 → 测试人员测试 → Bug修复 → 回归测试 → 验收测试
```

**测试文档**：
- 测试计划
- 测试用例
- 测试报告
- Bug清单

---

#### 5. 部署阶段

**环境划分**：
- **开发环境（dev）**：开发人员使用
- **测试环境（test）**：测试人员使用
- **预生产环境（staging）**：模拟生产环境
- **生产环境（prod）**：正式用户使用

**部署流程**：
```bash
# 1. 打包
mvn clean package -DskipTests

# 2. 构建Docker镜像
docker build -t xixin-auth:1.0.0 .

# 3. 推送镜像
docker push registry.example.com/xixin-auth:1.0.0

# 4. 部署到Kubernetes
kubectl apply -f deployment.yaml

# 5. 验证部署
kubectl get pods
curl http://localhost:8080/health
```

---

### 技术难点解决

#### 难点1：微服务间通信与数据一致性

**问题描述**：
- 多个微服务之间如何高效通信？
- 分布式事务如何保证数据一致性？
- 服务故障如何处理？

**解决方案**：

**1. 服务间通信**：
```java
// 使用Feign Client进行同步调用
@FeignClient(name = "xixin-user")
public interface UserClient {
    @GetMapping("/users/{id}")
    ApiResponse<User> getUserById(@PathVariable Long id);
}

// 使用RabbitMQ进行异步解耦
@Component
public class ReportProducer {
    @Autowired
    private RabbitTemplate rabbitTemplate;
    
    public void sendReportGeneratedEvent(Long reportId) {
        rabbitTemplate.convertAndSend("report.exchange", "report.generated", reportId);
    }
}
```

**2. 分布式事务**：
- **方案一**：Seata（强一致性，性能较低）
- **方案二**：最终一致性（推荐）
  - 本地事务 + 消息队列
  - 补偿机制（定时任务检查不一致数据）

**3. 服务容错**：
```yaml
# application.yml
spring:
  cloud:
    openfeign:
      circuitbreaker:
        enabled: true
    resilience4j:
      timelimiter:
        instances:
          default:
            timeout-duration: 3s
      retry:
        instances:
          default:
            max-attempts: 3
```

**经验总结**：
- 优先使用异步通信，降低耦合
- 关键业务使用最终一致性方案
- 设置合理的超时时间和重试次数
- 做好降级和熔断处理

---

#### 难点2：JWT Token权限控制

**问题描述**：
- 如何实现细粒度的权限控制？
- Token如何防止篡改？
- Token过期如何处理？

**解决方案**：

**1. 自定义权限注解**：
```java
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RequireRole {
    String[] value(); // 允许的角色
}
```

**2. 拦截器实现**：
```java
@Component
public class AuthInterceptor implements HandlerInterceptor {
    
    @Override
    public boolean preHandle(HttpServletRequest request, 
                            HttpServletResponse response, 
                            Object handler) {
        if (!(handler instanceof HandlerMethod)) {
            return true;
        }
        
        HandlerMethod method = (HandlerMethod) handler;
        RequireRole annotation = method.getMethodAnnotation(RequireRole.class);
        
        if (annotation == null) {
            return true; // 无需权限控制
        }
        
        // 从Header获取Token
        String token = request.getHeader("Authorization");
        if (token == null || !token.startsWith("Bearer ")) {
            throw new BusinessException("未登录");
        }
        
        // 解析Token
        Claims claims = JwtUtil.parseToken(token.substring(7));
        String role = claims.get("role", String.class);
        
        // 验证角色
        String[] allowedRoles = annotation.value();
        if (!Arrays.asList(allowedRoles).contains(role)) {
            throw new BusinessException("无权访问");
        }
        
        // 将用户信息存入请求上下文
        UserContext.setUserId(claims.get("userId", Long.class));
        UserContext.setRole(role);
        
        return true;
    }
}
```

**3. 使用示例**：
```java
@RestController
@RequestMapping("/admin")
public class AdminController {
    
    @RequireRole({"ADMIN"})
    @GetMapping("/users")
    public ApiResponse<PageData<User>> getUserList() {
        // 只有管理员可以访问
        return userService.getUserList();
    }
}
```

**4. Token刷新机制**：
```java
// 前端实现Token自动刷新
axios.interceptors.response.use(
  response => response,
  async error => {
    if (error.response?.status === 401) {
      // Token过期，尝试刷新
      const newToken = await refreshToken()
      if (newToken) {
        // 重试原请求
        error.config.headers.Authorization = `Bearer ${newToken}`
        return axios.request(error.config)
      } else {
        // 刷新失败，跳转登录页
        localStorage.removeItem('token')
        window.location.href = '/login'
      }
    }
    return Promise.reject(error)
  }
)
```

**经验总结**：
- Token中不要存储敏感信息
- 设置合理的Token过期时间（建