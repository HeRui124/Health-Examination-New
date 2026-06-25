<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { Calendar, Document, FirstAidKit, Clock, User } from '@element-plus/icons-vue'
import { getAppointmentList, completeAppointment } from '@/api/appointment'
import { getReportList, generateReport, batchCreateReportItems } from '@/api/report'
import { getPackageDetail } from '@/api/package'
import { getPatientDetail } from '@/api/patient'
import type { ExamItem, Patient } from '@/types'
import { useUserStore } from '@/stores/user'
import type { Appointment, Report } from '@/types'

const userStore = useUserStore()

const appointments = ref<Appointment[]>([])
const reports = ref<Report[]>([])
const loading = ref(false)
const page = ref(1)
const size = ref(10)
const total = ref(0)

// 报告生成弹窗
const generateDialogVisible = ref(false)
const generateLoading = ref(false)
const packageLoading = ref(false)
const currentAppointment = ref<Appointment | null>(null)
const examItems = ref<ExamItem[]>([])
const reportItemInputs = ref<{ examItemId: number; examItemName: string; result: string; referenceRange: string; abnormalFlag: number }[]>([])
const reportForm = ref({
  summary: '',
  conclusion: '',
})

// 预约详情弹窗
const detailVisible = ref(false)
const detailLoading = ref(false)
const appointmentDetail = ref<Appointment | null>(null)
const patientDetail = ref<Patient | null>(null)
const patientLoading = ref(false)

async function loadAppointments() {
  loading.value = true
  try {
    const res = await getAppointmentList(page.value, size.value)
    appointments.value = res.records
    total.value = res.total
  } catch (err: any) {
    console.error('加载预约失败:', err.message)
  } finally {
    loading.value = false
  }
}

async function loadReports() {
  try {
    const res = await getReportList(1, 100)
    reports.value = res.records
  } catch (err: any) {
    console.error('加载报告失败:', err.message)
  }
}

// 判断某个预约是否已有报告
function hasReport(appointmentId: number) {
  return reports.value.some(r => r.appointmentId === appointmentId)
}

const completing = ref<number | null>(null)

async function handleComplete(appointment: Appointment) {
  completing.value = appointment.id
  try {
    await completeAppointment(appointment.id)
    await loadAppointments()
  } catch (err: any) {
    alert('标记完成失败: ' + err.message)
  } finally {
    completing.value = null
  }
}

function getReportByAppointment(appointmentId: number): Report | undefined {
  return reports.value.find(r => r.appointmentId === appointmentId)
}

async function openGenerateDialog(appointment: Appointment) {
  currentAppointment.value = appointment
  reportForm.value = { summary: '', conclusion: '' }
  examItems.value = []
  reportItemInputs.value = []
  generateDialogVisible.value = true

  if (appointment.packageId) {
    packageLoading.value = true
    try {
      const pkg = await getPackageDetail(appointment.packageId)
      examItems.value = pkg.items || []
      reportItemInputs.value = examItems.value.map(item => ({
        examItemId: item.id,
        examItemName: item.name,
        result: '',
        referenceRange: '',
        abnormalFlag: 0,
      }))
    } catch (err: any) {
      console.error('加载套餐检查项失败:', err.message)
    } finally {
      packageLoading.value = false
    }
  }
}

async function submitGenerateReport() {
  if (!currentAppointment.value) return
  if (!reportForm.value.summary.trim() || !reportForm.value.conclusion.trim()) {
    alert('请填写检查摘要和总检结论')
    return
  }

  // 校验检查项目结果
  const filledItems = reportItemInputs.value.filter(item => item.result.trim() !== '')
  if (examItems.value.length > 0 && filledItems.length === 0) {
    alert('请至少录入一项检查结果')
    return
  }

  generateLoading.value = true
  try {
    // 1. 生成报告
    const report = await generateReport({
      userId: currentAppointment.value.userId,
      appointmentId: currentAppointment.value.id,
      summary: reportForm.value.summary,
      conclusion: reportForm.value.conclusion,
    })

    // 2. 批量录入检查项目明细
    if (report && report.id && filledItems.length > 0) {
      await batchCreateReportItems(
        report.id,
        filledItems.map(item => ({
          examItemId: item.examItemId,
          examItemName: item.examItemName,
          result: item.result,
          referenceRange: item.referenceRange || undefined,
          abnormalFlag: item.abnormalFlag,
        }))
      )
    }

    generateDialogVisible.value = false
    await loadReports()
  } catch (err: any) {
    alert('生成报告失败: ' + err.message)
  } finally {
    generateLoading.value = false
  }
}

async function openDetail(appointment: Appointment) {
  appointmentDetail.value = appointment
  patientDetail.value = null
  detailVisible.value = true

  // 加载患者档案
  patientLoading.value = true
  try {
    const patient = await getPatientDetail(appointment.userId)
    patientDetail.value = patient
  } catch (err: any) {
    console.error('加载患者档案失败:', err.message)
  } finally {
    patientLoading.value = false
  }
}

function getStatusType(status: number) {
  switch (status) {
    case 0: return 'warning'
    case 1: return 'success'
    case 2: return 'danger'
    case 3: return 'info'
    default: return 'info'
  }
}

function getStatusLabel(status: number) {
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

const todayCount = computed(() => {
  const today = new Date().toISOString().slice(0, 10)
  return appointments.value.filter(a => a.appointmentDate === today).length
})

const pendingCount = computed(() => appointments.value.filter(a => a.status === 1).length)

const completedCount = computed(() => appointments.value.filter(a => a.status === 3).length)

onMounted(() => {
  loadAppointments()
  loadReports()
})
</script>

<template>
  <div class="doctor-home-page">
    <!-- Header -->
    <div class="header">
      <h1 class="title">预约管理</h1>
      <div class="header-actions">
        <el-button circle size="small" @click="loadAppointments">
          <el-icon><Clock /></el-icon>
        </el-button>
      </div>
    </div>

    <!-- Stats Card -->
    <div class="stats-card">
      <div class="stat-item">
        <p class="stat-value">{{ todayCount }}</p>
        <p class="stat-label">今日预约</p>
      </div>
      <div class="stat-item divider">
        <p class="stat-value">{{ pendingCount }}</p>
        <p class="stat-label">待体检</p>
      </div>
      <div class="stat-item">
        <p class="stat-value">{{ completedCount }}</p>
        <p class="stat-label">已完成</p>
      </div>
    </div>

    <!-- Appointment List -->
    <div class="appointments-section">
      <div class="section-header">
        <h3 class="section-title">我的预约</h3>
        <span class="section-sub">共 {{ total }} 条</span>
      </div>

      <div v-if="loading" class="loading-state">
        <el-icon class="is-loading" :size="24"><Clock /></el-icon>
        <span>加载中...</span>
      </div>

      <div v-else-if="appointments.length === 0" class="empty-state">
        <el-icon :size="48" color="#d1d5db"><FirstAidKit /></el-icon>
        <p>暂无预约数据</p>
      </div>

      <div v-else class="appointment-list">
        <div
          v-for="item in appointments"
          :key="item.id"
          class="appointment-card"
        >
          <div class="appointment-header">
            <div class="appointment-id">预约 #{{ item.id }}</div>
            <el-tag :type="getStatusType(item.status)" effect="light" size="small">
              {{ getStatusLabel(item.status) }}
            </el-tag>
          </div>

          <div class="appointment-info">
            <div class="info-row">
              <el-icon :size="14" color="#9ca3af"><User /></el-icon>
              <span>患者ID: {{ item.userId }}</span>
            </div>
            <div class="info-row">
              <el-icon :size="14" color="#9ca3af"><Calendar /></el-icon>
              <span>{{ formatDateTime(item.appointmentDate, item.timeSlot) }}</span>
            </div>
            <div class="info-row">
              <el-icon :size="14" color="#9ca3af"><Document /></el-icon>
              <span>套餐ID: {{ item.packageId }}</span>
            </div>
            <div v-if="item.remark" class="info-row remark">
              <span>备注: {{ item.remark }}</span>
            </div>
          </div>

          <div class="appointment-actions">
            <el-button size="small" @click="openDetail(item)">查看详情</el-button>
            <el-button
              v-if="item.status === 1"
              size="small"
              type="warning"
              :loading="completing === item.id"
              @click="handleComplete(item)"
            >
              标记完成
            </el-button>
            <el-button
              v-else-if="item.status === 3 && !hasReport(item.id)"
              size="small"
              type="primary"
              @click="openGenerateDialog(item)"
            >
              生成报告
            </el-button>
            <el-button
              v-else-if="hasReport(item.id)"
              size="small"
              type="success"
              disabled
            >
              已有报告
            </el-button>
          </div>
        </div>
      </div>
    </div>

    <!-- 预约详情弹窗 -->
    <el-dialog v-model="detailVisible" title="预约详情" width="85%" align-center>
      <div v-if="appointmentDetail" class="detail-content">
        <!-- 患者档案 -->
        <div class="detail-section">
          <h4 class="detail-section-title">患者档案</h4>

          <div v-if="patientLoading" class="patient-loading">
            <el-icon class="is-loading" :size="18"><Clock /></el-icon>
            <span>加载患者档案...</span>
          </div>

          <div v-else-if="patientDetail" class="patient-info">
            <div class="detail-row">
              <span class="detail-label">姓名</span>
              <span class="detail-value">{{ patientDetail.name }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">性别</span>
              <span class="detail-value">{{ patientDetail.gender === 1 ? '男' : patientDetail.gender === 0 ? '女' : '未知' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">出生日期</span>
              <span class="detail-value">{{ patientDetail.birthday || '-' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">身份证号</span>
              <span class="detail-value">{{ patientDetail.idCard || '-' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">地址</span>
              <span class="detail-value">{{ patientDetail.address || '-' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">紧急联系人</span>
              <span class="detail-value">{{ patientDetail.emergencyContact || '-' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">紧急电话</span>
              <span class="detail-value">{{ patientDetail.emergencyPhone || '-' }}</span>
            </div>
          </div>

          <div v-else class="patient-empty">
            <span>未获取到患者档案</span>
          </div>
        </div>

        <!-- 预约信息 -->
        <div class="detail-section">
          <h4 class="detail-section-title">预约信息</h4>
          <div class="detail-row">
            <span class="detail-label">预约编号</span>
            <span class="detail-value">#{{ appointmentDetail.id }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">患者ID</span>
            <span class="detail-value">{{ appointmentDetail.userId }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">预约时间</span>
            <span class="detail-value">{{ formatDateTime(appointmentDetail.appointmentDate, appointmentDetail.timeSlot) }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">套餐ID</span>
            <span class="detail-value">{{ appointmentDetail.packageId }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">机构ID</span>
            <span class="detail-value">{{ appointmentDetail.institutionId || '-' }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">状态</span>
            <el-tag :type="getStatusType(appointmentDetail.status)" size="small">
              {{ getStatusLabel(appointmentDetail.status) }}
            </el-tag>
          </div>
          <div class="detail-row">
            <span class="detail-label">备注</span>
            <span class="detail-value">{{ appointmentDetail.remark || '无' }}</span>
          </div>
        </div>
      </div>
    </el-dialog>

    <!-- 生成报告弹窗 -->
    <el-dialog v-model="generateDialogVisible" title="生成体检报告" width="85%" align-center>
      <div class="generate-form">
        <div class="form-item">
          <label>检查摘要</label>
          <el-input
            v-model="reportForm.summary"
            type="textarea"
            :rows="3"
            placeholder="请输入检查摘要，如各项检查结果概述"
          />
        </div>
        <div class="form-item">
          <label>总检结论</label>
          <el-input
            v-model="reportForm.conclusion"
            type="textarea"
            :rows="3"
            placeholder="请输入总检结论和建议"
          />
        </div>

        <!-- 检查项目明细 -->
        <div class="form-item">
          <div class="items-header">
            <label>检查项目明细</label>
            <span v-if="examItems.length > 0" class="items-count">共 {{ examItems.length }} 项</span>
          </div>

          <div v-if="packageLoading" class="items-loading">
            <el-icon class="is-loading" :size="18"><Clock /></el-icon>
            <span>加载检查项目...</span>
          </div>

          <div v-else-if="examItems.length === 0" class="items-empty">
            <span>未获取到检查项目</span>
          </div>

          <div v-else class="items-list">
            <div
              v-for="(item, index) in reportItemInputs"
              :key="item.examItemId"
              class="item-input-card"
              :class="{ abnormal: item.abnormalFlag === 1 }"
            >
              <div class="item-input-header">
                <span class="item-input-name">{{ item.examItemName }}</span>
                <el-switch
                  v-model="item.abnormalFlag"
                  :active-value="1"
                  :inactive-value="0"
                  size="small"
                  inline-prompt
                  active-text="异常"
                  inactive-text="正常"
                />
              </div>
              <div class="item-input-row">
                <el-input
                  v-model="item.result"
                  size="small"
                  placeholder="检查结果"
                />
              </div>
              <div class="item-input-row">
                <el-input
                  v-model="item.referenceRange"
                  size="small"
                  placeholder="参考范围"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="generateDialogVisible = false">取消</el-button>
          <el-button type="primary" :loading="generateLoading" @click="submitGenerateReport">
            确认生成
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.doctor-home-page {
  padding-bottom: 20px;
}

.header {
  padding: 16px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.title {
  font-size: 20px;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.stats-card {
  background: white;
  margin: 0 20px 20px;
  border-radius: 16px;
  padding: 20px;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}

.stat-item {
  text-align: center;
}

.stat-item.divider {
  border-left: 1px solid #f3f4f6;
  border-right: 1px solid #f3f4f6;
}

.stat-value {
  font-size: 20px;
  font-weight: 700;
  color: #0d9488;
  margin: 0;
}

.stat-label {
  font-size: 12px;
  color: #9ca3af;
  margin: 4px 0 0;
}

.appointments-section {
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

.section-sub {
  font-size: 12px;
  color: #9ca3af;
}

.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 0;
  color: #9ca3af;
  gap: 8px;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px 0;
  color: #9ca3af;
  gap: 8px;
  font-size: 14px;
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
  align-items: center;
  margin-bottom: 12px;
}

.appointment-id {
  font-size: 14px;
  font-weight: 700;
  color: #1f2937;
}

.appointment-info {
  border-top: 1px solid #f9fafb;
  padding-top: 12px;
  margin-bottom: 12px;
}

.info-row {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: #6b7280;
  margin: 6px 0;
}

.info-row.remark {
  color: #9ca3af;
  padding: 8px;
  background: #f9fafb;
  border-radius: 8px;
  margin-top: 8px;
}

.appointment-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}

.detail-content {
  padding: 4px 0;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid #f3f4f6;
}

.detail-row:last-child {
  border-bottom: none;
}

.detail-label {
  font-size: 13px;
  color: #9ca3af;
}

.detail-value {
  font-size: 13px;
  color: #1f2937;
  font-weight: 500;
}

.generate-form {
  padding: 4px 0;
}

.form-item {
  margin-bottom: 16px;
}

.form-item label {
  display: block;
  font-size: 13px;
  font-weight: 600;
  color: #374151;
  margin-bottom: 8px;
}

.dialog-footer {
  display: flex;
  gap: 12px;
}

.dialog-footer .el-button {
  flex: 1;
}

.items-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.items-header label {
  margin-bottom: 0;
}

.items-count {
  font-size: 12px;
  color: #9ca3af;
  font-weight: normal;
}

.items-loading {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 20px 0;
  color: #9ca3af;
  font-size: 13px;
}

.items-empty {
  text-align: center;
  padding: 16px 0;
  color: #9ca3af;
  font-size: 13px;
}

.items-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  max-height: 320px;
  overflow-y: auto;
}

.item-input-card {
  background: #f9fafb;
  border-radius: 10px;
  padding: 12px;
  border: 1px solid transparent;
  transition: border-color 0.2s, background 0.2s;
}

.item-input-card.abnormal {
  background: #fef2f2;
  border-color: #fecaca;
}

.item-input-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.item-input-name {
  font-size: 13px;
  font-weight: 600;
  color: #1f2937;
}

.item-input-row {
  margin-bottom: 6px;
}

.item-input-row:last-child {
  margin-bottom: 0;
}

.detail-section {
  margin-bottom: 20px;
}

.detail-section:last-child {
  margin-bottom: 0;
}

.detail-section-title {
  font-size: 14px;
  font-weight: 700;
  color: #1f2937;
  margin: 0 0 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid #f3f4f6;
}

.patient-loading {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 20px 0;
  color: #9ca3af;
  font-size: 13px;
}

.patient-empty {
  text-align: center;
  padding: 16px 0;
  color: #9ca3af;
  font-size: 13px;
}
</style>
