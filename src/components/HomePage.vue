<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Star, StarFilled, Clock } from '@element-plus/icons-vue'
import { getActiveInstitutions, getInstitutionDetail } from '@/api/institution'
import { getPackageList, getPackageDetail } from '@/api/package'
import { getDictItemsByType } from '@/api/dict'
import type { Institution, ExamPackage, ExamItem, DictItem } from '@/types'

// 机构数据（接口获取）
const institutions = ref<Institution[]>([])
// 套餐数据（接口获取）
const packages = ref<ExamPackage[]>([])
// 体检类型数据（接口获取）
const appointmentTypes = ref<DictItem[]>([])
const loading = ref(false)

// 机构详情弹窗
const instDetailVisible = ref(false)
const instDetail = ref<Institution | null>(null)
const instDetailLoading = ref(false)

async function openInstDetail(id: number) {
  instDetailLoading.value = true
  instDetailVisible.value = true
  try {
    instDetail.value = await getInstitutionDetail(id)
  } catch {
    instDetail.value = null
  } finally {
    instDetailLoading.value = false
  }
}

// 套餐详情弹窗
const pkgDetailVisible = ref(false)
const pkgDetail = ref<(ExamPackage & { items?: ExamItem[] }) | null>(null)
const pkgDetailLoading = ref(false)

async function openPkgDetail(id: number) {
  pkgDetailLoading.value = true
  pkgDetailVisible.value = true
  try {
    pkgDetail.value = await getPackageDetail(id)
  } catch {
    pkgDetail.value = null
  } finally {
    pkgDetailLoading.value = false
  }
}

function renderStars(rating: number) {
  const full = Math.floor(rating)
  const half = rating % 1 >= 0.5 ? 1 : 0
  const empty = 5 - full - half
  return { full, half, empty }
}

// 加载数据（分别请求，互不影响）
async function loadData() {
  loading.value = true
  // 机构列表（推荐机构）
  try {
    institutions.value = await getActiveInstitutions()
  } catch (err: any) {
    console.warn('加载机构列表失败:', err.message)
    institutions.value = []
  }
  // 体检类型列表
  try {
    const typeRes = await getDictItemsByType(4)
    appointmentTypes.value = typeRes.records
  } catch (err: any) {
    console.warn('加载体检类型失败:', err.message)
    appointmentTypes.value = []
  }
  // 套餐列表
  try {
    const pkgRes = await getPackageList(1, 10)
    packages.value = pkgRes.records
  } catch (err: any) {
    console.warn('加载套餐列表失败:', err.message)
    packages.value = []
  }
  loading.value = false
}

onMounted(() => {
  loadData()
})

// 获取套餐图标样式（根据套餐名称匹配）
function getPackageStyle(name: string) {
  if (name.includes('女性')) {
    return { icon: 'Sugar', color: '#ec4899', bgColor: '#fdf2f8' }
  }
  if (name.includes('老年') || name.includes('银发')) {
    return { icon: 'FirstAidKit', color: '#f97316', bgColor: '#fff7ed' }
  }
  return { icon: 'User', color: '#0d9488', bgColor: '#f0fdfa' }
}

// 获取套餐价格描述
function getPriceText(price: number) {
  return `¥${price}`
}

// 获取套餐区域/描述
function getAreaFromAddress(address?: string) {
  if (!address) return ''
  const match = address.match(/([^省]+?市)/)
  return match ? match[1] : address.slice(0, 6)
}
</script>

<template>
  <div class="home-page">
    <!-- Header -->
    <div class="header">
      <h1 class="title">体检预约</h1>
      <el-avatar :size="40" src="https://modao.cc/agent-py/media/generated_images/2026-06-03/77a29bb9007d446b815a98cbb9868450.jpg" class="user-avatar" />
    </div>

    <!-- Recommended Institutions -->
    <div class="section">
      <h3 class="section-title">推荐体检机构</h3>
      <div v-if="institutions.length" class="institution-list">
        <div v-for="inst in institutions" :key="inst.id" class="institution-card" @click="openInstDetail(inst.id)">
          <div class="institution-image">
            <img :src="'https://modao.cc/agent-py/media/generated_images/2026-06-03/5fbe64543f784aafbc88093483f1b63a.jpg'" :alt="inst.name" />
          </div>
          <h4 class="institution-name">{{ inst.name }}</h4>
          <div class="institution-rating">
            <template v-for="i in renderStars(4.5).full" :key="'f' + i">
              <el-icon color="#f59e0b" :size="12"><StarFilled /></el-icon>
            </template>
            <template v-if="renderStars(4.5).half">
              <el-icon color="#f59e0b" :size="12"><StarFilled /></el-icon>
            </template>
            <template v-for="i in renderStars(4.5).empty" :key="'e' + i">
              <el-icon color="#e5e7eb" :size="12"><Star /></el-icon>
            </template>
            <span class="rating-text">4.5</span>
          </div>
          <div class="institution-footer">
            <span class="area">{{ getAreaFromAddress(inst.address) }}</span>
            <span class="price">{{ inst.phone || '' }}</span>
          </div>
        </div>
      </div>
      <div v-else class="empty-state">
        <p>暂无机构数据</p>
      </div>
    </div>

    <!-- Popular Appointment Types -->
    <div class="section">
      <div class="section-header">
        <h3 class="section-title">热门体检类型</h3>
      </div>
      <div v-if="appointmentTypes.length" class="type-list">
        <div
          v-for="type in appointmentTypes"
          :key="type.id"
          class="type-card"
        >
          <span class="type-label">{{ type.label }}</span>
        </div>
      </div>
      <div v-else class="empty-state">
        <p>暂无类型数据</p>
      </div>
    </div>

    <!-- Popular Packages -->
    <div class="section">
      <h3 class="section-title">热门体检套餐</h3>
      <div v-if="packages.length" class="package-list">
        <div v-for="pkg in packages" :key="pkg.id" class="package-card" @click="openPkgDetail(pkg.id)">
          <div class="package-icon" :style="{ backgroundColor: getPackageStyle(pkg.name).bgColor, color: getPackageStyle(pkg.name).color }">
            <el-icon :size="28">
              <component :is="getPackageStyle(pkg.name).icon" />
            </el-icon>
          </div>
          <div class="package-info">
            <h4 class="package-title">{{ pkg.name }}</h4>
            <p class="package-org">{{ pkg.description || '' }}</p>
            <div class="package-price-row">
              <span class="package-price">{{ getPriceText(pkg.price) }}</span>
              <el-tag :style="{ backgroundColor: getPackageStyle(pkg.name).bgColor, color: getPackageStyle(pkg.name).color, border: 'none' }" size="small">热销中</el-tag>
            </div>
          </div>
        </div>
      </div>
      <div v-else class="empty-state">
        <p>暂无套餐数据</p>
      </div>
    </div>

    <!-- 机构详情弹窗 -->
    <el-dialog v-model="instDetailVisible" :title="instDetail?.name || '机构详情'" width="85%" align-center>
      <div v-if="instDetailLoading" class="detail-loading">
        <el-icon class="is-loading" :size="24"><Clock /></el-icon>
        <span>加载中...</span>
      </div>
      <div v-else-if="instDetail" class="detail-content">
        <p class="detail-label">地址</p>
        <p class="detail-value">{{ instDetail.address || '暂无' }}</p>
        <p class="detail-label">电话</p>
        <p class="detail-value">{{ instDetail.phone || '暂无' }}</p>
        <p class="detail-label">营业时间</p>
        <p class="detail-value">{{ instDetail.businessHours || '暂无' }}</p>
        <p class="detail-label">简介</p>
        <p class="detail-value">{{ instDetail.description || '暂无' }}</p>
      </div>
      <div v-else class="detail-loading">
        <p>加载失败</p>
      </div>
    </el-dialog>

    <!-- 套餐详情弹窗 -->
    <el-dialog v-model="pkgDetailVisible" :title="pkgDetail?.name || '套餐详情'" width="85%" align-center>
      <div v-if="pkgDetailLoading" class="detail-loading">
        <el-icon class="is-loading" :size="24"><Clock /></el-icon>
        <span>加载中...</span>
      </div>
      <div v-else-if="pkgDetail" class="detail-content">
        <p class="detail-label">价格</p>
        <p class="detail-value price-highlight">¥{{ pkgDetail.price }}</p>
        <p class="detail-label">描述</p>
        <p class="detail-value">{{ pkgDetail.description || '暂无' }}</p>
        <template v-if="pkgDetail.items && pkgDetail.items.length > 0">
          <p class="detail-label">检查项目 ({{ pkgDetail.items.length }}项)</p>
          <div class="item-tags">
            <el-tag v-for="item in pkgDetail.items" :key="item.id" size="small" type="info">{{ item.name }}</el-tag>
          </div>
        </template>
      </div>
      <div v-else class="detail-loading">
        <p>加载失败</p>
      </div>
    </el-dialog>
  </div>
</template>

<style scoped>
.home-page {
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

.user-avatar {
  border: 2px solid #0d9488;
}

.section {
  margin-top: 24px;
}

.section-header {
  padding: 0 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.section-title {
  font-size: 16px;
  font-weight: 700;
  color: #1f2937;
  margin: 0 0 0 20px;
}

.institution-list {
  display: flex;
  gap: 12px;
  padding: 0 20px;
  overflow-x: auto;
  scrollbar-width: none;
}

.institution-list::-webkit-scrollbar {
  display: none;
}

.institution-card {
  flex-shrink: 0;
  width: 176px;
  background: white;
  border-radius: 12px;
  padding: 12px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
  border: 1px solid #f3f4f6;
  cursor: pointer;
  transition: box-shadow 0.2s;
}

.institution-card:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.institution-image {
  height: 96px;
  border-radius: 8px;
  overflow: hidden;
  background: #f3f4f6;
}

.institution-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.institution-name {
  font-size: 14px;
  font-weight: 600;
  color: #1f2937;
  margin: 10px 0 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.institution-rating {
  display: flex;
  align-items: center;
  gap: 2px;
}

.rating-text {
  margin-left: 4px;
  font-size: 10px;
  color: #9ca3af;
}

.institution-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 8px;
}

.area {
  font-size: 10px;
  color: #9ca3af;
}

.price {
  font-size: 12px;
  font-weight: 700;
  color: #0d9488;
}

.type-list {
  display: flex;
  gap: 10px;
  padding: 0 20px;
  overflow-x: auto;
  scrollbar-width: none;
}

.type-list::-webkit-scrollbar {
  display: none;
}

.type-card {
  flex-shrink: 0;
  padding: 8px 16px;
  background: white;
  border-radius: 20px;
  border: 1px solid #e5e7eb;
  font-size: 13px;
  color: #374151;
  cursor: pointer;
  transition: all 0.2s;
}

.type-card:hover {
  border-color: #0d9488;
  color: #0d9488;
  background: #f0fdfa;
}

.package-list {
  padding: 0 20px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.package-card {
  background: white;
  padding: 16px;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
  border: 1px solid #f3f4f6;
  display: flex;
  align-items: center;
  gap: 16px;
  cursor: pointer;
  transition: box-shadow 0.2s;
}

.package-card:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.package-icon {
  width: 64px;
  height: 64px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.package-info {
  flex: 1;
  min-width: 0;
}

.package-title {
  font-size: 14px;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.package-org {
  font-size: 10px;
  color: #9ca3af;
  margin: 4px 0 0;
}

.package-price-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 8px;
}

.package-price {
  color: #0d9488;
  font-weight: 700;
  font-size: 14px;
}

.package-original {
  color: #d1d5db;
  text-decoration: line-through;
  font-size: 10px;
}

.empty-state {
  padding: 24px 20px;
  text-align: center;
  color: #9ca3af;
  font-size: 13px;
}

/* 详情弹窗 */
.detail-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 32px 0;
  color: #9ca3af;
  gap: 8px;
  font-size: 14px;
}

.detail-content {
  padding: 4px 0;
}

.detail-label {
  font-size: 12px;
  color: #9ca3af;
  margin: 12px 0 4px;
}

.detail-label:first-child {
  margin-top: 0;
}

.detail-value {
  font-size: 14px;
  color: #1f2937;
  margin: 0;
  line-height: 1.6;
}

.price-highlight {
  font-size: 20px;
  font-weight: 700;
  color: #0d9488;
}

.item-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 4px;
}

</style>
