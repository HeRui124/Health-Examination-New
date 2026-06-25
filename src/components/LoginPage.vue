<script setup lang="ts">
import { ref, reactive } from 'vue'
import { User, Lock, FirstAidKit } from '@element-plus/icons-vue'
import { login, register } from '@/api/auth'
import { useUserStore } from '@/stores/user'
import { parseJwt } from '@/utils/jwt'

const userStore = useUserStore()

type PageMode = 'login' | 'register'
const pageMode = ref<PageMode>('login')

type LoginMode = 'patient' | 'doctor'
const loginMode = ref<LoginMode>('patient')

const loginForm = reactive({
  username: '',
  password: '',
})

const registerForm = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  realName: '',
  phone: '',
  email: '',
})

const loading = ref(false)
const errorMsg = ref('')

async function handleLogin() {
  if (!loginForm.username.trim() || !loginForm.password) {
    errorMsg.value = '请输入用户名和密码'
    return
  }
  errorMsg.value = ''
  loading.value = true
  try {
    const res = await login({
      username: loginForm.username.trim(),
      password: loginForm.password,
    })
    userStore.setToken(res.accessToken)
    // 尝试从 JWT 中解析用户信息
    const payload = parseJwt(res.accessToken)
    userStore.setUserInfo({
      id: payload?.userId ?? 0,
      username: payload?.username || loginForm.username.trim(),
      realName: payload?.username || loginForm.username.trim(),
      role: (payload?.role as any) || 'PATIENT',
      status: 1,
    })
    emit('loginSuccess')
  } catch (err: any) {
    errorMsg.value = err.message || '登录失败，请检查用户名和密码'
  } finally {
    loading.value = false
  }
}

async function handleRegister() {
  if (!registerForm.username.trim()) {
    errorMsg.value = '请输入用户名'
    return
  }
  if (!registerForm.password) {
    errorMsg.value = '请输入密码'
    return
  }
  if (registerForm.password !== registerForm.confirmPassword) {
    errorMsg.value = '两次输入的密码不一致'
    return
  }
  if (!registerForm.realName.trim()) {
    errorMsg.value = '请输入真实姓名'
    return
  }
  if (registerForm.phone && !/^1[3-9]\d{9}$/.test(registerForm.phone)) {
    errorMsg.value = '手机号格式不正确'
    return
  }
  errorMsg.value = ''
  loading.value = true
  try {
    await register({
      username: registerForm.username.trim(),
      password: registerForm.password,
      realName: registerForm.realName.trim(),
      phone: registerForm.phone || undefined,
      email: registerForm.email || undefined,
      role: 'PATIENT',
    })
    // 注册成功，清空表单并切回登录
    registerForm.username = ''
    registerForm.password = ''
    registerForm.confirmPassword = ''
    registerForm.realName = ''
    registerForm.phone = ''
    registerForm.email = ''
    pageMode.value = 'login'
    errorMsg.value = ''
    alert('注册成功，请登录')
  } catch (err: any) {
    errorMsg.value = err.message || '注册失败，请稍后重试'
  } finally {
    loading.value = false
  }
}

const emit = defineEmits<{
  loginSuccess: []
}>()

function switchMode(mode: LoginMode) {
  loginMode.value = mode
  loginForm.username = ''
  loginForm.password = ''
  errorMsg.value = ''
}

function switchToRegister() {
  pageMode.value = 'register'
  errorMsg.value = ''
}

function switchToLogin() {
  pageMode.value = 'login'
  errorMsg.value = ''
}

function fillTestAccount() {
  if (loginMode.value === 'doctor') {
    loginForm.username = 'testdoc01'
    loginForm.password = '123456'
  } else {
    loginForm.username = 'testuser01'
    loginForm.password = '123456'
  }
  errorMsg.value = ''
}
</script>

<template>
  <div class="login-page">
    <div class="login-header">
      <div class="logo">
        <el-icon :size="48" color="#0d9488"><FirstAidKit /></el-icon>
      </div>
      <h1 class="app-name">熙心体检</h1>
      <p class="app-slogan">关爱健康，从体检开始</p>
    </div>

    <div class="login-form">
      <!-- 登录模式 -->
      <template v-if="pageMode === 'login'">
        <div class="mode-switch">
          <div
            class="mode-tab"
            :class="{ active: loginMode === 'patient' }"
            @click="switchMode('patient')"
          >
            患者登录
          </div>
          <div
            class="mode-tab"
            :class="{ active: loginMode === 'doctor' }"
            @click="switchMode('doctor')"
          >
            医生登录
          </div>
        </div>

        <el-input
          v-model="loginForm.username"
          placeholder="用户名"
          :prefix-icon="User"
          size="large"
          class="form-input"
          @keyup.enter="handleLogin"
        />

        <el-input
          v-model="loginForm.password"
          type="password"
          placeholder="密码"
          :prefix-icon="Lock"
          size="large"
          show-password
          class="form-input"
          @keyup.enter="handleLogin"
        />

        <el-alert
          v-if="errorMsg"
          :title="errorMsg"
          type="error"
          :closable="false"
          show-icon
          class="error-alert"
        />

        <el-button
          type="primary"
          size="large"
          class="login-btn"
          :loading="loading"
          @click="handleLogin"
        >
          登 录
        </el-button>

        <div class="register-link">
          <span @click="switchToRegister">患者注册</span>
        </div>

        <div class="test-account">
          <el-button link type="info" size="small" @click="fillTestAccount">
            填入测试账号
          </el-button>
        </div>
      </template>

      <!-- 注册模式 -->
      <template v-else>
        <div class="mode-header">
          <h3 class="mode-title">患者注册</h3>
          <span class="mode-back" @click="switchToLogin">返回登录</span>
        </div>

        <el-input
          v-model="registerForm.username"
          placeholder="用户名"
          :prefix-icon="User"
          size="large"
          class="form-input"
        />

        <el-input
          v-model="registerForm.password"
          type="password"
          placeholder="密码"
          :prefix-icon="Lock"
          size="large"
          show-password
          class="form-input"
        />

        <el-input
          v-model="registerForm.confirmPassword"
          type="password"
          placeholder="确认密码"
          :prefix-icon="Lock"
          size="large"
          show-password
          class="form-input"
        />

        <el-input
          v-model="registerForm.realName"
          placeholder="真实姓名"
          :prefix-icon="User"
          size="large"
          class="form-input"
        />

        <el-input
          v-model="registerForm.phone"
          placeholder="手机号（选填）"
          :prefix-icon="User"
          size="large"
          class="form-input"
        />

        <el-input
          v-model="registerForm.email"
          placeholder="邮箱（选填）"
          :prefix-icon="User"
          size="large"
          class="form-input"
        />

        <el-alert
          v-if="errorMsg"
          :title="errorMsg"
          type="error"
          :closable="false"
          show-icon
          class="error-alert"
        />

        <el-button
          type="primary"
          size="large"
          class="login-btn"
          :loading="loading"
          @click="handleRegister"
        >
          注 册
        </el-button>

        <div class="register-link">
          <span @click="switchToLogin">已有账号？去登录</span>
        </div>
      </template>
    </div>

    <div class="login-footer">
      <p>登录即代表您同意《用户协议》和《隐私政策》</p>
    </div>
  </div>
</template>

<style scoped>
.login-page {
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 0 32px;
  background: linear-gradient(180deg, #f0fdfa 0%, #ffffff 40%);
}

.login-header {
  text-align: center;
  margin-bottom: 40px;
}

.logo {
  width: 80px;
  height: 80px;
  background: white;
  border-radius: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 16px;
  box-shadow: 0 4px 12px rgba(13, 148, 136, 0.15);
}

.app-name {
  font-size: 24px;
  font-weight: 700;
  color: #1f2937;
  margin: 0 0 8px;
}

.app-slogan {
  font-size: 13px;
  color: #6b7280;
  margin: 0;
}

.login-form {
  background: white;
  border-radius: 20px;
  padding: 28px 24px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.06);
}

.mode-switch {
  display: flex;
  background: #f3f4f6;
  border-radius: 12px;
  padding: 4px;
  margin-bottom: 20px;
}

.mode-tab {
  flex: 1;
  text-align: center;
  padding: 8px 0;
  font-size: 14px;
  font-weight: 600;
  color: #6b7280;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s;
}

.mode-tab.active {
  background: white;
  color: #0d9488;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
}

.form-title {
  font-size: 18px;
  font-weight: 700;
  color: #1f2937;
  margin: 0 0 20px;
  text-align: center;
}

.form-input {
  margin-bottom: 16px;
}

.form-input :deep(.el-input__wrapper) {
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
}

.error-alert {
  margin-bottom: 16px;
}

.login-btn {
  width: 100%;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 600;
  height: 44px;
  background: #0d9488;
  border: none;
}

.login-btn:hover {
  background: #0f766e;
}

.test-account {
  text-align: center;
  margin-top: 12px;
}

.register-link {
  text-align: center;
  margin-top: 12px;
}

.register-link span {
  font-size: 12px;
  color: #0d9488;
  text-decoration: underline;
  cursor: pointer;
}

.register-link span:hover {
  color: #0f766e;
}

.mode-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.mode-title {
  font-size: 18px;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.mode-back {
  font-size: 12px;
  color: #0d9488;
  text-decoration: underline;
  cursor: pointer;
}

.mode-back:hover {
  color: #0f766e;
}

.login-footer {
  margin-top: 32px;
  text-align: center;
}

.login-footer p {
  font-size: 11px;
  color: #9ca3af;
  margin: 0;
}
</style>
