<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElButton, ElDialog, ElForm, ElFormItem, ElInput, ElSelect, ElOption, ElSwitch } from 'element-plus'
import { Plus, Search, RefreshRight, SwitchButton } from '@element-plus/icons-vue'
import type { User, Patient, Doctor } from '@/types'
import { useUserStore } from '@/stores/user'
import { getUserList, updateUser, updateUserStatus, resetUserPassword, deleteUser } from '@/api/auth'
import { getPatientDetail } from '@/api/patient'
import { getDoctorDetail } from '@/api/doctor'

const userStore = useUserStore()

const users = ref<User[]>([])
const loading = ref(false)
const page = ref(1)
const size = ref(10)
const total = ref(0)
const searchKeyword = ref('')

const dialogVisible = ref(false)
const dialogMode = ref<'add' | 'edit'>('edit')
const form = ref<Partial<User>>({})
const formRef = ref<InstanceType<typeof ElForm>>()
const submitting = ref(false)

const resetDialogVisible = ref(false)
const resetTarget = ref<User | null>(null)
const newPassword = ref('')

// 档案详情
const profileDialogVisible = ref(false)
const profileUser = ref<User | null>(null)
const patientProfile = ref<Patient | null>(null)
const doctorProfile = ref<Doctor | null>(null)
const profileLoading = ref(false)

async function loadUsers() {
  loading.value = true
  try {
    const res = await getUserList(page.value, size.value, searchKeyword.value)
    users.value = res.records
    total.value = res.total
  } catch (err: any) {
    alert('加载用户列表失败: ' + err.message)
  } finally {
    loading.value = false
  }
}

function openAddDialog() {
  dialogMode.value = 'add'
  form.value = { role: 'PATIENT', status: 1 }
  dialogVisible.value = true
}

function openEditDialog(user: User) {
  dialogMode.value = 'edit'
  form.value = { ...user }
  dialogVisible.value = true
}

async function handleSubmit() {
  if (!formRef.value) return
  await formRef.value.validate()
  submitting.value = true
  try {
    if (dialogMode.value === 'edit' && form.value.id) {
      await updateUser(form.value.id, {
        realName: form.value.realName,
        phone: form.value.phone,
        email: form.value.email,
        role: form.value.role,
      })
      alert('修改成功')
    }
    dialogVisible.value = false
    loadUsers()
  } catch (err: any) {
    alert('操作失败: ' + err.message)
  } finally {
    submitting.value = false
  }
}

async function handleToggleStatus(user: User) {
  const newStatus = user.status === 1 ? 0 : 1
  const action = newStatus === 1 ? '启用' : '禁用'
  if (!confirm(`确定要${action}用户 "${user.username}" 吗？`)) return
  try {
    await updateUserStatus(user.id, newStatus)
    alert(`${action}成功`)
    loadUsers()
  } catch (err: any) {
    alert('操作失败: ' + err.message)
  }
}

function openResetDialog(user: User) {
  resetTarget.value = user
  newPassword.value = ''
  resetDialogVisible.value = true
}

async function handleResetPassword() {
  if (!resetTarget.value || !newPassword.value) return
  try {
    await resetUserPassword(resetTarget.value.id, newPassword.value)
    alert('密码重置成功')
    resetDialogVisible.value = false
  } catch (err: any) {
    alert('密码重置失败: ' + err.message)
  }
}

async function handleDelete(user: User) {
  if (!confirm(`确定要删除用户 "${user.username}" 吗？此操作不可恢复！`)) return
  try {
    await deleteUser(user.id)
    alert('删除成功')
    loadUsers()
  } catch (err: any) {
    alert('删除失败: ' + err.message)
  }
}

// 档案详情
async function openProfileDialog(user: User) {
  profileUser.value = user
  patientProfile.value = null
  doctorProfile.value = null
  profileDialogVisible.value = true
  profileLoading.value = true
  try {
    if (user.role === 'PATIENT') {
      patientProfile.value = await getPatientDetail(user.id)
    } else if (user.role === 'DOCTOR') {
      doctorProfile.value = await getDoctorDetail(user.id)
    }
  } catch (err: any) {
    // 静默失败，部分用户可能没有档案
  } finally {
    profileLoading.value = false
  }
}

function handleLogout() {
  if (confirm('确定要退出登录吗？')) {
    userStore.logout()
  }
}

onMounted(loadUsers)
</script>

<template>
  <div class="admin-page">
    <div class="admin-header">
      <h2 class="admin-title">用户管理</h2>
      <div class="admin-actions">
        <el-input
          v-model="searchKeyword"
          placeholder="搜索用户名/姓名"
          size="small"
          style="width: 140px"
          :prefix-icon="Search"
        />
        <el-button type="primary" size="small" :icon="Plus" circle @click="openAddDialog" />
        <el-button size="small" :icon="RefreshRight" circle @click="loadUsers" />
        <el-button type="danger" size="small" :icon="SwitchButton" circle @click="handleLogout" />
      </div>
    </div>

    <div class="admin-content">
      <div v-if="loading" class="loading-text">加载中...</div>
      <div v-else-if="users.length === 0" class="empty-text">暂无用户数据</div>
      <div v-else class="card-list">
        <div v-for="user in users" :key="user.id" class="data-card" @click="openProfileDialog(user)">
          <div class="card-header-row">
            <span class="card-title">{{ user.realName || user.username }}</span>
            <el-tag :type="user.status === 1 ? 'success' : 'danger'" size="small">
              {{ user.status === 1 ? '正常' : '禁用' }}
            </el-tag>
          </div>
          <div class="card-info">
            <p>用户名：{{ user.username }}</p>
            <p>角色：<el-tag size="small" type="info">{{ user.role }}</el-tag></p>
            <p v-if="user.phone">手机：{{ user.phone }}</p>
            <p v-if="user.email">邮箱：{{ user.email }}</p>
          </div>
          <div class="card-actions" @click.stop>
            <el-button type="primary" size="small" text @click="openEditDialog(user)">编辑</el-button>
            <el-button
              :type="user.status === 1 ? 'danger' : 'success'"
              size="small"
              text
              @click="handleToggleStatus(user)"
            >
              {{ user.status === 1 ? '禁用' : '启用' }}
            </el-button>
            <el-button type="warning" size="small" text @click="openResetDialog(user)">重置密码</el-button>
            <el-button type="danger" size="small" text @click="handleDelete(user)">删除</el-button>
          </div>
        </div>
      </div>
    </div>

    <!-- 编辑/新增弹窗 -->
    <el-dialog v-model="dialogVisible" :title="dialogMode === 'edit' ? '编辑用户' : '新增用户'" width="90%">
      <el-form ref="formRef" :model="form" label-width="70px">
        <el-form-item label="用户名" v-if="dialogMode === 'edit'">
          <el-input v-model="form.username" disabled />
        </el-form-item>
        <el-form-item label="真实姓名">
          <el-input v-model="form.realName" placeholder="请输入真实姓名" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="form.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="form.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="角色">
          <el-select v-model="form.role" placeholder="请选择角色" style="width: 100%">
            <el-option label="管理员" value="ADMIN" />
            <el-option label="医生" value="DOCTOR" />
            <el-option label="患者" value="PATIENT" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button size="small" @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" size="small" :loading="submitting" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 重置密码弹窗 -->
    <el-dialog v-model="resetDialogVisible" title="重置密码" width="90%">
      <p style="margin-bottom: 12px; font-size: 14px; color: #666;">
        正在为 <strong>{{ resetTarget?.username }}</strong> 重置密码
      </p>
      <el-input v-model="newPassword" placeholder="请输入新密码" show-password />
      <template #footer>
        <el-button size="small" @click="resetDialogVisible = false">取消</el-button>
        <el-button type="primary" size="small" @click="handleResetPassword">确定</el-button>
      </template>
    </el-dialog>

    <!-- 档案详情弹窗 -->
    <el-dialog v-model="profileDialogVisible" title="用户档案" width="90%">
      <div v-if="profileLoading" class="loading-text">加载中...</div>
      <div v-else-if="!profileUser" class="empty-text">无用户数据</div>
      <div v-else>
        <!-- 用户基本信息 -->
        <div class="profile-section">
          <h3 class="profile-section-title">基本信息</h3>
          <div class="profile-info">
            <p><strong>用户名：</strong>{{ profileUser.username }}</p>
            <p><strong>真实姓名：</strong>{{ profileUser.realName }}</p>
            <p><strong>角色：</strong><el-tag size="small" type="info">{{ profileUser.role }}</el-tag></p>
            <p v-if="profileUser.phone"><strong>手机：</strong>{{ profileUser.phone }}</p>
            <p v-if="profileUser.email"><strong>邮箱：</strong>{{ profileUser.email }}</p>
            <p><strong>状态：</strong><el-tag :type="profileUser.status === 1 ? 'success' : 'danger'" size="small">{{ profileUser.status === 1 ? '正常' : '禁用' }}</el-tag></p>
          </div>
        </div>

        <!-- 患者档案 -->
        <div v-if="profileUser.role === 'PATIENT'" class="profile-section">
          <h3 class="profile-section-title">患者档案</h3>
          <div v-if="!patientProfile" class="empty-text">暂无患者档案</div>
          <div v-else class="profile-info">
            <p><strong>姓名：</strong>{{ patientProfile.name }}</p>
            <p><strong>性别：</strong>{{ patientProfile.gender === 1 ? '男' : patientProfile.gender === 0 ? '女' : '未知' }}</p>
            <p v-if="patientProfile.birthday"><strong>生日：</strong>{{ patientProfile.birthday }}</p>
            <p v-if="patientProfile.idCard"><strong>身份证号：</strong>{{ patientProfile.idCard }}</p>
            <p v-if="patientProfile.address"><strong>地址：</strong>{{ patientProfile.address }}</p>
            <p v-if="patientProfile.emergencyContact"><strong>紧急联系人：</strong>{{ patientProfile.emergencyContact }}</p>
            <p v-if="patientProfile.emergencyPhone"><strong>紧急电话：</strong>{{ patientProfile.emergencyPhone }}</p>
          </div>
        </div>

        <!-- 医生档案 -->
        <div v-if="profileUser.role === 'DOCTOR'" class="profile-section">
          <h3 class="profile-section-title">医生档案</h3>
          <div v-if="!doctorProfile" class="empty-text">暂无医生档案</div>
          <div v-else class="profile-info">
            <p v-if="doctorProfile.department"><strong>科室：</strong>{{ doctorProfile.department }}</p>
            <p v-if="doctorProfile.title"><strong>职称：</strong>{{ doctorProfile.title }}</p>
            <p v-if="doctorProfile.specialty"><strong>专长：</strong>{{ doctorProfile.specialty }}</p>
            <p v-if="doctorProfile.introduction"><strong>简介：</strong>{{ doctorProfile.introduction }}</p>
          </div>
        </div>
      </div>
      <template #footer>
        <el-button size="small" @click="profileDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.admin-page {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.admin-header {
  padding: 16px;
  background: white;
  border-bottom: 1px solid #f3f4f6;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-shrink: 0;
}

.admin-title {
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
}

.admin-actions {
  display: flex;
  gap: 8px;
  align-items: center;
}

.admin-content {
  flex: 1;
  overflow-y: auto;
  padding: 12px;
  background: #f9fafb;
}

.loading-text,
.empty-text {
  text-align: center;
  padding: 40px 0;
  color: #9ca3af;
  font-size: 14px;
}

.card-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.data-card {
  background: white;
  border-radius: 12px;
  padding: 14px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
  cursor: pointer;
  transition: box-shadow 0.2s;
}

.data-card:active {
  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
}

.card-header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
}

.card-info p {
  font-size: 13px;
  color: #6b7280;
  margin: 4px 0;
  line-height: 1.5;
}

.card-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  margin-top: 10px;
  padding-top: 10px;
  border-top: 1px solid #f3f4f6;
}

.profile-section {
  margin-bottom: 16px;
}

.profile-section-title {
  font-size: 15px;
  font-weight: 600;
  color: #374151;
  margin-bottom: 8px;
  padding-bottom: 6px;
  border-bottom: 1px solid #f3f4f6;
}

.profile-info p {
  font-size: 14px;
  color: #4b5563;
  margin: 6px 0;
  line-height: 1.5;
}
</style>
