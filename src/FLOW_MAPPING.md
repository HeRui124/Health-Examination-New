# 东软熙心健康体检管理系统 — 流程功能对照表

> 本文档将流程图中的每一个步骤，映射到具体的 API 接口、所属微服务和 Controller 类，说明对应功能的作用。
>
> 最后更新: 2026-06-12

---

## 一、患者 (PATIENT) 流程图

```
注册/登录 → 选择预约类型 → 选择体检机构 → 查看套餐列表 → 查看套餐详情（含检查项目）→ 提交预约（自动确认+分配医生）→ 查看我的预约 → 取消预约 → 查看体检报告
```

| 流程图步骤 | 接口 | 方法 | 微服务 | Controller 类 | 作用 |
|-----------|------|:--:|--------|---------------|------|
| **注册** | `/api/auth/register` | POST | `xixin-auth` | `AuthController` | 患者自主注册账号，填写用户名、密码、姓名、手机号；角色自动设为 `PATIENT` |
| **登录** | `/api/auth/login` | POST | `xixin-auth` | `AuthController` | 验证用户名密码，签发 JWT 令牌（含 userId、username、role），后续所有请求携带此令牌识别身份 |
| **选择预约类型** | `/api/system/dict-items/by-type/4` | GET | `xixin-system` | `DictItemController` | 获取预约类型字典：个人/团体/入职/出入境，用于前端下拉框。**权限：PATIENT、ADMIN** |
| **选择体检机构** | `/api/exam/appointment-types/{type}/institutions` | GET | `xixin-exam` | `AppointmentFlowController` | 根据所选预约类型，返回可用的机构列表（含名称、地址、电话、营业时间）。**权限：PATIENT、ADMIN** |
| **查看套餐列表** | `/api/exam/institutions/{id}/packages` | GET | `xixin-exam` | `AppointmentFlowController` | 根据所选机构，返回该机构提供的套餐（含名称、价格、描述） |
| **套餐详情（含检查项目）** | `/api/exam/packages/{id}` | GET | `xixin-exam` | `ExamPackageController` | 查看套餐完整信息及包含的检查项目列表（`items` 字段内嵌返回），**一次请求同时获取套餐和检查项** |
| **提交预约（自动确认+分配医生）** | `/api/exam/appointments` | POST | `xixin-exam` | `AppointmentController` | 提交 packageId、institutionId、appointmentDate、timeSlot；**userId 从 Token 自动获取**，系统自动将预约设为"已确认"（status=1），并根据套餐绑定的 doctorId 自动分配医生；也可手动指定 doctorId 覆盖默认值 |
| **查看我的预约** | `/api/exam/appointments` | GET | `xixin-exam` | `AppointmentController` | **患者查看本人全部预约（不分页）**，按时间倒序；显示机构、套餐、日期、状态、负责医生 |
| **取消预约** | `/api/exam/appointments/{id}/cancel` | PUT | `xixin-exam` | `AppointmentController` | 将预约状态设为"已取消"（status=2）；**只能取消本人的预约** |
| **查看体检报告** | `/api/report/list` | GET | `xixin-report` | `ReportController` | **仅返回属于自己的报告**（按 userId 过滤） |
| **查看报告详情** | `/api/report/{id}` | GET | `xixin-report` | `ReportController` | 查看单份报告的摘要、结论；**只能查看本人的报告** |
| **查看报告检查项目明细** | `/api/report/{id}/items/all` | GET | `xixin-report` | `ReportItemController` | 查看报告中每个检查项的具体结果、参考范围和异常标记 |

---

## 二、医生 (DOCTOR) 流程图

```
登录 → 查看分配给自己的预约 → 查看患者档案 → 录入体检结果（直接发布）
```

| 流程图步骤 | 接口 | 方法 | 微服务 | Controller 类 | 作用 |
|-----------|------|:--:|--------|---------------|------|
| **登录** | `/api/auth/login` | POST | `xixin-auth` | `AuthController` | 与患者相同，系统根据 role 字段识别医生身份 |
| **查看分配给自己的预约** | `/api/exam/appointments` | GET | `xixin-exam` | `AppointmentController` | **仅返回分配给当前医生的预约（分页）**，按创建时间倒序 |
| **查看患者档案** | `/api/user/patients` | GET | `xixin-user` | `PatientController` | 查询患者基本信息（姓名、性别、出生日期、联系方式） |
| **查看患者详情** | `/api/user/patients/{id}` | GET | `xixin-user` | `PatientController` | 查看单个患者的完整档案，含身份证号、地址、紧急联系人 |
| **录入体检结果（直接发布）** | `/api/report/generate` | POST | `xixin-report` | `ReportController` | 医生完成体检后，录入摘要和总检结论；**doctorId 从 Token 自动获取**，报告直接设为"已发布"（status=2），患者可立即查看 |
| **录入检查项目明细** | `/api/report/{id}/items/batch` | POST | `xixin-report` | `ReportItemController` | 批量录入各检查项的具体结果值、参考范围、异常标记 |
| **修改报告** | `/api/report/{id}` | PUT | `xixin-report` | `ReportController` | 医生发现报告有误时修正摘要或结论；**只能修改自己生成的报告** |
| **修改检查项结果** | `/api/report/{id}/items/{itemId}` | PUT | `xixin-report` | `ReportItemController` | 修正某个检查项的结果值或异常标记 |
| **查看已生成报告** | `/api/report/list` | GET | `xixin-report` | `ReportController` | **仅返回自己生成的报告**（按 doctorId 过滤） |

---

## 三、管理员 (ADMIN) 流程图

```
登录 → 用户管理 → 角色管理 → 机构管理 → 套餐管理（含绑定医生）→ 检查项目管理 → 字典维护
```

> **注意：管理员不再参与预约管理。** 预约由患者提交后自动确认并分配医生（医生在套餐创建时已绑定），不需要管理员确认、取消或分配医生。

### 3.1 用户管理

| 流程图步骤 | 接口 | 方法 | 微服务 | Controller 类 | 作用 |
|-----------|------|:--:|--------|---------------|------|
| **用户列表** | `/api/auth/users` | GET | `xixin-auth` | `UserController` | 查看系统所有注册用户（权限：ADMIN） |
| **查看用户** | `/api/auth/users/{id}` | GET | `xixin-auth` | `UserController` | 查看单个用户的详细信息 |
| **编辑用户** | `/api/auth/users/{id}` | PUT | `xixin-auth` | `UserController` | 修改用户的真实姓名、手机号、邮箱、角色 |
| **启用/禁用** | `/api/auth/users/{id}/status?status=0` | PUT | `xixin-auth` | `UserController` | 禁用违规用户（status=0）或重新启用（status=1），禁用后 Token 立即失效 |
| **重置密码** | `/api/auth/users/{id}/reset-password` | PUT | `xixin-auth` | `UserController` | 为用户重置密码（明文存储） |
| **删除用户** | `/api/auth/users/{id}` | DELETE | `xixin-auth` | `UserController` | 删除用户（逻辑删除） |

### 3.2 角色管理

| 流程图步骤 | 接口 | 方法 | 微服务 | Controller 类 | 作用 |
|-----------|------|:--:|--------|---------------|------|
| **角色列表** | `/api/system/roles` | GET | `xixin-system` | `RoleController` | 查看系统所有角色及其编码、描述（权限：ADMIN） |
| **查看角色** | `/api/system/roles/{id}` | GET | `xixin-system` | `RoleController` | 查看某个角色的详细信息 |
| **新增角色** | `/api/system/roles` | POST | `xixin-system` | `RoleController` | 创建新角色（如护士、技师） |
| **编辑角色** | `/api/system/roles` | PUT | `xixin-system` | `RoleController` | 修改角色名称或描述 |
| **删除角色** | `/api/system/roles/{id}` | DELETE | `xixin-system` | `RoleController` | 删除不再使用的角色（逻辑删除） |

### 3.3 机构管理

| 流程图步骤 | 接口 | 方法 | 微服务 | Controller 类 | 作用 |
|-----------|------|:--:|--------|---------------|------|
| **机构列表** | `/api/exam/institutions` | GET | `xixin-exam` | `InstitutionController` | 查看所有体检机构（权限：ADMIN） |
| **已启用机构** | `/api/exam/institutions/active` | GET | `xixin-exam` | `InstitutionController` | 患者端用，只返回 status=1 的机构（**权限：PATIENT、ADMIN**） |
| **查看机构** | `/api/exam/institutions/{id}` | GET | `xixin-exam` | `InstitutionController` | 查看单个机构的详细信息（权限：PATIENT、ADMIN） |
| **新增机构** | `/api/exam/institutions` | POST | `xixin-exam` | `InstitutionController` | 创建新的体检分支机构（权限：ADMIN） |
| **编辑机构** | `/api/exam/institutions` | PUT | `xixin-exam` | `InstitutionController` | 修改机构信息（权限：ADMIN） |
| **删除机构** | `/api/exam/institutions/{id}` | DELETE | `xixin-exam` | `InstitutionController` | 移除已关闭的机构（权限：ADMIN） |

### 3.4 套餐管理

| 流程图步骤 | 接口 | 方法 | 微服务 | Controller 类 | 作用 |
|-----------|------|:--:|--------|---------------|------|
| **套餐列表** | `/api/exam/packages` | GET | `xixin-exam` | `ExamPackageController` | 查看所有套餐（权限：PATIENT、ADMIN） |
| **查看套餐** | `/api/exam/packages/{id}` | GET | `xixin-exam` | `ExamPackageController` | **查看套餐详情及绑定的 doctorId，同时返回 items 数组（含该套餐下所有检查项目）** |
| **新增套餐** | `/api/exam/packages` | POST | `xixin-exam` | `ExamPackageController` | 创建新套餐，设置名称、价格、描述，并绑定一名医生（doctorId）。患者预约此套餐后自动分配给该医生（权限：ADMIN） |
| **编辑套餐** | `/api/exam/packages` | PUT | `xixin-exam` | `ExamPackageController` | 修改套餐信息（调价、更新描述、更换绑定医生）（权限：ADMIN） |
| **上架/下架** | `/api/exam/packages/{id}/status?status=0` | PUT | `xixin-exam` | `ExamPackageController` | 下架过时套餐（status=0，患者不可见）或重新上架（status=1）（权限：ADMIN） |
| **删除套餐** | `/api/exam/packages/{id}` | DELETE | `xixin-exam` | `ExamPackageController` | 彻底移除套餐，逻辑删除（权限：ADMIN） |

### 3.5 检查项目管理

| 流程图步骤 | 接口 | 方法 | 微服务 | Controller 类 | 作用 |
|-----------|------|:--:|--------|---------------|------|
| **项目列表** | `/api/exam/packages/{packageId}/items` | GET | `xixin-exam` | `ExamItemController` | 查看某个套餐包含的所有检查项目（**权限：PATIENT、ADMIN**） |
| **查看项目** | `/api/exam/packages/{packageId}/items/{id}` | GET | `xixin-exam` | `ExamItemController` | 查看单个体检项目的详情（**权限：PATIENT、ADMIN**） |
| **新增项目** | `/api/exam/packages/{packageId}/items` | POST | `xixin-exam` | `ExamItemController` | 在套餐中添加新检查项（权限：ADMIN） |
| **编辑项目** | `/api/exam/packages/{packageId}/items/{id}` | PUT | `xixin-exam` | `ExamItemController` | 修改检查项目的名称或描述（权限：ADMIN） |
| **删除项目** | `/api/exam/packages/{packageId}/items/{id}` | DELETE | `xixin-exam` | `ExamItemController` | 从套餐中移除某个检查项目（权限：ADMIN） |

### 3.6 字典维护

| 流程图步骤 | 接口 | 方法 | 微服务 | Controller 类 | 作用 |
|-----------|------|:--:|--------|---------------|------|
| **字典类型列表** | `/api/system/dict-types` | GET | `xixin-system` | `DictTypeController` | 查看所有字典分类（权限：ADMIN） |
| **查看字典类型** | `/api/system/dict-types/{id}` | GET | `xixin-system` | `DictTypeController` | 查看某个字典类型的详情 |
| **新增字典类型** | `/api/system/dict-types` | POST | `xixin-system` | `DictTypeController` | 创建新的字典分类（权限：ADMIN） |
| **编辑字典类型** | `/api/system/dict-types` | PUT | `xixin-system` | `DictTypeController` | 修改字典类型的名称或编码（权限：ADMIN） |
| **删除字典类型** | `/api/system/dict-types/{id}` | DELETE | `xixin-system` | `DictTypeController` | 删除字典分类，逻辑删除（权限：ADMIN） |
| **字典项列表** | `/api/system/dict-items/by-type/{typeId}` | GET | `xixin-system` | `DictItemController` | 查看某分类下的所有选项（**权限：PATIENT、ADMIN**；PATIENT 用于预约类型下拉框） |
| **查看字典项** | `/api/system/dict-items/{id}` | GET | `xixin-system` | `DictItemController` | 查看某个字典项详情（权限：ADMIN） |
| **新增字典项** | `/api/system/dict-items` | POST | `xixin-system` | `DictItemController` | 添加新的选项值（权限：ADMIN） |
| **编辑字典项** | `/api/system/dict-items` | PUT | `xixin-system` | `DictItemController` | 修改字典项的标签、值或排序（权限：ADMIN） |
| **删除字典项** | `/api/system/dict-items/{id}` | DELETE | `xixin-system` | `DictItemController` | 删除某个选项，逻辑删除（权限：ADMIN） |

### 3.7 医生/患者档案查询

| 流程图步骤 | 接口 | 方法 | 微服务 | Controller 类 | 作用 |
|-----------|------|:--:|--------|---------------|------|
| **医生列表** | `/api/user/doctors` | GET | `xixin-user` | `DoctorController` | 查看系统所有医生档案（权限：DOCTOR、ADMIN） |
| **医生详情** | `/api/user/doctors/{id}` | GET | `xixin-user` | `DoctorController` | 查看医生的科室、职称、专长 |
| **患者列表** | `/api/user/patients` | GET | `xixin-user` | `PatientController` | 查看系统所有患者档案（权限：DOCTOR、ADMIN） |
| **患者详情** | `/api/user/patients/{id}` | GET | `xixin-user` | `PatientController` | 查看患者的完整个人信息 |

---

## 四、微服务 ↔ Controller 汇总

| 微服务 | 端口 | 数据库 | Controller 类 | 负责功能 |
|--------|:---:|--------|--------------|------|
| `xixin-gateway` | 8080 | — | `AuthGlobalFilter` | 统一入口、JWT 认证拦截、注入 X-User-Id/X-Username/X-User-Role 请求头至下游 |
| `xixin-auth` | 8100 | xixin_user | `AuthController` | 登录、注册 |
| | | | `UserController` | 用户 CRUD、启用/禁用、重置密码（ADMIN） |
| `xixin-user` | 8110 | xixin_user | `DoctorController` | 医生档案列表、详情（DOCTOR、ADMIN） |
| | | | `PatientController` | 患者档案列表、详情（DOCTOR、ADMIN） |
| `xixin-exam` | 8120 | xixin_exam | `AppointmentFlowController` | 级联选择：预约类型→机构、机构→套餐（PATIENT） |
| | | | `AppointmentController` | 预约 CRUD、提交自动确认+分配医生、取消、数据隔离 |
| | | | `ExamPackageController` | 套餐 CRUD、上下架、详情含检查项目 |
| | | | `ExamItemController` | 检查项目 CRUD（查询 PATIENT+ADMIN，写入 ADMIN） |
| | | | `InstitutionController` | 机构 CRUD、启用机构列表 |
| `xixin-report` | 8130 | xixin_report | `ReportController` | 报告 CRUD、生成（直接发布）、数据隔离 |
| | | | `ReportItemController` | 报告项目明细 CRUD、批量录入 |
| `xixin-system` | 8140 | xixin_system | `RoleController` | 角色 CRUD（ADMIN） |
| | | | `DictTypeController` | 字典类型 CRUD（ADMIN） |
| | | | `DictItemController` | 字典项 CRUD（查询 PATIENT+ADMIN，写入 ADMIN） |
| `xixin-common` | — | — | `RoleAspect` | AOP 角色权限校验（`@RequireRole` 注解拦截，无 Spring Security 依赖） |
| | | | `UserContext` / `UserContextFilter` | 从网关请求头提取用户信息到 ThreadLocal |
| | | | `GlobalExceptionHandler` | 全局异常处理、参数校验错误格式化 |
| | | | `BaseEntity`、`R`、`PageResult` | 公共基类、统一响应、分页封装 |

---

## 五、接口总数汇总

| 模块 | 接口数 | 权限 | 所属 Controller |
|------|:-----:|------|------|
| 认证（登录/注册） | 2 | 公开 | `AuthController` |
| 用户管理 | 6 | ADMIN | `UserController` |
| 预约类型→机构查询 | 1 | PATIENT | `AppointmentFlowController` |
| 机构→套餐查询 | 1 | PATIENT | `AppointmentFlowController` |
| 机构管理 | 6 | PATIENT + ADMIN | `InstitutionController` |
| 套餐管理 | 6 | PATIENT + ADMIN | `ExamPackageController` |
| 检查项目管理 | 5 | PATIENT + ADMIN（读）/ ADMIN（写） | `ExamItemController` |
| 预约管理 | 5 | PATIENT + DOCTOR + ADMIN（数据隔离） | `AppointmentController` |
| 报告管理 | 5 | PATIENT + DOCTOR + ADMIN（数据隔离） | `ReportController` |
| 报告项目明细 | 7 | PATIENT+DOCTOR+ADMIN（读）/ DOCTOR（写） | `ReportItemController` |
| 角色管理 | 5 | ADMIN | `RoleController` |
| 字典类型维护 | 5 | ADMIN | `DictTypeController` |
| 字典项维护 | 5 | PATIENT + ADMIN（读）/ ADMIN（写） | `DictItemController` |
| 医生/患者查询 | 4 | DOCTOR + ADMIN | `DoctorController` / `PatientController` |
| **合计** | **63** | | **14 个 Controller** |

---

## 六、数据库表说明

### xixin_user 数据库（用户与角色）

| 表名 | 作用 | 存储内容 |
|------|------|------|
| **t_user** | 系统用户表 | 用户名、密码(明文)、真实姓名、手机号、邮箱、头像、角色(ADMIN/DOCTOR/PATIENT)、启用状态 |
| **t_patient** | 患者档案表 | 关联用户ID、姓名、性别、出生日期、身份证号、地址、紧急联系人及电话 |
| **t_doctor** | 医生档案表 | 关联用户ID、科室、职称、专长、简介。一个医生关联一个套餐（packageId） |

### xixin_exam 数据库（体检业务）

| 表名 | 作用 | 存储内容 |
|------|------|------|
| **t_exam_package** | 体检套餐表 | 套餐名称、价格、描述、**绑定的医生ID（doctorId）**、上架/下架状态、排序。患者预约此套餐后系统自动分配给绑定的医生 |
| **t_exam_item** | 检查项目表 | 所属套餐ID、项目名称、类型(检验/影像/心电/体格)、描述、排序 |
| **t_institution** | 体检机构表 | 机构名称、地址、电话、营业时间、描述、启用状态、排序 |
| **t_appt_type_institution** | 预约类型↔机构关联表 | 预约类型编码与机构ID的多对多映射 |
| **t_institution_package** | 机构↔套餐关联表 | 机构ID与套餐ID的多对多映射 |
| **t_appointment** | 预约记录表 | 用户ID、套餐ID、机构ID、预约日期、时间段、状态、备注、负责医生(doctorId) |

### xixin_report 数据库（体检报告）

| 表名 | 作用 | 存储内容 |
|------|------|------|
| **t_report** | 体检报告表 | 用户ID、关联预约ID、医生ID、检查摘要、总检结论、状态(2=已发布)、生成时间 |
| **t_report_item** | 报告明细表 | 报告ID、检查项目ID、项目名称、检查结果、参考范围、异常标志 |

### xixin_system 数据库（系统配置）

| 表名 | 作用 | 存储内容 |
|------|------|------|
| **t_role** | 角色表 | 角色名称、角色编码(唯一)、描述、状态 |
| **t_dict_type** | 字典类型表 | 字典名称、字典类型编码(唯一)、状态 |
| **t_dict_item** | 字典项表 | 所属字典类型ID、标签、值、排序、状态 |

### 数据流程图

```
注册 → t_user(账号) + t_patient(档案)
  ↓
登录 → JWT Token(含userId/role)
  ↓                  ↓
网关 AuthGlobalFilter  下游 UserContextFilter
(校验JWT，注入Header)   (提取Header到ThreadLocal)
                          ↓
                    RoleAspect AOP 切面
                    (校验 @RequireRole 注解)
  ↓
选预约类型 → t_dict_type[id=4] → t_dict_item(4条)
  ↓
选机构 → t_appt_type_institution(type→institutionIds) → t_institution(status=1)
  ↓
选套餐 → t_institution_package(institutionId→packageIds) → t_exam_package(status=1, doctorId)
  ↓
查看详情 → t_exam_package + t_exam_item（items 内嵌返回）
  ↓
提交预约 → t_appointment(userId从Token获取,packageId,institutionId,date,timeSlot)
  ↓ 系统自动：status=1(已确认), doctorId=套餐绑定的doctorId
体检完成
  ↓
录入结果 → t_report(userId,doctorId从Token获取,summary,conclusion) + t_report_item(results)
  ↓
报告直接发布（status=2），患者可查看
```

---

## 七、权限机制说明

### RBAC 架构

本系统采用轻量级 AOP + 注解方式实现角色权限控制，**未引入 Spring Security**。

1. **网关层** (`AuthGlobalFilter`)：校验 JWT 有效性，将 userId / username / role 注入 `X-User-*` 请求头
2. **公共模块** (`UserContextFilter` + `UserContext`)：从请求头提取用户信息到 ThreadLocal
3. **AOP 切面** (`RoleAspect`)：拦截 `@RequireRole` 注解，比对当前用户角色与接口要求角色，不匹配则抛 403
4. **数据隔离**：Controller 层根据 `UserContext.getRole()` 动态构造 `LambdaQueryWrapper` 过滤条件

### 角色权限矩阵

| 功能 | PATIENT | DOCTOR | ADMIN |
|------|:--:|:--:|:--:|
| 注册/登录 | ✅ | ✅ | ✅ |
| 查看套餐（含检查项目） | ✅ | — | ✅ |
| 提交预约 | ✅ | — | — |
| 取消预约 | ✅（仅本人） | — | — |
| 查看预约 | ✅（仅本人，不分页） | ✅（仅分配给自己，分页） | ✅（全部，分页） |
| 查看报告 | ✅（仅本人） | ✅（仅自己生成） | ✅（全部） |
| 录入报告 | — | ✅ | — |
| 修改报告 | — | ✅（仅自己生成） | — |
| 查看患者档案 | — | ✅ | ✅ |
| 用户管理 | — | — | ✅ |
| 套餐管理（增删改） | — | — | ✅ |
| 机构管理（增删改） | — | — | ✅ |
| 角色管理 | — | — | ✅ |
| 字典维护 | — | — | ✅ |
| 删除预约/报告 | — | — | ✅ |
