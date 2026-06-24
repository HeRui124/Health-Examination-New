<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Document, Clock, FirstAidKit, Warning } from '@element-plus/icons-vue'
import { getReportList, getReportDetail, getReportItemsAll } from '@/api/report'
import type { Report, ReportItem } from '@/types'

const reports = ref<Report[]>([])
const loading = ref(false)
const page = ref(1)
const size = ref(10)
const total = ref(0)

// 报告详情弹窗
const detailVisible = ref(false)
const detailLoading = ref(false)
const reportDetail = ref<Report | null>(null)
const reportItems = ref<ReportItem[]>([])

async function loadReports() {
  loading.value = true
  try {
    const res = await getReportList(page.value, size.value)
    reports.value = res.records
    total.value = res.total
  } catch (err: any) {
    console.error('加载报告失败:', err.message)
  } finally {
    loading.value = false
  }
}

async function openDetail(report: Report) {
  detailLoading.value = true
  detailVisible.value = true
  reportDetail.value = null
  reportItems.value = []
  try {
    const [detail, items] = await Promise.all([
      getReportDetail(report.id),
      getReportItemsAll(report.id),
    ])
    reportDetail.value = detail
    reportItems.value = items || []
  } catch (err: any) {
    console.error('加载报告详情失败:', err.message)
  } finally {
    detailLoading.value = false
  }
}

function getStatusType(status: number) {
  switch (status) {
    case 0: return 'warning'
    case 1: return 'primary'
    case 2: return 'success'
    default: return 'info'
  }
}

function getStatusLabel(status: number) {
  switch (status) {
    case 0: return '草稿'
    case 1: return '已生成'
    case 2: return '已发布'
    default: return '未知'
  }
}

function formatDate(date?: string) {
  if (!date) return '暂未生成'
  return date.replace('T', ' ').slice(0, 16)
}

onMounted(() => {
  loadReports()
})
</script>

<template>
  <div class="doctor-reports-page">
    <!-- Header -->
    <div class="header">
      <h1 class="title">报告管理</h1>
      <div class="header-actions">
        <el-button circle size="small" @click="loadReports">
          <el-icon><Clock /></el-icon>
        </el-button>
      </div>
    </div>

    <!-- Report List -->
    <div class="reports-section">
      <div class="section-header">
        <h3 class="section-title">我的报告</h3>
        <span class="section-sub">共 {{ total }} 条</span>
      </div>

      <div v-if="loading" class="loading-state">
        <el-icon class="is-loading" :size="24"><Clock /></el-icon>
        <span>加载中...</span>
      </div>

      <div v-else-if="reports.length === 0" class="empty-state">
        <el-icon :size="48" color="#d1d5db"><Document /></el-icon>
        <p>暂无报告数据</p>
      </div>

      <div v-else class="report-list">
        <div
          v-for="report in reports"
          :key="report.id"
          class="report-card"
          @click="openDetail(report)"
        >
          <div class="report-header">
            <div class="report-id">报告 #{{ report.id }}</div>
            <el-tag :type="getStatusType(report.status)" effect="light" size="small">
              {{ getStatusLabel(report.status) }}
            </el-tag>
          </div>

          <div class="report-info">
            <div class="info-row">
              <span class="info-label">患者ID</span>
              <span class="info-value">{{ report.userId }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">关联预约</span>
              <span class="info-value">#{{ report.appointmentId }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">生成时间</span>
              <span class="info-value">{{ formatDate(report.generateTime) }}</span>
            </div>
          </div>

          <div class="report-preview">
            <p class="preview-text">{{ report.summary || '暂无摘要' }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- 报告详情弹窗 -->
    <el-dialog v-model="detailVisible" title="报告详情" width="85%" align-center>
      <div v-if="detailLoading" class="detail-loading">
        <el-icon class="is-loading" :size="24"><Clock /></el-icon>
        <span>加载中...</span>
      </div>
      <div v-else-if="reportDetail" class="detail-content">
        <div class="detail-section">
          <h4 class="detail-section-title">基本信息</h4>
          <div class="detail-row">
            <span class="detail-label">报告编号</span>
            <span class="detail-value">#{{ reportDetail.id }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">患者ID</span>
            <span class="detail-value">{{ reportDetail.userId }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">关联预约</span>
            <span class="detail-value">#{{ reportDetail.appointmentId }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">状态</span>
            <el-tag :type="getStatusType(reportDetail.status)" size="small">
              {{ getStatusLabel(reportDetail.status) }}
            </el-tag>
          </div>
          <div class="detail-row">
            <span class="detail-label">生成时间</span>
            <span class="detail-value">{{ formatDate(reportDetail.generateTime) }}</span>
          </div>
        </div>

        <div class="detail-section">
          <h4 class="detail-section-title">检查摘要</h4>
          <p class="detail-text">{{ reportDetail.summary || '暂无' }}</p>
        </div>

        <div class="detail-section">
          <h4 class="detail-section-title">总检结论</h4>
          <p class="detail-text">{{ reportDetail.conclusion || '暂无' }}</p>
        </div>

        <div v-if="reportItems.length > 0" class="detail-section">
          <h4 class="detail-section-title">检查项目明细 ({{ reportItems.length }}项)</h4>
          <div class="item-list">
            <div
              v-for="item in reportItems"
              :key="item.id"
              class="item-card"
              :class="{ abnormal: item.abnormalFlag === 1 }"
            >
              <div class="item-header">
                <span class="item-name">{{ item.examItemName }}</span>
                <el-tag v-if="item.abnormalFlag === 1" type="danger" size="small">
                  <el-icon :size="10"><Warning /></el-icon>
                  异常
                </el-tag>
                <el-tag v-else type="success" size="small">正常</el-tag>
              </div>
              <div class="item-result">
                <span class="result-label">结果</span>
                <span class="result-value">{{ item.result }}</span>
              </div>
              <div class="item-result">
                <span class="result-label">参考范围</span>
                <span class="result-value">{{ item.referenceRange || '-' }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div v-else class="detail-loading">
        <p>加载失败</p>
      </div>
    </el-dialog>
  </div>
</template>

<style scoped>
.doctor-reports-page {
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

.reports-section {
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

.report-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.report-card {
  background: white;
  padding: 16px;
  border-radius: 16px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
  border: 1px solid #f3f4f6;
  cursor: pointer;
  transition: box-shadow 0.2s;
}

.report-card:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.report-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.report-id {
  font-size: 14px;
  font-weight: 700;
  color: #1f2937;
}

.report-info {
  border-top: 1px solid #f9fafb;
  padding-top: 12px;
  margin-bottom: 12px;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 12px;
  margin: 6px 0;
}

.info-label {
  color: #9ca3af;
}

.info-value {
  color: #374151;
  font-weight: 500;
}

.report-preview {
  background: #f9fafb;
  border-radius: 8px;
  padding: 10px 12px;
}

.preview-text {
  font-size: 12px;
  color: #6b7280;
  margin: 0;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.detail-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 32px 0;
  color: #9ca3af;
  gap: 8px;
}

.detail-content {
  padding: 4px 0;
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

.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
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

.detail-text {
  font-size: 13px;
  color: #374151;
  line-height: 1.6;
  margin: 0;
}

.item-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.item-card {
  background: #f9fafb;
  border-radius: 10px;
  padding: 12px;
  border: 1px solid transparent;
}

.item-card.abnormal {
  background: #fef2f2;
  border-color: #fecaca;
}

.item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.item-name {
  font-size: 13px;
  font-weight: 600;
  color: #1f2937;
}

.item-result {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  margin: 4px 0;
}

.result-label {
  color: #9ca3af;
}

.result-value {
  color: #374151;
  font-weight: 500;
}
</style>
