# 健康检查系统 - 前端功能与接口说明文档

## 项目概述

本项目是一个基于 Vue 3 + TypeScript + Element Plus 的健康体检预约管理系统，采用前后端分离架构。

---

## 一、功能模块清单

### 1. 用户认证模块（所有角色）

#### 功能描述
- **登录**：用户名密码登录，支持三种角色（患者/医生/管理员）
- **注册**：新用户注册，默认角色为患者
- **头像上传**：更新用户头像

#### 使用组件
- `LoginPage.vue` - 登录页面
- `ProfilePage.vue` - 个人中心（患者）
- `DoctorProfilePage.vue` - 医生个人中心

#### 后端接口
| 接口名称 | 请求方法 | URL | 参数 | 说明 |
|---------|---------|-----|------|------|
| 用户登录 | POST | `/api/auth/login` | `{username, password}` | 返回 token 和用户信息 |
| 用户注册 | POST | `/api/auth/register` | `{username, password, realName, phone, role?}` | 默认 role="PATIENT" |
| 更新头像 | PUT | `/api/user/avatar` | `{avatarUrl}` | 从 Token 获取 userId |

---

### 2. 患者端功能

#### 2.1 首页（HomePage.vue）

**功能描述**：展示推荐机构、热门体检类型、热门套餐

**数据加载流程**：
1. 加载已启用的机构列表 → `getActiveInstitutions()`
2. 加载体检类型字典 → `getDictItemsByType(4)`
3. 加载套餐列表 → `getPackageList(1, 10)`

**后端接口**：
| 接口名称 | 请求方法 | URL | 参数 | 说明 |
|---------|---------|-----|------|------|
| 查询已启用机构 | GET | `/api/exam/institutions/active` | 无 | 返回数组 |
| 查询字典项 | GET | `/api/exam/dict-items/type/{typeId}` | `typeId=4` | 体检类型字典 |
| 分页查询套餐 | GET | `/api/exam/packages?page=1&size=10` | page, size | 过滤 status=1 |
| 查询机构详情 | GET | `/api/exam/institutions/{id}` | id | 弹窗显示 |
| 查询套餐详情 | GET | `/api/exam/packages/{id}` | id | 包含检查项目列表 |

---

#### 2.2 预约功能（BookingPage.vue）

**功能描述**：选择体检类型 → 选择机构 → 选择套餐 → 确认订单 → 提交预约

**业务流程**：
```
1. 根据体检类型查询机构列表
   ↓
2. 根据机构查询可用套餐列表
   ↓
3. 查看套餐详情（可选）
   ↓
4. 填写预约日期和备注
   ↓
5. 提交预约（userId 从 Token 自动获取）
```

**后端接口**：
| 接口名称 | 请求方法 | URL | 参数 | 说明 |
|---------|---------|-----|------|------|
| 按类型查机构 | GET | `/api/exam/appointment-types/{type}/institutions` | type | 返回数组 |
| 按机构查套餐 | GET | `/api/exam/institutions/{institutionId}/packages` | institutionId | 返回数组 |
| 查询套餐详情 | GET | `/api/exam/packages/{id}` | id | 查看详情 |
| 创建预约 | POST | `/api/exam/appointments` | `{packageId, institutionId?, appointmentDate, timeSlot?, remark?}` | userId 从 Token 获取 |

---

#### 2.3 个人中心（ProfilePage.vue）

**功能描述**：查看个人信息、我的预约、我的报告、编辑档案

**子功能**：
- **我的预约**：查看预约列表、取消预约
- **我的报告**：查看报告列表、查看报告详情、查看检查项目明细
- **编辑档案**：更新患者基本信息（姓名、性别、年龄、电话等）

**后端接口**：
| 接口名称 | 请求方法 | URL | 参数 | 说明 |
|---------|---------|-----|------|------|
| 查询预约列表 | GET | `/api/exam/appointments?page=1&size=10` | page, size | PATIENT 返回数组，其他返回 PageData |
| 取消预约 | PUT | `/api/exam/appointments/{id}/cancel` | id | 只能取消自己的预约 |
| 查询报告列表 | GET | `/api/report/list?page=1&size=10` | page, size | 分页对象 |
| 查询报告详情 | GET | `/api/report/{id}` | id | 包含 summary、conclusion |
| 查询报告项目明细 | GET | `/api/report/{reportId}/items/all` | reportId | 返回数组 |
| 查询患者详情 | GET | `/api/user/patients/{id}` | id | 个人档案 |
| 更新患者档案 | PUT | `/api/user/patients/{id}` | `{realName, gender, age, phone, ...}` | 部分字段 |

---

### 3. 医生端功能

#### 3.1 工作台（DoctorHomePage.vue）

**功能描述**：查看待处理预约、生成报告、录入检查结果

**业务流程**：
```
1. 查看待处理预约列表
   ↓
2. 标记体检完成（可选）
   ↓
3. 生成报告（填写摘要、结论）
   ↓
4. 批量录入检查项目结果
```

**后端接口**：
| 接口名称 | 请求方法 | URL | 参数 | 说明 |
|---------|---------|-----|------|------|
| 查询预约列表 | GET | `/api/exam/appointments?page=1&size=10` | page, size | DOCTOR 返回 PageData |
| 标记体检完成 | PUT | `/api/exam/appointments/{id}/complete` | id | 医生操作 |
| 生成报告 | POST | `/api/report/generate` | `{userId, appointmentId, summary, conclusion}` | 直接发布 |
| 批量录入项目 | POST | `/api/report/{reportId}/items/batch` | reportId, items[] | 批量插入 |
| 查询套餐详情 | GET | `/api/exam/packages/{id}` | id | 查看套餐包含的项目 |
| 查询患者详情 | GET | `/api/user/patients/{id}` | id | 查看患者信息 |

---

#### 3.2 报告管理（DoctorReportsPage.vue）

**功能描述**：查看已生成的报告、修改报告内容、修改检查项目结果

**后端接口**：
| 接口名称 | 请求方法 | URL | 参数 | 说明 |
|---------|---------|-----|------|------|
| 查询报告列表 | GET | `/api/report/list?page=1&size=10` | page, size | 分页对象 |
| 查询报告详情 | GET | `/api/report/{id}` | id | 报告基本信息 |
| 查询报告项目明细 | GET | `/api/report/{reportId}/items/all` | reportId | 所有检查项目 |
| 修改报告 | PUT | `/api/report/{id}` | `{summary?, conclusion?}` | 部分更新 |
| 修改检查项 | PUT | `/api/report/{reportId}/items/{itemId}` | `{result?, referenceRange?, abnormalFlag?}` | 单个项目 |
| 查询预约列表 | GET | `/api/exam/appointments?page=1&size=10` | page, size | 关联预约 |

---

#### 3.3 医生个人中心（DoctorProfilePage.vue）

**功能描述**：查看医生信息、更新头像、快捷跳转

**后端接口**：
| 接口名称 | 请求方法 | URL | 参数 | 说明 |
|---------|---------|-----|------|------|
| 查询医生详情 | GET | `/api/user/doctors/{id}` | id | 医生档案 |
| 更新头像 | PUT | `/api/user/avatar` | `{avatarUrl}` | 通用接口 |

---

### 4. 管理员端功能

#### 4.1 用户管理（AdminUsersPage.vue）

**功能描述**：查看所有用户、筛选用户类型、编辑用户信息、重置密码、删除用户

**后端接口**：
| 接口名称 | 请求方法 | URL | 参数 | 说明 |
|---------|---------|-----|------|------|
| 查询用户列表 | GET | `/api/auth/users?page=1&size=10&keyword=&role=` | page, size, keyword, role | 支持角色筛选 |
| 更新用户信息 | PUT | `/api/auth/users/{id}` | `{realName, phone, email, ...}` | 部分字段 |
| 更新用户状态 | PUT | `/api/auth/users/{id}/status?status={0|1}` | id, status | 禁用/启用 |
| 重置密码 | PUT | `/api/auth/users/{id}/password` | `{newPassword}` | 管理员操作 |
| 删除用户 | DELETE | `/api/auth/users/{id}` | id | 逻辑删除 |
| 查询患者详情 | GET | `/api/user/patients/{id}` | id | 查看详细信息 |
| 查询医生详情 | GET | `/api/user/doctors/{id}` | id | 查看详细信息 |

---

#### 4.2 套餐管理（AdminPackagesPage.vue）

**功能描述**：管理体检套餐、管理套餐下的检查项目

**子功能**：
- **套餐 CRUD**：新增、编辑、启用/禁用、删除套餐
- **检查项目管理**：为套餐添加/删除检查项目

**后端接口**：
| 接口名称 | 请求方法 | URL | 参数 | 说明 |
|---------|---------|-----|------|------|
| 分页查询套餐 | GET | `/api/exam/packages?page=1&size=10` | page, size | 分页对象 |
| 查询套餐详情 | GET | `/api/exam/packages/{id}` | id | 包含检查项目列表 |
| 创建套餐 | POST | `/api/exam/packages` | `{name, price, description, status, sortOrder}` | 完整对象 |
| 更新套餐 | PUT | `/api/exam/packages` | `{id, name, price, ...}` | 需传 id |
| 切换套餐状态 | PUT | `/api/exam/packages/{id}/status?status={0|1}` | id, status | 启用/禁用 |
| 删除套餐 | DELETE | `/api/exam/packages/{id}` | id | 逻辑删除 |
| 查询检查项目 | GET | `/api/exam/packages/{packageId}/items?page=1&size=10` | packageId, page, size | 分页对象 |
| 创建检查项目 | POST | `/api/exam/packages/{packageId}/items` | packageId, `{name, category, sortOrder}` | 完整对象 |
| 更新检查项目 | PUT | `/api/exam/packages/{packageId}/items/{id}` | packageId, id, `{name, category, ...}` | 需传 id |
| 删除检查项目 | DELETE | `/api/exam/packages/{packageId}/items/{id}` | packageId, id | 物理删除 |

---

#### 4.3 机构管理（AdminInstitutionsPage.vue）

**功能描述**：管理体检机构、关联套餐、关联预约类型

**子功能**：
- **机构 CRUD**：新增、编辑、删除机构
- **套餐关联**：为机构关联多个套餐
- **预约类型关联**：为机构配置支持的预约类型（个人体检、团体体检等）

**后端接口**：
| 接口名称 | 请求方法 | URL | 参数 | 说明 |
|---------|---------|-----|------|------|
| 分页查询机构 | GET | `/api/exam/institutions?page=1&size=10` | page, size | 分页对象 |
| 查询机构详情 | GET | `/api/exam/institutions/{id}` | id | 包含关联套餐 |
| 创建机构 | POST | `/api/exam/institutions` | `{name, address, phone, businessHours, description, status, sortOrder}` | 完整对象 |
| 更新机构 | PUT | `/api/exam/institutions` | `{id, name, address, ...}` | 需传 id |
| 删除机构 | DELETE | `/api/exam/institutions/{id}` | id | 逻辑删除 |
| 查询机构套餐 | GET | `/api/exam/institution-packages?institutionId={id}` | institutionId | 返回数组 |
| 关联套餐 | POST | `/api/exam/institution-packages` | `{institutionId, packageId}` | 多对多关系 |
| 取消关联 | DELETE | `/api/exam/institution-packages/{id}` | id | 删除关联记录 |
| 查询所有套餐 | GET | `/api/exam/packages?page=1&size=100` | page, size | 用于选择 |
| 查询机构预约类型 | GET | `/api/exam/appt-type-institutions?institutionId={id}` | institutionId | 返回数组 |
| 关联预约类型 | POST | `/api/exam/appt-type-institutions` | `{institutionId, apptType}` | apptType 为字典项 value |
| 取消关联预约类型 | DELETE | `/api/exam/appt-type-institutions/{id}` | id | 删除关联记录 |
| 查询预约类型字典 | GET | `/api/exam/dict-items/type/4?page=1&size=20` | typeId=4 | 获取可用预约类型列表 |

---

#### 4.4 字典管理（AdminDictPage.vue）

**功能描述**：管理字典类型、管理字典项（左右分栏布局，移动端垂直排列）

**子功能**：
- **字典类型 CRUD**：新增、编辑、删除字典类型
- **字典项 CRUD**：为字典类型添加/编辑/删除字典项

**后端接口**：
| 接口名称 | 请求方法 | URL | 参数 | 说明 |
|---------|---------|-----|------|------|
| 分页查询字典类型 | GET | `/api/system/dict-types?page=1&size=10` | page, size | 分页对象 |
| 查询字典类型详情 | GET | `/api/system/dict-types/{id}` | id | 单个对象 |
| 创建字典类型 | POST | `/api/system/dict-types` | `{dictName, dictType, status, remark}` | 完整对象 |
| 更新字典类型 | PUT | `/api/system/dict-types` | `{id, dictName, dictType, status, remark}` | 需传 id |
| 删除字典类型 | DELETE | `/api/system/dict-types/{id}` | id | 逻辑删除 |
| 分页查询字典项 | GET | `/api/system/dict-items/by-type/{typeId}?page=1&size=20` | typeId, page, size | 分页对象 |
| 查询字典项详情 | GET | `/api/system/dict-items/{id}` | id | 单个对象 |
| 创建字典项 | POST | `/api/system/dict-items` | `{dictTypeId, label, value, sortOrder, status, remark}` | 完整对象 |
| 更新字典项 | PUT | `/api/system/dict-items` | `{id, label, value, sortOrder, status, remark}` | 需传 id |
| 删除字典项 | DELETE | `/api/system/dict-items/{id}` | id | 物理删除 |

---

### 5. AI 聊天功能（AIChatWidget.vue）

**功能描述**：悬浮窗形式的 AI 助手，支持 Markdown 格式渲染

**使用场景**：患者端和医生端可见，管理员端隐藏

**后端接口**：
| 接口名称 | 请求方法 | URL | 参数 | 说明 |
|---------|---------|-----|------|------|
| AI 对话 | POST | `/api/ai/chat` | `{message, history?}` | 返回 AI 回复，支持 Markdown |

---

### 6. 文件上传功能

**功能描述**：上传图片文件（头像等）

**后端接口**：
| 接口名称 | 请求方法 | URL | 参数 | 说明 |
|---------|---------|-----|------|------|
| 上传文件 | POST | `/api/file/upload` | FormData(file) | 返回文件 URL |

---

## 二、未使用的后端接口

以下后端接口在前端代码中**未被调用**：

### 1. 预约相关
- ❌ `GET /api/exam/appointments/{id}` - 查询预约详情（前端未单独调用）
- ❌ `PUT /api/exam/appointments/{id}/complete` - 标记体检完成（仅医生端使用，但代码中存在）

### 2. 报告相关
- ✅ 所有报告接口均已使用

### 3. 机构相关
- ❌ `GET /api/exam/institutions/{id}` - 查询机构详情（仅在 HomePage 弹窗中使用）

### 4. 字典相关
- ❌ `GET /api/exam/dict-types/{id}` - 查询字典类型详情（前端未调用）
-  `GET /api/exam/dict-items/{id}` - 查询字典项详情（前端未调用）

### 5. 患者/医生相关
- ❌ 部分详细查询接口可能未在特定场景使用

---

## 三、技术栈说明

### 前端技术栈
- **框架**：Vue 3 (Composition API + `<script setup>`)
- **语言**：TypeScript
- **构建工具**：Vite
- **UI 组件库**：Element Plus
- **状态管理**：Pinia
- **HTTP 客户端**：Axios
- **路由**：无（单页应用，Tab 切换）

### 后端技术栈（参考）
- **框架**：Spring Boot + Spring Cloud
- **注册中心**：Nacos Discovery
- **配置中心**：Nacos Config
- **网关**：Spring Cloud Gateway
- **数据库**：MySQL + MyBatis-Plus
- **消息队列**：RabbitMQ
- **文件存储**：MinIO
- **AI 集成**：Spring AI + RAG（通义千问）

---

## 四、权限控制说明

### 角色定义
- **PATIENT**（患者）：普通用户，可预约、查看报告
- **DOCTOR**（医生）：可查看预约、生成报告、录入结果
- **ADMIN**（管理员）：全权限，可管理用户、套餐、机构、字典

### 前端权限控制
```typescript
// App.vue 中根据角色显示不同页面
const isAdmin = computed(() => userStore.user?.role === 'ADMIN')
const isDoctor = computed(() => userStore.user?.role === 'DOCTOR')

// 管理员端
<template v-if="isAdmin">
  <AdminUsersPage v-show="currentTab === 'users'" />
  <AdminPackagesPage v-show="currentTab === 'packages'" />
  <AdminInstitutionsPage v-show="currentTab === 'institutions'" />
  <AdminDictPage v-show="currentTab === 'dicts'" />
</template>

// 患者端
<template v-else-if="!isDoctor">
  <HomePage v-show="currentTab === 'home'" />
  <BookingPage v-show="currentTab === 'booking'" />
  <ProfilePage v-show="currentTab === 'profile'" />
</template>

// 医生端
<template v-else>
  <DoctorHomePage v-show="currentTab === 'workbench'" />
  <DoctorReportsPage v-show="currentTab === 'reports'" />
  <DoctorProfilePage v-show="currentTab === 'profile'" />
</template>
```

### 后端权限控制
- 使用 `@RequireRole` 注解进行接口级权限控制
- Token 中携带用户信息和角色
- 网关层统一鉴权

---

## 五、数据流转说明

### 典型业务流程示例：患者预约体检

```
1. 患者登录
   POST /api/auth/login
   ↓ 返回 token + userInfo

2. 首页加载数据
   GET /api/exam/institutions/active
   GET /api/exam/dict-items/type/4
   GET /api/exam/packages?page=1&size=10
   ↓ 显示机构、类型、套餐

3. 选择体检类型
   点击类型卡片 → 进入预约页面

4. 根据类型查询机构
   GET /api/exam/appointment-types/{type}/institutions
   ↓ 显示该类型支持的机构

5. 选择机构后查询套餐
   GET /api/exam/institutions/{institutionId}/packages
   ↓ 显示该机构的可用套餐

6. 确认预约信息
   填写日期、时间、备注

7. 提交预约
   POST /api/exam/appointments
   Body: { packageId, institutionId, appointmentDate, timeSlot, remark }
   ↓ 后端从 Token 提取 userId
   ↓ 创建预约记录

8. 查看我的预约
   GET /api/exam/appointments?page=1&size=10
   ↓ 显示预约列表
```

---

## 六、注意事项

### 1. 响应格式统一
所有接口返回格式：
```typescript
interface ApiResponse<T> {
  code: number      // 200 成功，其他失败
  message: string   // 提示信息
  data: T           // 业务数据
}
```

### 2. 分页格式
```typescript
interface PageData<T> {
  total: number     // 总记录数
  page: number      // 当前页码
  size: number      // 每页大小
  records: T[]      // 数据列表
}
```

### 3. Token 管理
- 登录后将 token 存储在 localStorage
- 每次请求在 Header 中携带 `Authorization: Bearer {token}`
- Token 过期后自动跳转到登录页

### 4. 错误处理
- 网络错误：显示友好提示
- 业务错误：显示后端返回的 message
- 权限错误：403 时提示无权访问

---

## 七、附录

### API 文件清单
```
src/api/
├── auth.ts              # 认证相关（登录、注册、用户管理）
├── appointment.ts       # 预约相关
├── report.ts            # 报告相关
├── package.ts           # 套餐相关
├── institution.ts       # 机构相关
├── institution-package.ts # 机构套餐关联
├── appt-type-institution.ts # 机构预约类型关联（新增）
├── examitem.ts          # 检查项目相关
├── patient.ts           # 患者档案
├── doctor.ts            # 医生档案
├── dict.ts              # 字典管理
├── ai.ts                # AI 对话
├── file.ts              # 文件上传
└── request.ts           # Axios 封装
```

### 组件文件清单
```
src/components/
├── LoginPage.vue        # 登录页
├── HomePage.vue         # 患者首页
├── BookingPage.vue      # 预约页
├── ProfilePage.vue      # 患者个人中心
├── DoctorHomePage.vue   # 医生工作台
├── DoctorReportsPage.vue # 医生报告管理
├── DoctorProfilePage.vue # 医生个人中心
├── AdminUsersPage.vue   # 用户管理
├── AdminPackagesPage.vue # 套餐管理
├── AdminInstitutionsPage.vue # 机构管理
├── AdminDictPage.vue    # 字典管理
├── AIChatWidget.vue     # AI 悬浮窗
└── App.vue              # 主应用（Tab 切换）
```

---

## 八、更新记录

| 日期 | 版本 | 更新内容 |
|------|------|----------|
| 2026-07-04 | v1.1 | 新增机构预约类型关联功能，更新 API 清单和接口说明 |
| 2026-07-04 | v1.0 | 初始版本，包含所有前端功能和接口说明 |

---

**文档说明**：本文档基于前端实际使用的接口编写，部分后端接口可能未被前端调用，请以实际代码为准。
