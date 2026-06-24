# 东软熙心健康体检管理系统 — API 接口文档

> **Base URL:** `http://localhost:8080` (统一通过网关访问)
> **最后更新:** 2026-06-12
> **鉴权方式:** 请求头 `Authorization: Bearer <accessToken>`

---

## 目录

- [1. 认证服务 (Auth)](#1-认证服务)
- [2. 套餐管理 (Packages)](#2-套餐管理)
- [3. 机构管理 (Institutions)](#3-机构管理)
- [4. 检查项目 (Exam Items)](#4-检查项目)
- [5. 预约管理 (Appointments)](#5-预约管理)
- [6. 报告管理 (Reports)](#6-报告管理)
- [7. 用户管理 (Users)](#7-用户管理)
- [8. 角色管理 (Roles)](#8-角色管理)
- [9. 字典维护 (Dict)](#9-字典维护)
- [10. 医生/患者档案查询](#10-医生患者档案查询)
- [11. 预约流程级联选择](#11-预约流程级联选择)
- [附录 A：统一响应格式](#附录-a统一响应格式)
- [附录 B：权限机制](#附录-b权限机制)
- [附录 C：数据隔离规则](#附录-c数据隔离规则)
- [附录 D：数据库表结构](#附录-d数据库表结构)

---

## 1. 认证服务

> **微服务:** `xixin-auth` (端口 8100) | **Controller:** `AuthController`

### 1.1 患者注册

```
POST /api/auth/register
```

**权限：** 公开（无需 Token）

**请求体：**

```json
{
  "username": "patient_test",
  "password": "123456",
  "realName": "测试患者丁",
  "role": "PATIENT",
  "phone": "13900009999",
  "email": "patient_test@test.com"
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|:--:|------|
| username | String | ✅ | 用户名（唯一） |
| password | String | ✅ | 密码（明文存储） |
| realName | String | ✅ | 真实姓名 |
| role | String | ✅ | `ADMIN` / `DOCTOR` / `PATIENT` |
| phone | String | | 手机号 |
| email | String | | 邮箱 |

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

### 1.2 登录

```
POST /api/auth/login
```

**权限：** 公开

**请求体：**

```json
{
  "username": "testuser01",
  "password": "123456"
}
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "accessToken": "eyJhbGciOiJIUzM4NCJ9.eyJyb2xlIjoiUEFUSUVOVCIsInVzZXJJZCI6MiwidXNlcm5hbWUiOiJ0ZXN0dXNlcjAxIiwic3ViIjoidGVzdHVzZXIwMSIsImlhdCI6MTc4MTIyNTM3OSwiZXhwIjoxNzgxMzExNzc5fQ.iCsP0zA...",
    "refreshToken": "eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJ0ZXN0dXNlcjAxIiwidXNlcklkIjoyLCJpYXQiOjE3ODEyMjUzNzksImV4cCI6MTc4MTgzMDE3OX0...",
    "expiresIn": 7200
  }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| accessToken | String | JWT 访问令牌，有效期 **24 小时** |
| refreshToken | String | 刷新令牌，有效期 7 天 |
| expiresIn | Integer | accessToken 过期时间（秒），实际为 86400（24h） |

**JWT 载荷：** `{ userId, username (sub), role }`，由网关 `AuthGlobalFilter` 校验后注入 `X-User-Id`、`X-Username`、`X-User-Role` 请求头至下游服务。

---

## 2. 套餐管理

> **微服务:** `xixin-exam` (端口 8120) | **Controller:** `ExamPackageController`
> **路径前缀:** `/api/exam/packages`

### 接口列表

| 方法 | 路径 | 权限 | 说明 |
|------|------|:--:|------|
| GET | `/api/exam/packages?page=1&size=10` | PATIENT, ADMIN | 分页查询套餐列表 |
| GET | `/api/exam/packages/{id}` | PATIENT, ADMIN | **查询套餐详情（内嵌检查项目）** |
| POST | `/api/exam/packages` | ADMIN | 新增套餐 |
| PUT | `/api/exam/packages` | ADMIN | 更新套餐 |
| PUT | `/api/exam/packages/{id}/status?status=0` | ADMIN | 上架/下架 |
| DELETE | `/api/exam/packages/{id}` | ADMIN | 删除（逻辑删除） |

---

### 2.1 套餐列表

```
GET /api/exam/packages?page=1&size=10
Authorization: Bearer <token>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "total": 0,
    "page": 1,
    "size": 10,
    "records": [
      {
        "id": 1,
        "name": "基础健康体检",
        "price": 199.00,
        "description": "血常规、尿常规、心电图三项基础检查",
        "doctorId": 3,
        "status": 1,
        "sortOrder": 1,
        "items": null
      },
      {
        "id": 3,
        "name": "高端全面体检",
        "price": 1299.00,
        "description": "标准项目+肿瘤标志物筛查+甲状腺彩超+低剂量螺旋CT",
        "doctorId": 3,
        "status": 1,
        "sortOrder": 3,
        "items": null
      }
    ]
  }
}
```

> **注意：** 列表接口 `items` 字段始终为 `null`，仅详情接口填充。

---

### 2.2 套餐详情（含检查项目）

```
GET /api/exam/packages/1
Authorization: Bearer <token>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "createTime": "2026-06-04T10:35:24",
    "updateTime": "2026-06-12T08:18:17",
    "deleted": 0,
    "name": "基础健康体检",
    "price": 199.00,
    "description": "血常规、尿常规、心电图三项基础检查",
    "doctorId": 3,
    "status": 1,
    "sortOrder": 1,
    "items": [
      {
        "id": 1,
        "packageId": 1,
        "name": "血常规",
        "type": "检验",
        "description": "白细胞、红细胞、血红蛋白、血小板等全血细胞计数",
        "sortOrder": 1
      },
      {
        "id": 2,
        "packageId": 1,
        "name": "尿常规",
        "type": "检验",
        "description": "尿液化学分析及显微镜检查",
        "sortOrder": 2
      },
      {
        "id": 3,
        "packageId": 1,
        "name": "十二导联心电图",
        "type": "心电",
        "description": "静息十二导联心电图检查",
        "sortOrder": 3
      }
    ]
  }
}
```

> **关键：** `items` 数组内嵌返回该套餐下所有检查项目，**前端无需额外请求**。

---

### 2.3 新增套餐

```
POST /api/exam/packages
Authorization: Bearer <adminToken>
Content-Type: application/json
```

**请求体：**

```json
{
  "name": "心脑血管专项检查",
  "price": 899.00,
  "description": "心脏彩超+颈动脉超声+血脂全套+同型半胱氨酸",
  "doctorId": 3,
  "status": 1,
  "sortOrder": 11
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|:--:|------|
| name | String | ✅ | 套餐名称 |
| price | BigDecimal | ✅ | 价格 |
| description | String | | 描述 |
| doctorId | Long | ✅ | **绑定医生用户ID。患者预约后自动分配给该医生** |
| status | Integer | | 0=下架, 1=上架（默认 1） |
| sortOrder | Integer | | 排序号 |

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

### 2.4 更新套餐

```
PUT /api/exam/packages
Authorization: Bearer <adminToken>
Content-Type: application/json
```

**请求体：**

```json
{
  "id": 7,
  "name": "心脑血管专项检查(加强版)",
  "price": 999.00,
  "doctorId": 3,
  "description": "加强版：增加24h动态心电图监测"
}
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

### 2.5 套餐上下架

```
PUT /api/exam/packages/7/status?status=0
Authorization: Bearer <adminToken>
```

| 参数 | 说明 |
|------|------|
| status=0 | 下架（患者不可见） |
| status=1 | 上架（患者可见） |

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

### 2.6 删除套餐

```
DELETE /api/exam/packages/7
Authorization: Bearer <adminToken>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

## 3. 机构管理

> **微服务:** `xixin-exam` (端口 8120) | **Controller:** `InstitutionController`
> **路径前缀:** `/api/exam/institutions`

### 接口列表

| 方法 | 路径 | 权限 | 说明 |
|------|------|:--:|------|
| GET | `/api/exam/institutions?page=1&size=10` | ADMIN | 全部机构列表（含已停用） |
| GET | `/api/exam/institutions/active` | PATIENT, ADMIN | 已启用机构列表 |
| GET | `/api/exam/institutions/{id}` | PATIENT, ADMIN | 机构详情 |
| POST | `/api/exam/institutions` | ADMIN | 新增机构 |
| PUT | `/api/exam/institutions` | ADMIN | 更新机构 |
| DELETE | `/api/exam/institutions/{id}` | ADMIN | 删除（逻辑删除） |

---

### 3.1 全部机构列表（管理端）

```
GET /api/exam/institutions?page=1&size=10
Authorization: Bearer <adminToken>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "total": 0,
    "page": 1,
    "size": 10,
    "records": [
      {
        "id": 1,
        "name": "北京旗舰体检中心",
        "address": "北京市东城区长安街100号东方广场3层",
        "phone": "010-88881001",
        "businessHours": "周一至周五 08:00-17:00, 周六 08:00-12:00",
        "description": "旗舰级体检中心，配备全套进口设备，支持所有体检套餐",
        "status": 1,
        "sortOrder": 1
      },
      {
        "id": 4,
        "name": "成都锦江社区体检站",
        "address": "成都市锦江区红星路400号社区中心",
        "phone": "028-44444004",
        "businessHours": "周一至周五 09:00-18:00",
        "description": "社区便民体检站，提供基础检查和常规体检",
        "status": 0,
        "sortOrder": 4
      }
    ]
  }
}
```

> **注意：** 管理端返回全部机构，`status=0` 的已停用机构也会出现。

---

### 3.2 已启用机构（患者端）

```
GET /api/exam/institutions/active
Authorization: Bearer <patientToken>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": [
    {
      "id": 1,
      "name": "北京旗舰体检中心",
      "address": "北京市东城区长安街100号东方广场3层",
      "phone": "010-88881001",
      "businessHours": "周一至周五 08:00-17:00, 周六 08:00-12:00",
      "description": "旗舰级体检中心，配备全套进口设备，支持所有体检套餐",
      "status": 1,
      "sortOrder": 1
    },
    {
      "id": 2,
      "name": "上海浦东体检分院",
      "address": "上海市浦东新区世纪大道200号金融大厦",
      "phone": "021-66662002",
      "businessHours": "周一至周日 07:30-16:30",
      "description": "新近装修，配备最新CT和磁共振设备",
      "status": 1,
      "sortOrder": 2
    }
  ]
}
```

> **注意：** 返回 `List`（非分页），仅含 `status=1` 的机构。

---

### 3.3 机构详情

```
GET /api/exam/institutions/1
Authorization: Bearer <patientToken>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "name": "北京旗舰体检中心",
    "address": "北京市东城区长安街100号东方广场3层",
    "phone": "010-88881001",
    "businessHours": "周一至周五 08:00-17:00, 周六 08:00-12:00",
    "description": "旗舰级体检中心，配备全套进口设备，支持所有体检套餐",
    "status": 1,
    "sortOrder": 1
  }
}
```

---

### 3.4 新增机构

```
POST /api/exam/institutions
Authorization: Bearer <adminToken>
Content-Type: application/json
```

**请求体：**

```json
{
  "name": "武汉光谷体检中心",
  "address": "武汉市洪山区珞喻路800号光谷广场",
  "phone": "027-77771007",
  "businessHours": "周一至周六 08:00-17:00",
  "description": "华中地区旗舰体检中心，配备全套先进设备",
  "status": 1,
  "sortOrder": 6
}
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

### 3.5 更新机构

```
PUT /api/exam/institutions
Authorization: Bearer <adminToken>
Content-Type: application/json
```

**请求体：**

```json
{
  "id": 6,
  "name": "武汉光谷体检中心(升级)",
  "phone": "027-77771008",
  "description": "升级新增PET-CT检查能力"
}
```

> **注意：** 支持部分更新，只传需要修改的字段。

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

## 4. 检查项目

> **微服务:** `xixin-exam` (端口 8120) | **Controller:** `ExamItemController`
> **路径前缀:** `/api/exam/packages/{packageId}/items`

### 接口列表

| 方法 | 路径 | 权限 | 说明 |
|------|------|:--:|------|
| GET | `/api/exam/packages/{packageId}/items?page=1&size=10` | **PATIENT, ADMIN** | 项目列表 |
| GET | `/api/exam/packages/{packageId}/items/{id}` | **PATIENT, ADMIN** | 项目详情 |
| POST | `/api/exam/packages/{packageId}/items` | ADMIN | 新增项目 |
| PUT | `/api/exam/packages/{packageId}/items/{id}` | ADMIN | 更新项目 |
| DELETE | `/api/exam/packages/{packageId}/items/{id}` | ADMIN | 删除（逻辑删除） |

> **提示：** 套餐详情接口 (`GET /api/exam/packages/{id}`) 已内嵌 `items` 数组，前端展示套餐时通常无需单独调用此控制器的查询接口。此控制器主要用于管理后台的检查项目增删改。

---

### 4.1 检查项目列表

```
GET /api/exam/packages/1/items?page=1&size=10
Authorization: Bearer <token>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "total": 0,
    "page": 1,
    "size": 10,
    "records": [
      {
        "id": 1,
        "packageId": 1,
        "name": "血常规",
        "type": "检验",
        "description": "白细胞、红细胞、血红蛋白、血小板等全血细胞计数",
        "sortOrder": 1
      },
      {
        "id": 2,
        "packageId": 1,
        "name": "尿常规",
        "type": "检验",
        "description": "尿液化学分析及显微镜检查",
        "sortOrder": 2
      },
      {
        "id": 3,
        "packageId": 1,
        "name": "十二导联心电图",
        "type": "心电",
        "description": "静息十二导联心电图检查",
        "sortOrder": 3
      }
    ]
  }
}
```

---

### 4.2 新增检查项目

```
POST /api/exam/packages/1/items
Authorization: Bearer <adminToken>
Content-Type: application/json
```

**请求体：**

```json
{
  "name": "眼底检查",
  "type": "体格",
  "description": "眼底镜+裂隙灯全面检查，排查青光眼、白内障等",
  "sortOrder": 10
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|:--:|------|
| name | String | ✅ | 项目名称 |
| type | String | ✅ | 类型：`检验` / `影像` / `心电` / `体格` |
| description | String | | 项目描述 |
| sortOrder | Integer | | 排序号 |

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

### 4.3 更新检查项目

```
PUT /api/exam/packages/1/items/16
Authorization: Bearer <adminToken>
Content-Type: application/json
```

**请求体：**

```json
{
  "name": "眼底检查(升级)",
  "description": "增加眼压测量和OCT光学相干断层扫描"
}
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

### 4.4 删除检查项目

```
DELETE /api/exam/packages/1/items/16
Authorization: Bearer <adminToken>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

## 5. 预约管理

> **微服务:** `xixin-exam` (端口 8120) | **Controller:** `AppointmentController`
> **路径前缀:** `/api/exam/appointments`

### 接口列表

| 方法 | 路径 | 权限 | 说明 |
|------|------|:--:|------|
| GET | `/api/exam/appointments` | PATIENT, DOCTOR, ADMIN | 预约列表（**角色数据隔离**） |
| GET | `/api/exam/appointments/{id}` | PATIENT, DOCTOR, ADMIN | 预约详情（**所有权校验**） |
| POST | `/api/exam/appointments` | PATIENT | 提交预约（自动确认+分配医生） |
| PUT | `/api/exam/appointments/{id}/cancel` | PATIENT | 取消预约（**仅限本人**） |
| DELETE | `/api/exam/appointments/{id}` | ADMIN | 删除（逻辑删除） |

---

### 5.1 预约列表（数据隔离）

```
GET /api/exam/appointments                  ← PATIENT：不分页，返回全部
GET /api/exam/appointments?page=1&size=10   ← DOCTOR/ADMIN：分页
Authorization: Bearer <token>
```

#### PATIENT 响应 (200) — 不分页数组：

```json
{
  "code": 200,
  "message": "操作成功",
  "data": [
    {
      "id": 10,
      "createTime": "2026-06-12T08:40:51",
      "updateTime": "2026-06-12T08:40:51",
      "createBy": 2,
      "updateBy": 2,
      "deleted": 0,
      "userId": 2,
      "packageId": 3,
      "institutionId": 2,
      "doctorId": 3,
      "appointmentDate": "2026-07-20",
      "timeSlot": "下午",
      "status": 1,
      "remark": "指定张医生"
    },
    {
      "id": 9,
      "createTime": "2026-06-12T08:40:45",
      "createBy": 2,
      "updateBy": 2,
      "userId": 2,
      "packageId": 1,
      "institutionId": 1,
      "doctorId": 3,
      "appointmentDate": "2026-07-15",
      "timeSlot": "上午",
      "status": 1,
      "remark": "空腹前来，携带身份证"
    }
  ]
}
```

#### DOCTOR/ADMIN 响应 (200) — 分页：

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "total": 0,
    "page": 1,
    "size": 10,
    "records": [ ... ]
  }
}
```

#### 数据隔离规则

| 角色 | 返回格式 | 过滤条件 |
|------|---------|------|
| **PATIENT** | `List<Appointment>`（不分页） | `userId == 当前用户ID` |
| **DOCTOR** | `PageResult<Appointment>`（分页） | `doctorId == 当前用户ID` |
| **ADMIN** | `PageResult<Appointment>`（分页） | 无过滤，返回全部 |

---

### 5.2 预约详情

```
GET /api/exam/appointments/9
Authorization: Bearer <token>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 9,
    "createTime": "2026-06-12T08:40:45",
    "updateTime": "2026-06-12T08:40:45",
    "createBy": 2,
    "updateBy": 2,
    "deleted": 0,
    "userId": 2,
    "packageId": 1,
    "institutionId": 1,
    "doctorId": 3,
    "appointmentDate": "2026-07-15",
    "timeSlot": "上午",
    "status": 1,
    "remark": "空腹前来，携带身份证"
  }
}
```

**所有权校验：** PATIENT 只能查看 `userId == 自己的预约`，DOCTOR 只能查看 `doctorId == 自己的预约`，非授权访问返回 `403`。

---

### 5.3 提交预约（自动确认+分配医生）

```
POST /api/exam/appointments
Authorization: Bearer <patientToken>
Content-Type: application/json
```

**请求体（自动分配医生）：**

```json
{
  "packageId": 1,
  "institutionId": 1,
  "appointmentDate": "2026-07-15",
  "timeSlot": "上午",
  "remark": "空腹前来，携带身份证"
}
```

**请求体（手动指定医生，覆盖套餐默认）：**

```json
{
  "packageId": 3,
  "institutionId": 2,
  "doctorId": 3,
  "appointmentDate": "2026-07-20",
  "timeSlot": "下午",
  "remark": "指定张医生"
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|:--:|------|
| packageId | Long | ✅ | 套餐 ID |
| institutionId | Long | ✅ | 机构 ID |
| appointmentDate | String | ✅ | 预约日期 `yyyy-MM-dd` |
| timeSlot | String | ✅ | 时间段：`上午` / `下午` |
| doctorId | Long | | 手动指定医生；不传则从套餐 `doctorId` 自动分配 |
| remark | String | | 备注 |

> **⚠ 注意：** `userId` **由后端从 Token 自动获取**，客户端无需也不应传递。`status` 自动设为 `1`（已确认）。

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

**预约状态流转：** `1=已确认（自动）` → `2=已取消` / `3=已完成`

---

### 5.4 取消预约

```
PUT /api/exam/appointments/1/cancel
Authorization: Bearer <patientToken>
```

**权限：** PATIENT，且只能取消本人的预约（`userId == 当前用户ID`）。非本人返回 `403`。

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

### 5.5 删除预约

```
DELETE /api/exam/appointments/1
Authorization: Bearer <adminToken>
```

**权限：** 仅 ADMIN。逻辑删除（`deleted=1`）。

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

## 6. 报告管理

> **微服务:** `xixin-report` (端口 8130)
> **路径前缀:** `/api/report`

### 报告接口列表

| 方法 | 路径 | 权限 | 说明 |
|------|------|:--:|------|
| GET | `/api/report/list?page=1&size=10` | ALL | 报告列表（**角色数据隔离**） |
| GET | `/api/report/{id}` | ALL | 报告详情（**所有权校验**） |
| POST | `/api/report/generate` | DOCTOR | 生成报告（直接发布） |
| PUT | `/api/report/{id}` | DOCTOR | 更新报告（**仅限自己生成的**） |
| DELETE | `/api/report/{id}` | ADMIN | 删除（逻辑删除） |

#### 数据隔离规则

| 角色 | 过滤条件 |
|------|------|
| **PATIENT** | `userId == 当前用户ID` |
| **DOCTOR** | `doctorId == 当前用户ID` |
| **ADMIN** | 无过滤，返回全部 |

---

### 6.1 报告列表

```
GET /api/report/list?page=1&size=10
Authorization: Bearer <token>
```

**PATIENT 响应 (200) — 仅返回本人的报告：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "total": 0,
    "page": 1,
    "size": 10,
    "records": [
      {
        "id": 1,
        "createTime": "2026-06-04T10:35:24",
        "deleted": 0,
        "userId": 2,
        "appointmentId": 1,
        "doctorId": 1,
        "summary": "生命体征平稳，血常规各项指标在正常范围，心电图示窦性心律",
        "conclusion": "身体健康，建议继续保持良好生活习惯",
        "status": 2,
        "generateTime": "2026-06-10T14:00:00"
      }
    ]
  }
}
```

**DOCTOR 响应 (200) — 仅返回自己生成的报告：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "total": 0,
    "page": 1,
    "size": 10,
    "records": [
      {
        "id": 9,
        "createTime": "2026-06-12T08:50:32",
        "createBy": 3,
        "updateBy": 3,
        "userId": 2,
        "appointmentId": 9,
        "doctorId": 3,
        "summary": "All tests normal",
        "conclusion": "Healthy, keep exercising",
        "status": 2,
        "generateTime": null
      }
    ]
  }
}
```

---

### 6.2 报告详情

```
GET /api/report/1
Authorization: Bearer <token>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "createTime": "2026-06-04T10:35:24",
    "deleted": 0,
    "userId": 2,
    "appointmentId": 1,
    "doctorId": 1,
    "summary": "生命体征平稳，血常规各项指标在正常范围，心电图示窦性心律",
    "conclusion": "身体健康，建议继续保持良好生活习惯",
    "status": 2,
    "generateTime": "2026-06-10T14:00:00"
  }
}
```

**所有权校验：** PATIENT 只能看 `userId == 自己的`，DOCTOR 只能看 `doctorId == 自己的`。

---

### 6.3 生成报告（直接发布）

```
POST /api/report/generate
Authorization: Bearer <doctorToken>
Content-Type: application/json
```

**请求体：**

```json
{
  "userId": 2,
  "appointmentId": 9,
  "summary": "血常规各项指标正常，肾功能正常，心电图示窦性心律，心率72次/分",
  "conclusion": "体检结果正常，健康状况良好，建议保持规律作息，每年定期体检"
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|:--:|------|
| userId | Long | ✅ | 患者用户 ID |
| appointmentId | Long | ✅ | 关联的预约 ID |
| summary | String | ✅ | 检查摘要 |
| conclusion | String | ✅ | 总检结论 |

> **⚠ 注意：** `doctorId` **由后端从 Token 自动获取**，`status` 自动设为 `2`（已发布），患者立即可查看。

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 9,
    "createTime": "2026-06-12T08:50:31",
    "createBy": 3,
    "updateBy": 3,
    "userId": 2,
    "appointmentId": 9,
    "doctorId": 3,
    "summary": "血常规各项指标正常，肾功能正常，心电图示窦性心律，心率72次/分",
    "conclusion": "体检结果正常，健康状况良好，建议保持规律作息，每年定期体检",
    "status": 2,
    "generateTime": null
  }
}
```

> 返回的 `data.id` 是新报告的 ID，后续录入检查项和查看明细时需要用到。

---

### 6.4 更新报告

```
PUT /api/report/9
Authorization: Bearer <doctorToken>
Content-Type: application/json
```

**请求体：**

```json
{
  "conclusion": "（修正后）体检结果正常，健康状况良好。建议保持规律作息，每年定期体检，戒烟限酒",
  "summary": "血常规、肾功能、心电图均正常，肝功能谷丙转氨酶65 U/L轻度升高，建议复查"
}
```

**权限：** 医生只能修改 `doctorId == 自己的` 的报告。

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

### 6.5 删除报告

```
DELETE /api/report/1
Authorization: Bearer <adminToken>
```

**权限：** 仅 ADMIN。

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

### 报告项目明细

> **Controller:** `ReportItemController`
> **路径前缀:** `/api/report/{reportId}/items`

| 方法 | 路径 | 权限 | 说明 |
|------|------|:--:|------|
| GET | `/api/report/{reportId}/items` | ALL | 分页查询 |
| GET | `/api/report/{reportId}/items/all` | ALL | **全部明细（不分页）** |
| GET | `/api/report/{reportId}/items/{id}` | ALL | 单项详情 |
| POST | `/api/report/{reportId}/items` | DOCTOR | 单独录入 |
| POST | `/api/report/{reportId}/items/batch` | DOCTOR | **批量录入** |
| PUT | `/api/report/{reportId}/items/{id}` | DOCTOR | 修正结果 |
| DELETE | `/api/report/{reportId}/items/{id}` | DOCTOR | 删除 |

---

### 6.6 查看全部检查项目明细

```
GET /api/report/9/items/all
Authorization: Bearer <token>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": [
    {
      "id": 11,
      "reportId": 9,
      "examItemId": 1,
      "examItemName": "血常规",
      "result": "WBC 6.8",
      "referenceRange": "4-10",
      "abnormalFlag": 0
    },
    {
      "id": 12,
      "reportId": 9,
      "examItemId": 3,
      "examItemName": "ECG",
      "result": "Normal",
      "referenceRange": "Normal",
      "abnormalFlag": 0
    },
    {
      "id": 13,
      "reportId": 9,
      "examItemId": 4,
      "examItemName": "Liver function",
      "result": "ALT 65",
      "referenceRange": "10-40",
      "abnormalFlag": 1
    }
  ]
}
```

> `abnormalFlag`: `0`=正常, `1`=异常（前端应对异常项高亮标记）

---

### 6.7 批量录入检查项目明细

```
POST /api/report/9/items/batch
Authorization: Bearer <doctorToken>
Content-Type: application/json
```

**请求体：**

```json
[
  {
    "examItemId": 1,
    "examItemName": "血常规",
    "result": "白细胞6.8, 红细胞5.2, 血红蛋白148g/L, 血小板210",
    "referenceRange": "白细胞4-10, 红细胞4.5-5.8, 血红蛋白130-175, 血小板100-300",
    "abnormalFlag": 0
  },
  {
    "examItemId": 2,
    "examItemName": "尿常规",
    "result": "葡萄糖阴性, 蛋白质阴性, 潜血阴性",
    "referenceRange": "阴性",
    "abnormalFlag": 0
  },
  {
    "examItemId": 3,
    "examItemName": "十二导联心电图",
    "result": "窦性心律，心率72次/分，电轴正常，ST-T未见异常",
    "referenceRange": "正常窦性心律",
    "abnormalFlag": 0
  }
]
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|:--:|------|
| examItemId | Long | ✅ | 关联套餐检查项 ID |
| examItemName | String | ✅ | 检查项名称（去规范化冗余） |
| result | String | ✅ | 检查结果值 |
| referenceRange | String | | 正常参考范围 |
| abnormalFlag | Integer | | 0=正常（默认）, 1=异常 |

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

### 6.8 单独录入一项检查结果

```
POST /api/report/9/items
Authorization: Bearer <doctorToken>
Content-Type: application/json
```

**请求体：**

```json
{
  "examItemId": 4,
  "examItemName": "肝功能谷丙转氨酶",
  "result": "65 U/L",
  "referenceRange": "10-40 U/L",
  "abnormalFlag": 1
}
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

### 6.9 修正检查项结果

```
PUT /api/report/9/items/13
Authorization: Bearer <doctorToken>
Content-Type: application/json
```

**请求体：**

```json
{
  "examItemId": 4,
  "examItemName": "肝功能谷丙转氨酶",
  "result": "58 U/L",
  "referenceRange": "10-40 U/L",
  "abnormalFlag": 1
}
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

## 7. 用户管理

> **微服务:** `xixin-auth` (端口 8100) | **Controller:** `UserController`
> **路径前缀:** `/api/auth/users`

### 接口列表

| 方法 | 路径 | 权限 | 说明 |
|------|------|:--:|------|
| GET | `/api/auth/users?page=1&size=10` | ADMIN | 用户列表 |
| GET | `/api/auth/users/{id}` | ADMIN | 用户详情 |
| PUT | `/api/auth/users/{id}` | ADMIN | 编辑用户（部分更新） |
| PUT | `/api/auth/users/{id}/status?status=0` | ADMIN | 启用/禁用 |
| PUT | `/api/auth/users/{id}/reset-password?newPassword=xxx` | ADMIN | 重置密码 |
| DELETE | `/api/auth/users/{id}` | ADMIN | 删除（逻辑删除） |

---

### 7.1 用户列表

```
GET /api/auth/users?page=1&size=10
Authorization: Bearer <adminToken>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "total": 0,
    "page": 1,
    "size": 10,
    "records": [
      {
        "id": 2,
        "username": "testuser01",
        "password": "123456",
        "realName": "测试患者(改)",
        "phone": "13900002222",
        "email": "test01@test.com",
        "avatar": null,
        "role": "PATIENT",
        "status": 1
      },
      {
        "id": 3,
        "username": "testdoc01",
        "realName": "张医生",
        "phone": "13900139001",
        "role": "DOCTOR",
        "status": 1
      },
      {
        "id": 1,
        "username": "admin",
        "realName": "系统管理员",
        "role": "ADMIN",
        "status": 1
      }
    ]
  }
}
```

> ⚠ `password` 字段明文返回，生产环境需脱敏。

---

### 7.2 用户详情

```
GET /api/auth/users/2
Authorization: Bearer <adminToken>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 2,
    "username": "testuser01",
    "realName": "测试患者(改)",
    "phone": "13900002222",
    "email": "test01@test.com",
    "role": "PATIENT",
    "status": 1
  }
}
```

---

### 7.3 编辑用户

```
PUT /api/auth/users/2
Authorization: Bearer <adminToken>
Content-Type: application/json
```

**请求体（部分更新）：**

```json
{
  "realName": "Test Patient Updated",
  "phone": "13900002222",
  "email": "updated_patient@test.com"
}
```

| 字段 | 说明 |
|------|------|
| realName | 真实姓名 |
| phone | 手机号 |
| email | 邮箱 |
| role | 角色 `ADMIN`/`DOCTOR`/`PATIENT` |
| status | 0=禁用, 1=启用 |

> 只传需要修改的字段，`null`/空值不覆盖原有数据。

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

### 7.4 启用/禁用用户

```
PUT /api/auth/users/2/status?status=0     ← 禁用
PUT /api/auth/users/2/status?status=1     ← 启用
Authorization: Bearer <adminToken>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

### 7.5 重置密码

```
PUT /api/auth/users/2/reset-password?newPassword=123456
Authorization: Bearer <adminToken>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

### 7.6 删除用户

```
DELETE /api/auth/users/7
Authorization: Bearer <adminToken>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

## 8. 角色管理

> **微服务:** `xixin-system` (端口 8140) | **Controller:** `RoleController`
> **路径前缀:** `/api/system/roles`

### 接口列表

| 方法 | 路径 | 权限 | 说明 |
|------|------|:--:|------|
| GET | `/api/system/roles?page=1&size=10` | ADMIN | 角色列表 |
| GET | `/api/system/roles/{id}` | ADMIN | 角色详情 |
| POST | `/api/system/roles` | ADMIN | 新增角色 |
| PUT | `/api/system/roles` | ADMIN | 更新角色 |
| DELETE | `/api/system/roles/{id}` | ADMIN | 删除 |

---

### 8.1 角色列表

```
GET /api/system/roles?page=1&size=10
Authorization: Bearer <adminToken>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "total": 0,
    "page": 1,
    "size": 10,
    "records": [
      {
        "id": 2,
        "roleName": "医生",
        "roleCode": "DOCTOR",
        "description": "体检医生",
        "status": 1
      },
      {
        "id": 3,
        "roleName": "患者",
        "roleCode": "PATIENT",
        "description": "体检用户",
        "status": 1
      }
    ]
  }
}
```

---

### 8.2 新增角色

```
POST /api/system/roles
Authorization: Bearer <adminToken>
Content-Type: application/json
```

**请求体：**

```json
{
  "roleName": "检验技师",
  "roleCode": "TECHNICIAN",
  "description": "负责检验科各项化验操作的技术人员",
  "status": 1
}
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

### 8.3 更新角色

```
PUT /api/system/roles
Authorization: Bearer <adminToken>
Content-Type: application/json
```

**请求体：**

```json
{
  "id": 4,
  "roleName": "检验技师(高级)",
  "description": "高级检验技术人员，可独立审核检验报告"
}
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

### 8.4 删除角色

```
DELETE /api/system/roles/4
Authorization: Bearer <adminToken>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

## 9. 字典维护

> **微服务:** `xixin-system` (端口 8140)

### 字典类型 (`/api/system/dict-types`)

| 方法 | 路径 | 权限 | 说明 |
|------|------|:--:|------|
| GET | `/api/system/dict-types?page=1&size=10` | ADMIN | 列表 |
| GET | `/api/system/dict-types/{id}` | ADMIN | 详情 |
| POST | `/api/system/dict-types` | ADMIN | 新增 |
| PUT | `/api/system/dict-types` | ADMIN | 更新 |
| DELETE | `/api/system/dict-types/{id}` | ADMIN | 删除 |

---

### 9.1 字典类型列表

```
GET /api/system/dict-types?page=1&size=10
Authorization: Bearer <adminToken>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "total": 0,
    "page": 1,
    "size": 10,
    "records": [
      { "id": 1, "dictName": "性别", "dictType": "sys_gender", "status": 1 },
      { "id": 2, "dictName": "预约状态", "dictType": "exam_appt_status", "status": 1 },
      { "id": 3, "dictName": "报告状态", "dictType": "report_status", "status": 1 },
      { "id": 4, "dictName": "预约类型", "dictType": "exam_appt_type", "status": 1 }
    ]
  }
}
```

**新增字典类型请求体：**

```json
{
  "dictName": "科室分类",
  "dictType": "sys_department",
  "status": 1
}
```

---

### 字典项 (`/api/system/dict-items`)

| 方法 | 路径 | 权限 | 说明 |
|------|------|:--:|------|
| GET | `/api/system/dict-items/by-type/{typeId}?page=1&size=10` | **PATIENT, ADMIN** | 按类型查选项 |
| GET | `/api/system/dict-items/{id}` | ADMIN | 详情 |
| POST | `/api/system/dict-items` | ADMIN | 新增 |
| PUT | `/api/system/dict-items` | ADMIN | 更新 |
| DELETE | `/api/system/dict-items/{id}` | ADMIN | 删除 |

---

### 9.2 预约类型字典项（PATIENT 可访问）

```
GET /api/system/dict-items/by-type/4?page=1&size=10
Authorization: Bearer <patientToken>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "total": 0,
    "page": 1,
    "size": 10,
    "records": [
      { "id": 10, "dictTypeId": 4, "label": "个人体检", "value": "individual", "sortOrder": 1, "status": 1 },
      { "id": 11, "dictTypeId": 4, "label": "团体体检", "value": "group",       "sortOrder": 2, "status": 1 },
      { "id": 12, "dictTypeId": 4, "label": "入职体检", "value": "onboarding",  "sortOrder": 3, "status": 1 },
      { "id": 13, "dictTypeId": 4, "label": "出入境体检", "value": "travel",     "sortOrder": 4, "status": 1 }
    ]
  }
}
```

---

### 9.3 预约状态字典项

```
GET /api/system/dict-items/by-type/2?page=1&size=10
Authorization: Bearer <adminToken>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      { "id": 3, "dictTypeId": 2, "label": "待确认", "value": "0", "sortOrder": 1 },
      { "id": 4, "dictTypeId": 2, "label": "已确认", "value": "1", "sortOrder": 2 },
      { "id": 5, "dictTypeId": 2, "label": "已取消", "value": "2", "sortOrder": 3 },
      { "id": 6, "dictTypeId": 2, "label": "已完成", "value": "3", "sortOrder": 4 }
    ]
  }
}
```

---

### 9.4 字典项新增/更新/删除

**新增：**

```json
POST /api/system/dict-items
{ "dictTypeId": 2, "label": "已过期", "value": "4", "sortOrder": 5, "status": 1 }
```

**更新：**

```json
PUT /api/system/dict-items
{ "id": 14, "label": "已超时(已更新)" }
```

**删除：**

```
DELETE /api/system/dict-items/14
```

---

## 10. 医生/患者档案查询

> **微服务:** `xixin-user` (端口 8110)
> **路径前缀:** `/api/user/doctors`, `/api/user/patients`
> **权限:** DOCTOR, ADMIN

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/user/doctors?page=1&size=10` | 医生列表 |
| GET | `/api/user/doctors/{id}` | 医生详情 |
| GET | `/api/user/patients?page=1&size=10` | 患者列表 |
| GET | `/api/user/patients/{id}` | 患者详情 |

---

### 10.1 医生列表

```
GET /api/user/doctors?page=1&size=10
Authorization: Bearer <token>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      {
        "id": 1,
        "userId": 1,
        "packageId": 1,
        "department": "全科医学科",
        "title": "主任医师",
        "specialty": "心血管疾病",
        "introduction": "从事内科临床工作逾25年，擅长冠心病、高血压、心力衰竭的诊治"
      },
      {
        "id": 2,
        "userId": 3,
        "packageId": 2,
        "department": "呼吸内科",
        "title": "副主任医师",
        "specialty": "呼吸系统疾病",
        "introduction": "专长：慢性阻塞性肺疾病、支气管哮喘、肺部感染性疾病"
      }
    ]
  }
}
```

---

### 10.2 患者列表

```
GET /api/user/patients?page=1&size=10
Authorization: Bearer <token>
```

**响应 (200)：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      {
        "id": 1,
        "userId": 2,
        "name": "测试患者甲",
        "gender": 1,
        "birthday": "1990-03-15",
        "idCard": "110101199003150011",
        "address": "北京市海淀区中关村大街1号",
        "emergencyContact": "张父",
        "emergencyPhone": "13900001001"
      },
      {
        "id": 2,
        "userId": 5,
        "name": "王患者乙",
        "gender": 1,
        "birthday": "1985-07-22",
        "address": "上海市浦东新区世纪大道100号",
        "emergencyContact": "王母",
        "emergencyPhone": "13900001002"
      }
    ]
  }
}
```

| 字段 | 说明 |
|------|------|
| gender | 0=女, 1=男 |
| idCard | 身份证号 |
| emergencyContact | 紧急联系人 |
| emergencyPhone | 紧急联系人电话 |

---

## 11. 预约流程级联选择

> **微服务:** `xixin-exam` (端口 8120) | **Controller:** `AppointmentFlowController`
> **权限:** PATIENT, ADMIN

### Step 1: 预约类型 → 机构列表

```
GET /api/exam/appointment-types/{type}/institutions
Authorization: Bearer <patientToken>
```

| type 取值 | 含义 |
|-----------|------|
| `individual` | 个人体检 |
| `group` | 团体体检 |
| `onboarding` | 入职体检 |
| `travel` | 出入境体检 |

**示例（个人体检 → 4家机构）：**

```
GET /api/exam/appointment-types/individual/institutions
```

**响应 (200)：**

```json
{
  "code": 200,
  "data": [
    { "id": 1, "name": "北京旗舰体检中心", "address": "北京市东城区长安街100号东方广场3层", "phone": "010-88881001", "businessHours": "周一至周五 08:00-17:00, 周六 08:00-12:00" },
    { "id": 2, "name": "上海浦东体检分院", "address": "上海市浦东新区世纪大道200号金融大厦", "phone": "021-66662002", "businessHours": "周一至周日 07:30-16:30" },
    { "id": 3, "name": "广州天河体检分院", "address": "广州市天河区天河路300号正佳广场旁", "phone": "020-55553003", "businessHours": "周一至周六 08:30-17:30" },
    { "id": 5, "name": "南京鼓楼体检中心", "address": "南京市鼓楼区中山路500号大学附属楼", "phone": "025-33335005", "businessHours": "周一至周日 08:00-16:00" }
  ]
}
```

> 不同预约类型对应不同机构集合（通过 `t_appt_type_institution` 关联表过滤）。仅返回 `status=1` 的启用机构。

---

### Step 2: 机构 → 套餐列表

```
GET /api/exam/institutions/{institutionId}/packages
Authorization: Bearer <patientToken>
```

**示例（北京旗舰 → 5个套餐）：**

```
GET /api/exam/institutions/1/packages
```

**响应 (200)：**

```json
{
  "code": 200,
  "data": [
    { "id": 1, "name": "基础健康体检", "price": 199.00, "description": "血常规、尿常规、心电图三项基础检查", "doctorId": 3, "status": 1, "sortOrder": 1 },
    { "id": 2, "name": "标准健康体检", "price": 599.00, "description": "基础项目+肝功能全项+肾功能全项+胸部X光片", "doctorId": 3, "status": 1, "sortOrder": 2 },
    { "id": 3, "name": "高端全面体检", "price": 1299.00, "description": "标准项目+肿瘤标志物筛查+甲状腺彩超+低剂量螺旋CT", "doctorId": 3, "status": 1, "sortOrder": 3 }
  ]
}
```

> 规格同套餐列表，仅返回 `status=1` 的上架套餐。`doctorId` 告知前端该套餐绑定的默认医生。

---

## 附录 A：统一响应格式

### 成功响应

```json
{
  "code": 200,
  "message": "操作成功",
  "data": <任意类型>
}
```

**data 类型对照：**

| 接口类型 | data 格式 |
|---------|----------|
| 普通增删改 | `null` |
| 单条查询 | 对象 |
| 分页查询 | `{ total, page, size, records }` |
| PATIENT 预约列表 | `Array`（不分页） |
| active 机构列表 | `Array`（不分页） |
| 报告全部项目明细 | `Array`（不分页） |

### 错误响应

```json
{
  "code": 403,
  "message": "无权限访问，当前角色: PATIENT",
  "data": null
}
```

### 通用错误码

| 码 | 含义 |
|----|------|
| 200 | 成功 |
| 400 | 参数错误 |
| 401 | 未认证（网关拦截，无 Token 或已过期） |
| 403 | 无权限（`@RequireRole` 拦截，角色不匹配） |
| 404 | 不存在 |
| 500 | 内部错误 |

---

## 附录 B：权限机制

```
HTTP 请求
    │
    ▼
┌──────────────────────────────────────┐
│  Gateway (8080)                      │
│  AuthGlobalFilter                    │
│  ├─ 白名单 (login/register) → 放行   │
│  ├─ 提取 Authorization: Bearer xxx   │
│  ├─ JWT 校验 (expiry/signature)       │
│  └─ 注入 Header:                     │
│       X-User-Id, X-Username, X-User-Role
└──────────────────────────────────────┘
    │
    ▼ (路由到下游微服务)
┌──────────────────────────────────────┐
│  下游服务 (exam/report/system/user)  │
│  UserContextFilter                   │
│  └─ Header → UserContext ThreadLocal │
│                                      │
│  RoleAspect (AOP)                    │
│  └─ @RequireRole 注解 → 角色校验      │
│      ├─ role=null → 403 "请先登录"    │
│      ├─ 不匹配   → 403 "无权限访问"    │
│      └─ 匹配     → 执行业务逻辑        │
│                                      │
│  Controller 内数据隔离               │
│  └─ UserContext.getUserId/getRole()  │
│      → LambdaQueryWrapper 动态过滤   │
└──────────────────────────────────────┘
```

**关键组件：**
- `@RequireRole` — 方法级注解，声明允许的角色
- `RoleAspect` — AOP 切面，运行时校验
- `UserContext` — ThreadLocal 持有当前请求用户信息
- `UserContextFilter` — Servlet Filter，从 Header 提取用户信息
- **未使用 Spring Security**，无额外依赖

---

## 附录 C：数据隔离规则

| 功能 | PATIENT | DOCTOR | ADMIN |
|------|---------|--------|-------|
| 预约列表 | 本人全部（不分页） | 分配给自己的（分页） | 全部（分页） |
| 预约详情 | `appointment.userId == self` | `appointment.doctorId == self` | 无限制 |
| 取消预约 | 仅本人 | — | — |
| 报告列表 | `report.userId == self` | `report.doctorId == self` | 全部 |
| 报告详情 | `report.userId == self` | `report.doctorId == self` | 无限制 |
| 更新报告 | — | `report.doctorId == self` | — |

---

## 附录 D：数据库表结构

### xixin_exam（体检业务）

| 表 | 关键字段 |
|----|---------|
| `t_exam_package` | id, name, price, description, **doctor_id**, status, sort_order |
| `t_exam_item` | id, package_id, name, type, description, sort_order |
| `t_institution` | id, name, address, phone, business_hours, description, status, sort_order |
| `t_appt_type_institution` | id, appt_type, institution_id |
| `t_institution_package` | id, institution_id, package_id |
| `t_appointment` | id, user_id, package_id, institution_id, **doctor_id**, appointment_date, time_slot, **status** (1=已确认,2=已取消,3=已完成), remark |

### xixin_report（体检报告）

| 表 | 关键字段 |
|----|---------|
| `t_report` | id, user_id, appointment_id, **doctor_id**, summary, conclusion, **status** (2=已发布), generate_time |
| `t_report_item` | id, report_id, exam_item_id, exam_item_name, result, reference_range, abnormal_flag |

### xixin_user（用户）

| 表 | 关键字段 |
|----|---------|
| `t_user` | id, username, password(明文), real_name, phone, email, role, status |
| `t_patient` | id, user_id, name, gender, birthday, id_card, address, emergency_contact, emergency_phone |
| `t_doctor` | id, user_id, package_id, department, title, specialty, introduction |

### xixin_system（系统配置）

| 表 | 关键字段 |
|----|---------|
| `t_role` | id, role_name, role_code, description, status |
| `t_dict_type` | id, dict_name, dict_type, status |
| `t_dict_item` | id, dict_type_id, label, value, sort_order, status |

### 审计字段

所有表均继承 `BaseEntity`，含：`create_time`, `update_time`, `create_by`, `update_by`, `deleted`（逻辑删除标识）。

`create_by` / `update_by` 由 `MyBatisPlusConfig` 从 `UserContext.getUserId()` 自动填充。
