<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { Calendar, Document, SwitchButton, User, Phone, Location, UserFilled } from '@element-plus/icons-vue'
import { getAppointmentList, cancelAppointment } from '@/api/appointment'
import { getReportList, getReportDetail, getReportItemsAll } from '@/api/report'
import { getPatientDetail, updatePatientDetail } from '@/api/patient'
import { useUserStore } from '@/stores/user'
import type { Appointment, Report, AppointmentStatus, Patient, ReportItem } from '@/types'

const userStore = useUserStore()

function handleLogout() {
  userStore.logout()
}

const user = computed(() => ({
  name: userStore.user?.realName || '体检用户',
  phone: maskPhone(userStore.user?.phone),
  avatar: userStore.user?.avatar || 'https://modao.cc/agent-py/media/generated_images/2026-06-03/14abbabc406b43ec8a82b7f7edd276b5.jpg',
  reports: reportsCount.value,
  appointments: appointmentsCount.value,
  points: 128,
}))

// 患者档案
const patientDetail = ref<Patient | null>(null)
const patientLoading = ref(false)
const editDialogVisible = ref(false)
const saving = ref(false)
const editForm = ref<Partial<Patient>>({})

async function loadPatientProfile() {
  if (!userStore.userId) return
  patientLoading.value = true
  try {
    const data = await getPatientDetail(userStore.userId)
    patientDetail.value = data
  } catch (err: any) {
    console.error('加载患者档案失败:', err.message)
  } finally {
    patientLoading.value = false
  }
}

function enterEditMode() {
  if (!patientDetail.value) return
  editForm.value = {
    name: patientDetail.value.name,
    gender: patientDetail.value.gender,
    birthday: patientDetail.value.birthday,
    idCard: patientDetail.value.idCard,
    address: patientDetail.value.address,
    emergencyContact: patientDetail.value.emergencyContact,
    emergencyPhone: patientDetail.value.emergencyPhone,
  }
  editDialogVisible.value = true
}

function cancelEdit() {
  editDialogVisible.value = false
  editForm.value = {}
}

async function saveEdit() {
  if (!userStore.userId) return
  saving.value = true
  try {
    const updated = await updatePatientDetail(userStore.userId, editForm.value)
    patientDetail.value = updated
    editDialogVisible.value = false
    alert('档案更新成功')
  } catch (err: any) {
    alert('更新失败: ' + err.message)
  } finally {
    saving.value = false
  }
}

function genderLabel(gender?: number) {
  if (gender === 0) return '女'
  if (gender === 1) return '男'
  return '—'
}

// 预约列表
const appointments = ref<Appointment[]>([])
const reports = ref<Report[]>([])
const loading = ref(false)

const appointmentsCount = computed(() => appointments.value.length)
const reportsCount = computed(() => reports.value.length)

function maskPhone(phone?: string) {
  if (!phone || phone.length < 7) return '138****5678'
  return phone.slice(0, 3) + '****' + phone.slice(-4)
}

// 加载数据
async function loadAppointments() {
  try {
    const res = await getAppointmentList(1, 20)
    appointments.value = res.records
  } catch (err: any) {
    console.error('加载预约失败:', err.message)
  }
}

async function loadReports() {
  try {
    const res = await getReportList(1, 20)
    reports.value = res.records
  } catch (err: any) {
    console.error('加载报告失败:', err.message)
  }
}

onMounted(() => {
  loadAppointments()
  loadReports()
  loadPatientProfile()
})

const cancelDialogVisible = ref(false)
const cancelTargetId = ref<number | null>(null)
const cancelling = ref(false)

function confirmCancel(id: number) {
  cancelTargetId.value = id
  cancelDialogVisible.value = true
}

async function executeCancel() {
  if (cancelTargetId.value === null) return
  cancelling.value = true
  try {
    await cancelAppointment(cancelTargetId.value)
    await loadAppointments()
  } catch (err: any) {
    alert('取消预约失败: ' + err.message)
  } finally {
    cancelling.value = false
    cancelDialogVisible.value = false
    cancelTargetId.value = null
  }
}

// 报告详情弹窗
const reportDetailVisible = ref(false)
const reportDetail = ref<Report | null>(null)
const reportDetailLoading = ref(false)
const reportItems = ref<ReportItem[]>([])
const reportItemsLoading = ref(false)

async function viewReport(appointmentId: number) {
  // 从已加载的报告列表中匹配
  const matched = reports.value.find(r => r.appointmentId === appointmentId)
  if (!matched) {
    alert('暂无该预约的报告')
    return
  }
  reportDetailLoading.value = true
  reportItemsLoading.value = true
  reportDetailVisible.value = true
  reportItems.value = []
  try {
    reportDetail.value = await getReportDetail(matched.id)
  } catch {
    reportDetail.value = null
  } finally {
    reportDetailLoading.value = false
  }
  try {
    reportItems.value = await getReportItemsAll(matched.id)
  } catch {
    reportItems.value = []
  } finally {
    reportItemsLoading.value = false
  }
}

// 状态映射：后端 0=待确认, 1=已确认, 2=已取消, 3=已完成
function getStatusType(status: AppointmentStatus) {
  switch (status) {
    case 0: return 'warning'   // 待确认
    case 1: return 'success'   // 已确认
    case 2: return 'danger'    // 已取消
    case 3: return 'info'      // 已完成
    default: return 'info'
  }
}

function getStatusLabel(status: AppointmentStatus) {
  switch (status) {
    case 0: return '待确认'
    case 1: return '已确认'
    case 2: return '已取消'
    case 3: return '已完成'
    default: return '未知'
  }
}

function formatDateTime(date: string, timeSlot?: string) {
  if (!timeSlot) return date
  const timeMap: Record<string, string> = {
    'Morning': '08:30',
    'morning': '08:30',
    'Afternoon': '14:00',
    'afternoon': '14:00',
    '上午': '08:30',
    '下午': '14:00',
  }
  const time = timeMap[timeSlot] || '09:00'
  return `${date} ${time}`
}

function addNewAppointment(data: any) {
  // 提交成功后刷新列表
  loadAppointments()
}

defineExpose({ addNewAppointment })
</script>

<template>
  <div class="profile-page">
    <!-- User Info Card -->
    <div class="user-card">
      <div class="user-header">
        <el-avatar :size="64" :src="user.avatar" class="user-avatar" />
        <div class="user-info">
          <h2 class="user-name">{{ user.name }}</h2>
          <p class="user-phone">{{ user.phone }}</p>
        </div>
        <el-icon class="settings-icon" :size="24" @click="handleLogout"><SwitchButton /></el-icon>
      </div>
      <div class="user-stats">
        <div class="stat-item">
          <p class="stat-value">{{ user.reports }}</p>
          <p class="stat-label">我的报告</p>
        </div>
        <div class="stat-item divider">
          <p class="stat-value">{{ user.appointments }}</p>
          <p class="stat-label">我的预约</p>
        </div>
        <div class="stat-item">
          <p class="stat-value">{{ user.points }}</p>
          <p class="stat-label">健康积分</p>
        </div>
      </div>
    </div>

    <!-- Patient Profile -->
    <div class="menu-section">
      <div class="section-header">
        <h3 class="section-title">我的档案</h3>
        <el-button v-if="patientDetail" link type="primary" size="small" @click="enterEditMode">
          编辑
        </el-button>
      </div>
      <div class="menu-group">
        <div v-if="patientLoading" class="menu-loading">
          <el-skeleton :rows="3" animated />
        </div>
        <template v-else-if="patientDetail">
          <div class="menu-item">
            <div class="menu-left">
              <el-icon :size="18" color="#0d9488"><User /></el-icon>
              <span class="menu-label">姓名</span>
            </div>
            <span class="menu-value">{{ patientDetail.name || '—' }}</span>
          </div>
          <div class="menu-item">
            <div class="menu-left">
              <el-icon :size="18" color="#0d9488"><UserFilled /></el-icon>
              <span class="menu-label">性别</span>
            </div>
            <span class="menu-value">{{ genderLabel(patientDetail.gender) }}</span>
          </div>
          <div class="menu-item">
            <div class="menu-left">
              <el-icon :size="18" color="#0d9488"><Calendar /></el-icon>
              <span class="menu-label">出生日期</span>
            </div>
            <span class="menu-value">{{ patientDetail.birthday || '—' }}</span>
          </div>
          <div class="menu-item">
            <div class="menu-left">
              <el-icon :size="18" color="#0d9488"><Document /></el-icon>
              <span class="menu-label">身份证号</span>
            </div>
            <span class="menu-value">{{ patientDetail.idCard || '—' }}</span>
          </div>
          <div class="menu-item">
            <div class="menu-left">
              <el-icon :size="18" color="#0d9488"><Location /></el-icon>
              <span class="menu-label">居住地址</span>
            </div>
            <span class="menu-value">{{ patientDetail.address || '—' }}</span>
          </div>
          <div class="menu-item">
            <div class="menu-left">
              <el-icon :size="18" color="#0d9488"><UserFilled /></el-icon>
              <span class="menu-label">紧急联系人</span>
            </div>
            <span class="menu-value">{{ patientDetail.emergencyContact || '—' }}</span>
          </div>
          <div class="menu-item">
            <div class="menu-left">
              <el-icon :size="18" color="#0d9488"><Phone /></el-icon>
              <span class="menu-label">紧急联系人电话</span>
            </div>
            <span class="menu-value">{{ patientDetail.emergencyPhone || '—' }}</span>
          </div>
        </template>
        <div v-else class="menu-empty">
          未获取到档案信息
        </div>
      </div>
    </div>

    <!-- Appointments -->
    <div class="appointments-section">
      <div class="section-header">
        <h3 class="section-title">我的预约</h3>
      </div>
      <div class="appointment-list">
        <div
          v-for="item in appointments"
          :key="item.id"
          class="appointment-card"
          :class="{ 'opacity-60': item.status === 2 }"
        >
          <div class="appointment-header">
            <div>
              <h4 class="appointment-org">体检预约 #{{ item.id }}</h4>
              <p class="appointment-package">套餐ID: {{ item.packageId }}</p>
            </div>
            <el-tag :type="getStatusType(item.status)" effect="light" size="small">
              {{ getStatusLabel(item.status) }}
            </el-tag>
          </div>
          <div class="appointment-detail">
            <p class="detail-item">
              <el-icon :size="12"><Calendar /></el-icon>
              <span>预约时间：{{ formatDateTime(item.appointmentDate, item.timeSlot) }}</span>
            </p>
            <p class="detail-item">
              <el-icon :size="12"><Document /></el-icon>
              <span>备注：{{ item.remark || '无' }}</span>
            </p>
          </div>
          <div class="appointment-actions">
            <el-button
              size="small"
              type="primary"
              :disabled="item.status !== 3"
              @click="viewReport(item.id)"
            >
              查看报告
            </el-button>
            <el-button
              v-if="item.status === 0 || item.status === 1"
              size="small"
              @click="confirmCancel(item.id)"
            >
              取消预约
            </el-button>
          </div>
        </div>
      </div>
      <p class="no-more">没有更多数据了</p>
    </div>

    <!-- Cancel Dialog -->
    <el-dialog
      v-model="cancelDialogVisible"
      title="取消预约"
      width="80%"
      align-center
      class="cancel-dialog"
    >
      <p class="dialog-text">您确定要取消本次体检预约吗？取消后名额将不再保留。</p>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="cancelDialogVisible = false">再想想</el-button>
          <el-button type="danger" :loading="cancelling" @click="executeCancel">确定取消</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- Report Detail Dialog -->
    <el-dialog
      v-model="reportDetailVisible"
      title="体检报告"
      width="85%"
      align-center
    >
      <div v-if="reportDetailLoading" class="report-loading">
        <span>加载中...</span>
      </div>
      <div v-else-if="reportDetail" class="report-content">
        <p class="report-label">检查摘要</p>
        <p class="report-value">{{ reportDetail.summary || '暂无' }}</p>
        <p class="report-label">总检结论</p>
        <p class="report-value">{{ reportDetail.conclusion || '暂无' }}</p>
        <p class="report-label">生成时间</p>
        <p class="report-value">{{ reportDetail.generateTime || '暂未生成' }}</p>

        <p class="report-label">检查项目明细</p>
        <div v-if="reportItemsLoading" class="report-loading">
          <span>加载检查项...</span>
        </div>
        <div v-else-if="reportItems.length === 0" class="report-value" style="color: #9ca3af;">
          暂无检查项目明细
        </div>
        <div v-else class="report-item-list">
          <div
            v-for="item in reportItems"
            :key="item.id"
            class="report-item"
            :class="{ abnormal: item.abnormalFlag === 1 }"
          >
            <div class="report-item-header">
              <span class="report-item-name">{{ item.examItemName }}</span>
              <el-tag v-if="item.abnormalFlag === 1" type="danger" size="small">异常</el-tag>
              <el-tag v-else type="success" size="small">正常</el-tag>
            </div>
            <div class="report-item-body">
              <span class="report-item-result">结果：{{ item.result || '—' }}</span>
              <span class="report-item-ref">参考范围：{{ item.referenceRange || '—' }}</span>
            </div>
          </div>
        </div>
      </div>
      <div v-else class="report-loading">
        <p>加载失败</p>
      </div>
    </el-dialog>

    <!-- Edit Profile Dialog -->
    <el-dialog
      v-model="editDialogVisible"
      title="编辑档案"
      width="85%"
      align-center
    >
      <el-form label-position="top" size="default">
        <el-form-item label="姓名">
          <el-input v-model="editForm.name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="性别">
          <el-radio-group v-model="editForm.gender">
            <el-radio :label="1">男</el-radio>
            <el-radio :label="0">女</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="出生日期">
          <el-date-picker
            v-model="editForm.birthday"
            type="date"
            placeholder="选择日期"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="身份证号">
          <el-input v-model="editForm.idCard" placeholder="请输入身份证号" />
        </el-form-item>
        <el-form-item label="居住地址">
          <el-input v-model="editForm.address" placeholder="请输入居住地址" />
        </el-form-item>
        <el-form-item label="紧急联系人">
          <el-input v-model="editForm.emergencyContact" placeholder="请输入紧急联系人姓名" />
        </el-form-item>
        <el-form-item label="紧急联系人电话">
          <el-input v-model="editForm.emergencyPhone" placeholder="请输入紧急联系人电话" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="cancelEdit">取消</el-button>
          <el-button type="primary" :loading="saving" @click="saveEdit">保存</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.profile-page {
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

.user-phone {
  font-size: 12px;
  color: #9ca3af;
  margin: 4px 0 0;
}

.settings-icon {
  color: #d1d5db;
  cursor: pointer;
}

.user-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  margin-top: 20px;
}

.stat-item {
  text-align: center;
}

.stat-item.divider {
  border-left: 1px solid #f3f4f6;
  border-right: 1px solid #f3f4f6;
}

.stat-value {
  font-size: 16px;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.stat-label {
  font-size: 11px;
  color: #9ca3af;
  margin: 4px 0 0;
}

.appointments-section {
  margin-top: 24px;
  padding: 0 20px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.section-title {
  font-size: 16px;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.appointment-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.appointment-card {
  background: white;
  padding: 16px;
  border-radius: 16px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
  border: 1px solid #f3f4f6;
}

.appointment-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
}

.appointment-org {
  font-size: 14px;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.appointment-package {
  font-size: 11px;
  color: #9ca3af;
  margin: 4px 0 0;
}

.appointment-detail {
  border-top: 1px solid #f9fafb;
  padding-top: 12px;
  margin-bottom: 12px;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 11px;
  color: #6b7280;
  margin: 6px 0;
}

.appointment-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}

.opacity-60 {
  opacity: 0.6;
}

.no-more {
  text-align: center;
  font-size: 11px;
  color: #d1d5db;
  margin-top: 24px;
}

.dialog-text {
  text-align: center;
  color: #6b7280;
  font-size: 14px;
}

.dialog-footer {
  display: flex;
  gap: 12px;
}

.dialog-footer .el-button {
  flex: 1;
}

/* 报告详情弹窗 */
.report-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 32px 0;
  color: #9ca3af;
  font-size: 14px;
}

.report-content {
  padding: 4px 0;
}

.report-label {
  font-size: 12px;
  color: #9ca3af;
  margin: 12px 0 4px;
}

.report-label:first-child {
  margin-top: 0;
}

.report-value {
  font-size: 14px;
  color: #1f2937;
  margin: 0;
  line-height: 1.6;
}

.report-item-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: 8px;
}

.report-item {
  background: #f9fafb;
  border-radius: 10px;
  padding: 12px;
  border: 1px solid #f3f4f6;
}

.report-item.abnormal {
  background: #fef2f2;
  border-color: #fecaca;
}

.report-item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
}

.report-item-name {
  font-size: 14px;
  font-weight: 600;
  color: #1f2937;
}

.report-item-body {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.report-item-result,
.report-item-ref {
  font-size: 12px;
  color: #6b7280;
}

/* 患者档案 */
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
  padding: 14px 16px;
  border-bottom: 1px solid #f9fafb;
}

.menu-item:last-child {
  border-bottom: none;
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
  color: #6b7280;
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
</style>
