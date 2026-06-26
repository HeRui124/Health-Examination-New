<script setup lang="ts">
import { ref, provide, computed, watch, onMounted } from 'vue'
import { HomeFilled, DocumentChecked, UserFilled, Iphone, ChatDotRound, Lightning, FirstAidKit, Document, Notebook, User, Box, OfficeBuilding } from '@element-plus/icons-vue'
import { useUserStore } from './stores/user'
import HomePage from './components/HomePage.vue'
import BookingPage from './components/BookingPage.vue'
import ProfilePage from './components/ProfilePage.vue'
import LoginPage from './components/LoginPage.vue'
import DoctorHomePage from './components/DoctorHomePage.vue'
import DoctorReportsPage from './components/DoctorReportsPage.vue'
import DoctorProfilePage from './components/DoctorProfilePage.vue'
import AdminUsersPage from './components/AdminUsersPage.vue'
import AdminPackagesPage from './components/AdminPackagesPage.vue'
import AdminInstitutionsPage from './components/AdminInstitutionsPage.vue'

type PatientTab = 'home' | 'booking' | 'profile'
type DoctorTab = 'workbench' | 'reports' | 'profile'
type AdminTab = 'users' | 'packages' | 'institutions'
type TabType = PatientTab | DoctorTab | AdminTab

const userStore = useUserStore()
const currentTab = ref<TabType>('home')
const profileRef = ref<InstanceType<typeof ProfilePage> | null>(null)
const toastVisible = ref(false)
const toastMessage = ref('')

const isLoggedIn = computed(() => userStore.isLoggedIn)
const userRole = computed(() => userStore.userRole)
const isDoctor = computed(() => userRole.value === 'DOCTOR')
const isAdmin = computed(() => userRole.value === 'ADMIN')

watch(isLoggedIn, (loggedIn) => {
  if (!loggedIn) {
    currentTab.value = 'home'
  } else if (isAdmin.value) {
    currentTab.value = 'users'
  } else if (isDoctor.value) {
    currentTab.value = 'workbench'
  } else {
    currentTab.value = 'home'
  }
})

// 初始化时根据角色设置默认 tab
onMounted(() => {
  if (isLoggedIn.value) {
    if (isAdmin.value) {
      currentTab.value = 'users'
    } else if (isDoctor.value) {
      currentTab.value = 'workbench'
    }
  }
})

function switchTab(tab: TabType) {
  currentTab.value = tab
}

function showToast(msg: string) {
  toastMessage.value = msg
  toastVisible.value = true
  setTimeout(() => {
    toastVisible.value = false
  }, 2000)
}

function handleLoginSuccess() {
  showToast('登录成功')
}

function handleBookingSubmit(data: any) {
  showToast('预约成功！正在跳转...')
  setTimeout(() => {
    if (profileRef.value) {
      profileRef.value.addNewAppointment(data)
    }
    currentTab.value = 'profile'
  }, 1500)
}

provide('showToast', showToast)
</script>

<template>
  <div class="app-container">
    <div class="mobile-frame">
      <!-- Status Bar -->
      <div class="status-bar">
        <span class="status-time">9:41</span>
        <div class="status-icons">
          <el-icon :size="12"><Iphone /></el-icon>
          <el-icon :size="12"><ChatDotRound /></el-icon>
          <el-icon :size="12"><Lightning /></el-icon>
        </div>
      </div>

      <!-- Page Content -->
      <div class="page-wrapper">
        <LoginPage v-if="!isLoggedIn" @loginSuccess="handleLoginSuccess" />
        <template v-else>
          <!-- 管理员页面 -->
          <template v-if="isAdmin">
            <AdminUsersPage v-show="currentTab === 'users'" />
            <AdminPackagesPage v-show="currentTab === 'packages'" />
            <AdminInstitutionsPage v-show="currentTab === 'institutions'" />
          </template>
          <!-- 患者页面 -->
          <template v-else-if="!isDoctor">
            <HomePage v-show="currentTab === 'home'" />
            <BookingPage
              v-show="currentTab === 'booking'"
              @submit="handleBookingSubmit"
            />
            <ProfilePage v-show="currentTab === 'profile'" ref="profileRef" />
          </template>
          <!-- 医生页面 -->
          <template v-else>
            <DoctorHomePage v-show="currentTab === 'workbench'" />
            <DoctorReportsPage v-show="currentTab === 'reports'" />
            <DoctorProfilePage v-show="currentTab === 'profile'" />
          </template>
        </template>
      </div>

      <!-- Bottom Tab Bar -->
      <div v-if="isLoggedIn" class="tab-bar">
        <!-- 管理员导航 -->
        <template v-if="isAdmin">
          <div
            class="tab-item"
            :class="{ active: currentTab === 'users' }"
            @click="switchTab('users')"
          >
            <el-icon :size="22"><User /></el-icon>
            <span class="tab-label">用户</span>
          </div>
          <div
            class="tab-item"
            :class="{ active: currentTab === 'packages' }"
            @click="switchTab('packages')"
          >
            <el-icon :size="22"><Box /></el-icon>
            <span class="tab-label">套餐</span>
          </div>
          <div
            class="tab-item"
            :class="{ active: currentTab === 'institutions' }"
            @click="switchTab('institutions')"
          >
            <el-icon :size="22"><OfficeBuilding /></el-icon>
            <span class="tab-label">机构</span>
          </div>
        </template>
        <!-- 患者导航 -->
        <template v-else-if="!isDoctor">
          <div
            class="tab-item"
            :class="{ active: currentTab === 'home' }"
            @click="switchTab('home')"
          >
            <el-icon :size="22"><HomeFilled /></el-icon>
            <span class="tab-label">首页</span>
          </div>
          <div
            class="tab-item"
            :class="{ active: currentTab === 'booking' }"
            @click="switchTab('booking')"
          >
            <el-icon :size="22"><DocumentChecked /></el-icon>
            <span class="tab-label">预约</span>
          </div>
          <div
            class="tab-item"
            :class="{ active: currentTab === 'profile' }"
            @click="switchTab('profile')"
          >
            <el-icon :size="22"><UserFilled /></el-icon>
            <span class="tab-label">我的</span>
          </div>
        </template>
        <!-- 医生导航 -->
        <template v-else>
          <div
            class="tab-item"
            :class="{ active: currentTab === 'workbench' }"
            @click="switchTab('workbench')"
          >
            <el-icon :size="22"><FirstAidKit /></el-icon>
            <span class="tab-label">预约管理</span>
          </div>
          <div
            class="tab-item"
            :class="{ active: currentTab === 'reports' }"
            @click="switchTab('reports')"
          >
            <el-icon :size="22"><Notebook /></el-icon>
            <span class="tab-label">报告管理</span>
          </div>
          <div
            class="tab-item"
            :class="{ active: currentTab === 'profile' }"
            @click="switchTab('profile')"
          >
            <el-icon :size="22"><UserFilled /></el-icon>
            <span class="tab-label">我的</span>
          </div>
        </template>
      </div>

      <!-- Toast -->
      <transition name="toast">
        <div v-if="toastVisible" class="toast">
          {{ toastMessage }}
        </div>
      </transition>
    </div>
  </div>
</template>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  background-color: #f3f4f6;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
}

#app {
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
}
</style>

<style scoped>
.app-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  padding: 20px;
}

.mobile-frame {
  width: 375px;
  height: 812px;
  background-color: #f9fafb;
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  border-radius: 40px;
  border: 8px solid #1f2937;
}

.status-bar {
  height: 40px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 24px;
  padding-top: 12px;
  flex-shrink: 0;
}

.status-time {
  font-size: 12px;
  font-weight: 600;
  color: #1f2937;
}

.status-icons {
  display: flex;
  gap: 4px;
  align-items: center;
}

.page-wrapper {
  flex: 1;
  overflow-y: auto;
  scrollbar-width: none;
}

.page-wrapper::-webkit-scrollbar {
  display: none;
}

.tab-bar {
  height: 64px;
  background: white;
  border-top: 1px solid #f3f4f6;
  display: flex;
  justify-content: space-around;
  align-items: center;
  padding-bottom: 8px;
  flex-shrink: 0;
}

.tab-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  cursor: pointer;
  color: #9ca3af;
  transition: color 0.2s;
}

.tab-item.active {
  color: #0d9488;
}

.tab-label {
  font-size: 10px;
  font-weight: 500;
}

.toast {
  position: absolute;
  bottom: 80px;
  left: 50%;
  transform: translateX(-50%);
  background: #374151;
  color: white;
  padding: 8px 20px;
  border-radius: 20px;
  font-size: 12px;
  z-index: 100;
}

.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s ease;
}

.toast-enter-from,
.toast-leave-to {
  opacity: 0;
  transform: translateX(-50%) translateY(20px);
}
</style>
