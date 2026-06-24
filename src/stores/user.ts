import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User, UserRole } from '@/types'

// 由于暂不实现登录功能，默认使用测试用户 testuser01 (id=2)
const DEFAULT_USER: User = {
  id: 2,
  username: 'testuser01',
  realName: '测试患者甲',
  phone: '13911111111',
  email: 'test01@test.com',
  role: 'PATIENT',
  status: 1,
}

// 从 localStorage 恢复用户信息
function loadUserFromStorage(): User | null {
  const raw = localStorage.getItem('userInfo')
  if (!raw) return null
  try {
    return JSON.parse(raw) as User
  } catch {
    return null
  }
}

export const useUserStore = defineStore('user', () => {
  // State
  const token = ref<string>(localStorage.getItem('accessToken') || '')
  const user = ref<User | null>(loadUserFromStorage())

  // Getters
  const isLoggedIn = computed(() => !!token.value && !!user.value)
  const userRole = computed<UserRole | null>(() => user.value?.role ?? null)
  const userId = computed<number | null>(() => user.value?.id ?? null)

  // Actions
  function setToken(newToken: string) {
    token.value = newToken
    localStorage.setItem('accessToken', newToken)
  }

  function setUserInfo(userInfo: User) {
    user.value = userInfo
    localStorage.setItem('userInfo', JSON.stringify(userInfo))
  }

  function initMockUser() {
    // 初始化模拟用户（用于开发测试，无需登录）
    setToken('mock-token-for-testuser01')
    setUserInfo({ ...DEFAULT_USER })
  }

  function logout() {
    token.value = ''
    user.value = null
    localStorage.removeItem('accessToken')
    localStorage.removeItem('userInfo')
  }

  return {
    token,
    user,
    isLoggedIn,
    userRole,
    userId,
    setToken,
    setUserInfo,
    initMockUser,
    logout,
  }
})
