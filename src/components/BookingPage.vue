<script setup lang="ts">
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { Check, Clock, ArrowLeft, ArrowRight, Document, OfficeBuilding, FirstAidKit } from '@element-plus/icons-vue'
import { getInstitutionsByAppointmentType } from '@/api/institution'
import { getPackagesByInstitution, getPackageDetail } from '@/api/package'
import { getDictItemsByType } from '@/api/dict'
import { createAppointment } from '@/api/appointment'
import { useUserStore } from '@/stores/user'
import type { Institution, ExamPackage, ExamItem, DictItem } from '@/types'

const userStore = useUserStore()
const currentStep = ref(1)
const submitting = ref(false)
const loading = ref(false)
const typesLoaded = ref(false)

const bookingData = reactive({
  appointmentType: '' as string,
  appointmentTypeLabel: '',
  institutionId: null as number | null,
  institutionName: '',
  packageId: null as number | null,
  packageName: '',
  date: '',
  timeSlot: '上午',
  price: 0,
  remark: '',
})

// 从接口加载的数据
const appointmentTypes = ref<DictItem[]>([])
const institutions = ref<Institution[]>([])
const packages = ref<ExamPackage[]>([])
const packageDetail = ref<(ExamPackage & { items?: ExamItem[] }) | null>(null)

const calendarDays = ref<{ day: string; type: 'disabled' | 'normal' | 'selected'; date: string }[]>([])
const currentMonthText = ref('')

function initCalendar() {
  const now = new Date()
  const year = now.getFullYear()
  const month = now.getMonth()
  const daysInMonth = new Date(year, month + 1, 0).getDate()
  const firstDayOfWeek = new Date(year, month, 1).getDay()

  currentMonthText.value = `${year}年${month + 1}月`

  // 今天的日期字符串，今天及之前的日期不可选
  const todayStr = `${year}-${String(month + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`

  const days: typeof calendarDays.value = []
  for (let i = 0; i < firstDayOfWeek; i++) {
    days.push({ day: '', type: 'disabled', date: '' })
  }
  for (let d = 1; d <= daysInMonth; d++) {
    const dateStr = `${year}-${String(month + 1).padStart(2, '0')}-${String(d).padStart(2, '0')}`
    // 今天及之前的日期不可选
    const type = dateStr <= todayStr ? 'disabled' : 'normal'
    days.push({ day: String(d), type, date: dateStr })
  }
  const remaining = (7 - (days.length % 7)) % 7
  for (let i = 0; i < remaining; i++) {
    days.push({ day: '', type: 'disabled', date: '' })
  }
  calendarDays.value = days
}

const stepLabels = ['分类', '机构', '套餐', '日期', '完成']

const emit = defineEmits<{
  submit: [data: typeof bookingData]
}>()

// 加载预约类型字典
async function loadAppointmentTypes() {
  if (typesLoaded.value) return
  loading.value = true
  try {
    const res = await getDictItemsByType(4)
    // 按 id 去重，防止后端返回重复数据
    const uniqueMap = new Map<number, DictItem>()
    for (const item of res.records) {
      uniqueMap.set(item.id, item)
    }
    appointmentTypes.value = Array.from(uniqueMap.values())
    if (appointmentTypes.value.length > 0 && !bookingData.appointmentType) {
      const first = appointmentTypes.value[0]
      bookingData.appointmentType = first.value
      bookingData.appointmentTypeLabel = first.label
    }
    typesLoaded.value = true
  } catch (err: any) {
    console.error('加载预约类型失败:', err.message)
  } finally {
    loading.value = false
  }
}

// 根据预约类型加载机构
async function loadInstitutions() {
  if (!bookingData.appointmentType) return
  loading.value = true
  try {
    institutions.value = await getInstitutionsByAppointmentType(bookingData.appointmentType)
  } catch (err: any) {
    console.error('加载机构失败:', err.message)
    institutions.value = []
  } finally {
    loading.value = false
  }
}

// 根据机构加载套餐
async function loadPackages() {
  if (!bookingData.institutionId) return
  loading.value = true
  try {
    packages.value = await getPackagesByInstitution(bookingData.institutionId)
  } catch (err: any) {
    console.error('加载套餐失败:', err.message)
    packages.value = []
  } finally {
    loading.value = false
  }
}

// 加载套餐详情（含检查项目）
async function loadPackageDetail(id: number) {
  try {
    packageDetail.value = await getPackageDetail(id)
  } catch (err: any) {
    console.error('加载套餐详情失败:', err.message)
    packageDetail.value = null
  }
}

// 监听步骤变化，动态加载数据
watch(currentStep, (step) => {
  if (step === 1) {
    if (!typesLoaded.value) loadAppointmentTypes()
  }
  if (step === 2) {
    if (bookingData.appointmentType) loadInstitutions()
  }
  if (step === 3) {
    if (bookingData.institutionId) loadPackages()
  }
})

// 是否允许进入下一步（当前步骤必须已选择）
const canNext = computed(() => {
  switch (currentStep.value) {
    case 1: return !!bookingData.appointmentType
    case 2: return !!bookingData.institutionId
    case 3: return !!bookingData.packageId
    case 4: return !!bookingData.date
    default: return true
  }
})

function nextStep() {
  if (currentStep.value < 5 && canNext.value) {
    currentStep.value++
  }
}

// 重置预约表单，回到第一步
function resetBooking() {
  currentStep.value = 1
  bookingData.appointmentType = ''
  bookingData.appointmentTypeLabel = ''
  bookingData.institutionId = null
  bookingData.institutionName = ''
  bookingData.packageId = null
  bookingData.packageName = ''
  bookingData.date = ''
  bookingData.timeSlot = '上午'
  bookingData.price = 0
  bookingData.remark = ''
  institutions.value = []
  packages.value = []
  packageDetail.value = null
}

function prevStep() {
  if (currentStep.value > 1) {
    currentStep.value--
  }
}

function selectAppointmentType(type: DictItem) {
  bookingData.appointmentType = type.value
  bookingData.appointmentTypeLabel = type.label
  institutions.value = []
  packages.value = []
  packageDetail.value = null
  bookingData.institutionId = null
  bookingData.institutionName = ''
  bookingData.packageId = null
  bookingData.packageName = ''
  bookingData.price = 0
}

function selectInstitution(inst: Institution) {
  bookingData.institutionId = inst.id
  bookingData.institutionName = inst.name
  packages.value = []
  packageDetail.value = null
  bookingData.packageId = null
  bookingData.packageName = ''
  bookingData.price = 0
}

function selectPackage(pkg: ExamPackage) {
  bookingData.packageId = pkg.id
  bookingData.packageName = pkg.name
  bookingData.price = pkg.price
  loadPackageDetail(pkg.id)
}

function selectDate(date: string) {
  bookingData.date = date
}

function selectTimeSlot(slot: string) {
  bookingData.timeSlot = slot
}

async function submitBooking() {
  if (!bookingData.packageId || !bookingData.date) {
    alert('预约信息不完整')
    return
  }
  submitting.value = true
  try {
    await createAppointment({
      packageId: bookingData.packageId,
      institutionId: bookingData.institutionId || undefined,
      appointmentDate: bookingData.date,
      timeSlot: bookingData.timeSlot,
      remark: bookingData.remark || undefined,
    })
    emit('submit', { ...bookingData })
    resetBooking()
  } catch (err: any) {
    alert('预约提交失败: ' + err.message)
  } finally {
    submitting.value = false
  }
}

function getStepIconClass(step: number) {
  if (step < currentStep.value) return 'step-completed'
  if (step === currentStep.value) return 'step-current'
  return 'step-pending'
}

const summaryPackageName = computed(() => bookingData.packageName)
const summaryPrice = computed(() => `¥${bookingData.price}`)
const selectedDateText = computed(() => bookingData.date.replace(/-/g, '/'))

onMounted(() => {
  loadAppointmentTypes()
  initCalendar()
})

function formatPrice(price: number) {
  return `¥${price}`
}
</script>

<template>
  <div class="booking-page">
    <h1 class="page-title">预约下单</h1>

    <!-- Step Indicator -->
    <div class="step-indicator">
      <div class="step-line-bg">
        <div class="step-line-progress" :style="{ width: ((currentStep - 1) * 25) + '%' }"></div>
      </div>
      <div class="steps">
        <div v-for="i in 5" :key="i" class="step-item">
          <div class="step-icon" :class="getStepIconClass(i)">
            <el-icon v-if="i < currentStep" :size="14"><Check /></el-icon>
            <span v-else>{{ i }}</span>
          </div>
          <span class="step-label" :class="{ 'step-label-active': i <= currentStep }">{{ stepLabels[i - 1] }}</span>
        </div>
      </div>
    </div>

    <!-- Step Content -->
    <div class="step-content">
      <!-- Step 1: 预约类型 -->
      <div v-if="currentStep === 1" class="step-panel">
        <h4 class="step-title">请选择预约类型</h4>
        <div v-if="loading" class="flow-loading">
          <el-icon class="is-loading"><Clock /></el-icon>
          <span>加载中...</span>
        </div>
        <div v-else class="category-grid">
          <div
            v-for="type in appointmentTypes"
            :key="type.id"
            class="selection-card"
            :class="{ selected: bookingData.appointmentType === type.value }"
            @click="selectAppointmentType(type)"
          >
            <el-icon :size="36" color="#0d9488">
              <component :is="type.value === 'individual' ? Document : type.value === 'group' ? OfficeBuilding : type.value === 'travel' ? FirstAidKit : Document" />
            </el-icon>
            <p class="selection-label">{{ type.label }}</p>
          </div>
        </div>
      </div>

      <!-- Step 2: Institution -->
      <div v-if="currentStep === 2" class="step-panel">
        <h4 class="step-title">请选择体检机构</h4>
        <div v-if="loading" class="flow-loading">
          <el-icon class="is-loading"><Clock /></el-icon>
          <span>加载中...</span>
        </div>
        <div v-else-if="institutions.length === 0" class="empty-state">
          <p>暂无可用机构</p>
        </div>
        <div v-else class="institution-list">
          <div
            v-for="inst in institutions"
            :key="inst.id"
            class="selection-card institution-row"
            :class="{ selected: bookingData.institutionId === inst.id }"
            @click="selectInstitution(inst)"
          >
            <div class="institution-thumb">
              <img :src="'https://modao.cc/agent-py/media/generated_images/2026-06-03/1692b7800da547adb0d7f9550a38fcb1.jpg'" :alt="inst.name" />
            </div>
            <div class="institution-info">
              <p class="institution-name">{{ inst.name }}</p>
              <p class="institution-address">{{ inst.address }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Step 3: Package -->
      <div v-if="currentStep === 3" class="step-panel">
        <h4 class="step-title">请选择体检套餐</h4>
        <div v-if="loading" class="flow-loading">
          <el-icon class="is-loading"><Clock /></el-icon>
          <span>加载中...</span>
        </div>
        <div v-else-if="packages.length === 0" class="empty-state">
          <p>暂无可用套餐</p>
        </div>
        <div v-else class="package-list">
          <div
            v-for="pkg in packages"
            :key="pkg.id"
            class="selection-card package-row"
            :class="{ selected: bookingData.packageId === pkg.id }"
            @click="selectPackage(pkg)"
          >
            <div class="package-header">
              <span class="package-name">{{ pkg.name }}</span>
              <span class="package-price">{{ formatPrice(pkg.price) }}</span>
            </div>
            <p class="package-desc">{{ pkg.description || '' }}</p>
            <p class="package-time">
              <el-icon :size="12"><Clock /></el-icon>
              <span>预计时长: 2小时</span>
            </p>
          </div>
        </div>
      </div>

      <!-- Step 4: Date -->
      <div v-if="currentStep === 4" class="step-panel">
        <h4 class="step-title">请选择预约日期</h4>
        <div class="calendar-card">
          <div class="calendar-header">
            <span class="calendar-month">{{ currentMonthText }}</span>
            <div class="calendar-nav">
              <el-icon><ArrowLeft /></el-icon>
              <el-icon><ArrowRight /></el-icon>
            </div>
          </div>
          <div class="calendar-weekdays">
            <span v-for="d in ['日','一','二','三','四','五','六']" :key="d">{{ d }}</span>
          </div>
          <div class="calendar-days">
            <span
              v-for="(day, idx) in calendarDays"
              :key="day.date || `empty-${idx}`"
              class="calendar-day"
              :class="{
                'day-disabled': day.type === 'disabled',
                'day-selected': day.date === bookingData.date,
                'day-normal': day.type === 'normal',
              }"
              @click="day.type !== 'disabled' && day.date && selectDate(day.date)"
            >
              {{ day.day }}
            </span>
          </div>
        </div>
        <div class="time-slot-section" style="margin-top: 16px;">
          <h4 class="step-title">选择时间段</h4>
          <div style="display: flex; gap: 12px;">
            <div
              class="selection-card"
              :class="{ selected: bookingData.timeSlot === '上午' }"
              @click="selectTimeSlot('上午')"
              style="flex: 1; text-align: center;"
            >上午</div>
            <div
              class="selection-card"
              :class="{ selected: bookingData.timeSlot === '下午' }"
              @click="selectTimeSlot('下午')"
              style="flex: 1; text-align: center;"
            >下午</div>
          </div>
        </div>
        <div class="selected-date-info">
          <p class="selected-date-text">已选择: <strong>{{ selectedDateText }} {{ bookingData.timeSlot }}</strong></p>
          <p class="selected-date-note">当日可预约名额剩余: 12人</p>
        </div>
      </div>

      <!-- Step 5: Summary -->
      <div v-if="currentStep === 5" class="step-panel">
        <h4 class="step-title">订单确认</h4>
        <div class="summary-card">
          <div class="summary-row">
            <span class="summary-label">预约类型</span>
            <span class="summary-value">{{ bookingData.appointmentTypeLabel || '未选择' }}</span>
          </div>
          <div class="summary-row">
            <span class="summary-label">体检机构</span>
            <span class="summary-value">{{ bookingData.institutionName || '未选择' }}</span>
          </div>
          <div class="summary-row">
            <span class="summary-label">体检套餐</span>
            <span class="summary-value">{{ summaryPackageName || '未选择' }}</span>
          </div>
          <div class="summary-row">
            <span class="summary-label">预约日期</span>
            <span class="summary-value">{{ bookingData.date }} {{ bookingData.timeSlot }}</span>
          </div>
          <div v-if="packageDetail?.items && packageDetail.items.length > 0" class="summary-row" style="flex-direction: column; align-items: flex-start; gap: 8px;">
            <span class="summary-label">检查项目</span>
            <div class="item-tags">
              <el-tag v-for="item in packageDetail.items" :key="item.id" size="small" type="info">{{ item.name }}</el-tag>
            </div>
          </div>
          <div class="summary-total">
            <span>总计金额</span>
            <span class="total-price">{{ summaryPrice }}</span>
          </div>
        </div>
        <div class="agreement">
          <el-checkbox>我已阅读并同意《体检预约服务协议》及《隐私政策》，确认身体状况符合体检要求。</el-checkbox>
        </div>
      </div>
    </div>

    <!-- Navigation Buttons -->
    <div class="nav-buttons">
      <el-button v-if="currentStep > 1" class="nav-btn" @click="prevStep">上一步</el-button>
      <el-button
        v-if="currentStep < 5"
        type="primary"
        class="nav-btn nav-btn-primary"
        :disabled="!canNext"
        @click="nextStep"
      >
        下一步
      </el-button>
      <el-button
        v-else
        type="primary"
        class="nav-btn nav-btn-primary"
        :loading="submitting"
        @click="submitBooking"
      >
        提交预约
      </el-button>
    </div>
  </div>
</template>

<style scoped>
.booking-page {
  padding: 16px 20px 20px;
}

.page-title {
  font-size: 20px;
  font-weight: 700;
  color: #1f2937;
  text-align: center;
  margin: 0 0 20px;
}

.step-indicator {
  position: relative;
  margin-bottom: 24px;
}

.step-line-bg {
  position: absolute;
  top: 16px;
  left: 10%;
  right: 10%;
  height: 2px;
  background: #e5e7eb;
  z-index: 0;
}

.step-line-progress {
  height: 100%;
  background: #0d9488;
  transition: width 0.3s ease;
}

.steps {
  display: flex;
  justify-content: space-between;
  position: relative;
  z-index: 1;
}

.step-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
}

.step-icon {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 700;
  transition: all 0.3s;
}

.step-completed {
  background: #0d9488;
  color: white;
}

.step-current {
  background: #0d9488;
  color: white;
  box-shadow: 0 0 0 4px #ccfbf1;
}

.step-pending {
  background: #e5e7eb;
  color: #6b7280;
}

.step-label {
  font-size: 10px;
  color: #9ca3af;
}

.step-label-active {
  color: #0d9488;
  font-weight: 600;
}

.step-content {
  min-height: 400px;
}

.step-panel {
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.step-title {
  font-size: 15px;
  font-weight: 700;
  color: #374151;
  margin: 0 0 16px;
}

.category-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.selection-card {
  background: white;
  border-radius: 12px;
  padding: 16px;
  border: 2px solid transparent;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
  cursor: pointer;
  transition: all 0.2s;
}

.selection-card.selected {
  border-color: #0d9488;
  background: #f0fdfa;
}

.selection-label {
  font-size: 14px;
  font-weight: 600;
  color: #374151;
  margin: 8px 0 0;
  text-align: center;
}

.institution-list,
.package-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.institution-row {
  display: flex;
  align-items: center;
  gap: 12px;
}

.institution-thumb {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  overflow: hidden;
  background: #f3f4f6;
  flex-shrink: 0;
}

.institution-thumb img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.institution-name {
  font-size: 14px;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.institution-address {
  font-size: 11px;
  color: #9ca3af;
  margin: 4px 0 0;
}

.package-row {
  padding: 16px;
}

.package-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.package-name {
  font-size: 14px;
  font-weight: 700;
  color: #1f2937;
}

.package-price {
  font-size: 14px;
  font-weight: 700;
  color: #0d9488;
}

.package-desc {
  font-size: 11px;
  color: #6b7280;
  margin: 8px 0 0;
}

.package-time {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 11px;
  color: #9ca3af;
  margin: 8px 0 0;
}

.calendar-card {
  background: white;
  border-radius: 16px;
  padding: 16px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}

.calendar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.calendar-month {
  font-size: 14px;
  font-weight: 700;
  color: #1f2937;
}

.calendar-nav {
  display: flex;
  gap: 8px;
  color: #9ca3af;
}

.calendar-weekdays {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  text-align: center;
  font-size: 10px;
  color: #9ca3af;
  margin-bottom: 8px;
}

.calendar-days {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  text-align: center;
  gap: 4px;
}

.calendar-day {
  padding: 8px 0;
  border-radius: 8px;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s;
}

.day-disabled {
  color: #e5e7eb;
  cursor: default;
}

.day-normal {
  color: #374151;
}

.day-normal:hover {
  background: #f3f4f6;
}

.day-selected {
  color: #0d9488;
  font-weight: 700;
  background: #f0fdfa;
}

.selected-date-info {
  margin-top: 16px;
  padding: 16px;
  background: #f0fdfa;
  border-radius: 12px;
}

.selected-date-text {
  font-size: 12px;
  color: #0f766e;
  margin: 0;
}

.selected-date-note {
  font-size: 10px;
  color: #5eead4;
  margin: 4px 0 0;
}

.summary-card {
  background: white;
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
  border: 1px solid #f3f4f6;
}

.summary-row {
  display: flex;
  justify-content: space-between;
  padding: 12px 0;
  border-bottom: 1px solid #f9fafb;
}

.summary-label {
  font-size: 12px;
  color: #9ca3af;
}

.summary-value {
  font-size: 12px;
  color: #1f2937;
  font-weight: 600;
}

.summary-total {
  display: flex;
  justify-content: space-between;
  padding-top: 16px;
  font-weight: 700;
  color: #1f2937;
}

.total-price {
  color: #0d9488;
  font-size: 20px;
}

.agreement {
  margin-top: 16px;
}

.agreement :deep(.el-checkbox__label) {
  font-size: 11px;
  color: #9ca3af;
}

.nav-buttons {
  display: flex;
  gap: 12px;
  margin-top: 24px;
}

.nav-btn {
  flex: 1;
  border-radius: 12px;
  height: 44px;
  font-weight: 600;
}

.item-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.flow-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 0;
  color: #9ca3af;
  gap: 8px;
}

.empty-state {
  text-align: center;
  padding: 40px 0;
  color: #9ca3af;
  font-size: 14px;
}

.nav-btn-primary {
  background: #0d9488;
  border-color: #0d9488;
}
</style>
