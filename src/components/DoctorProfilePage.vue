<script setup lang="ts">
import { computed, ref, onMounted } from 'vue'
import { UserFilled, FirstAidKit, DocumentChecked, SwitchButton, OfficeBuilding, Medal, Star, Document } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { getDoctorDetail } from '@/api/doctor'
import type { Doctor } from '@/types'

const userStore = useUserStore()

const doctorDetail = ref<Doctor | null>(null)
const loading = ref(false)

async function loadDoctorProfile() {
  if (!userStore.userId) return
  loading.value = true
  try {
    const data = await getDoctorDetail(userStore.userId)
    doctorDetail.value = data
  } catch (err: any) {
    console.error('加载医生档案失败:', err.message)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadDoctorProfile()
})

function handleLogout() {
  userStore.logout()
}

const user = computed(() => ({
  name: userStore.user?.realName || '医生',
  username: userStore.user?.username || '',
  role: userStore.user?.role || 'DOCTOR',
  avatar: userStore.user?.avatar || 'https://modao.cc/agent-py/media/generated_images/2026-06-03/14abbabc406b43ec8a82b7f7edd276b5.jpg',
}))
</script>

<template>
  <div class="doctor-profile-page">
    <!-- User Info Card -->
    <div class="user-card">
      <div class="user-header">
        <el-avatar :size="64" :src="user.avatar" class="user-avatar" />
        <div class="user-info">
          <h2 class="user-name">{{ user.name }}</h2>
          <p class="user-role">体检医生</p>
          <p class="user-username">{{ user.username }}</p>
        </div>
        <el-icon class="logout-icon" :size="24" @click="handleLogout"><SwitchButton /></el-icon>
      </div>

      <div class="quick-actions">
        <div class="action-item">
          <div class="action-icon" style="background: #f0fdfa; color: #0d9488;">
            <el-icon :size="20"><FirstAidKit /></el-icon>
          </div>
          <span class="action-label">预约管理</span>
        </div>
        <div class="action-item">
          <div class="action-icon" style="background: #eff6ff; color: #3b82f6;">
            <el-icon :size="20"><DocumentChecked /></el-icon>
          </div>
          <span class="action-label">报告管理</span>
        </div>
      </div>
    </div>

    <!-- Doctor Profile -->
    <div class="menu-section">
      <div class="menu-group">
        <div v-if="loading" class="menu-loading">
          <el-skeleton :rows="3" animated />
        </div>
        <template v-else-if="doctorDetail">
          <div class="menu-item">
            <div class="menu-left">
              <el-icon :size="18" color="#0d9488"><OfficeBuilding /></el-icon>
              <span class="menu-label">所属科室</span>
            </div>
            <span class="menu-value">{{ doctorDetail.department || '—' }}</span>
          </div>
          <div class="menu-item">
            <div class="menu-left">
              <el-icon :size="18" color="#0d9488"><Medal /></el-icon>
              <span class="menu-label">职称</span>
            </div>
            <span class="menu-value">{{ doctorDetail.title || '—' }}</span>
          </div>
          <div class="menu-item">
            <div class="menu-left">
              <el-icon :size="18" color="#0d9488"><Star /></el-icon>
              <span class="menu-label">专长领域</span>
            </div>
            <span class="menu-value">{{ doctorDetail.specialty || '—' }}</span>
          </div>
          <div class="menu-item menu-item-block">
            <div class="menu-left">
              <el-icon :size="18" color="#0d9488"><Document /></el-icon>
              <span class="menu-label">个人简介</span>
            </div>
            <p class="intro-text">{{ doctorDetail.introduction || '暂无简介' }}</p>
          </div>
        </template>
        <div v-else class="menu-empty">
          未获取到医生档案
        </div>
      </div>
    </div>

    <!-- Basic Info -->
    <div class="menu-section">
      <div class="menu-group">
        <div class="menu-item">
          <div class="menu-left">
            <el-icon :size="18" color="#0d9488"><UserFilled /></el-icon>
            <span class="menu-label">角色身份</span>
          </div>
          <span class="menu-value">医生</span>
        </div>
        <div class="menu-item">
          <div class="menu-left">
            <el-icon :size="18" color="#0d9488"><FirstAidKit /></el-icon>
            <span class="menu-label">所属系统</span>
          </div>
          <span class="menu-value">熙心体检</span>
        </div>
      </div>
    </div>

    <!-- Logout Button -->
    <div class="logout-section">
      <el-button class="logout-btn" @click="handleLogout">
        <el-icon :size="16"><SwitchButton /></el-icon>
        退出登录
      </el-button>
    </div>

    <p class="version-text">熙心健康体检管理系统 v1.0</p>
  </div>
</template>

<style scoped>
.doctor-profile-page {
  padding-bottom: 20px;
}

.user-card {
  background: white;
  padding: 24px 20px 20px;
  border-radius: 0 0 32px 32px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
}

.user-header {
  display: flex;
  align-items: center;
  gap: 16px;
}

.user-avatar {
  border: 4px solid #f0fdfa;
}

.user-info {
  flex: 1;
}

.user-name {
  font-size: 18px;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.user-role {
  font-size: 12px;
  color: #0d9488;
  font-weight: 600;
  margin: 4px 0 0;
}

.user-username {
  font-size: 11px;
  color: #9ca3af;
  margin: 2px 0 0;
}

.logout-icon {
  color: #d1d5db;
  cursor: pointer;
  transition: color 0.2s;
}

.logout-icon:hover {
  color: #ef4444;
}

.quick-actions {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
  margin-top: 20px;
}

.action-item {
  background: #f9fafb;
  border-radius: 12px;
  padding: 16px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  transition: all 0.2s;
}

.action-item:hover {
  background: #f3f4f6;
}

.action-icon {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.action-label {
  font-size: 13px;
  font-weight: 600;
  color: #374151;
}

.menu-section {
  margin-top: 24px;
  padding: 0 20px;
}

.menu-group {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}

.menu-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-bottom: 1px solid #f9fafb;
}

.menu-item:last-child {
  border-bottom: none;
}

.menu-item-block {
  flex-direction: column;
  align-items: flex-start;
  gap: 8px;
}

.intro-text {
  font-size: 13px;
  color: #6b7280;
  line-height: 1.6;
  margin: 0;
}

.menu-loading {
  padding: 16px;
}

.menu-empty {
  padding: 24px 16px;
  text-align: center;
  font-size: 13px;
  color: #9ca3af;
}

.menu-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.menu-label {
  font-size: 14px;
  color: #374151;
}

.menu-value {
  font-size: 13px;
  color: #9ca3af;
}

.logout-section {
  margin-top: 24px;
  padding: 0 20px;
}

.logout-btn {
  width: 100%;
  height: 44px;
  border-radius: 12px;
  font-size: 14px;
  font-weight: 600;
  color: #ef4444;
  background: white;
  border: 1px solid #fee2e2;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.logout-btn:hover {
  background: #fef2f2;
  border-color: #fecaca;
}

.version-text {
  text-align: center;
  font-size: 11px;
  color: #d1d5db;
  margin-top: 20px;
}
</style>
