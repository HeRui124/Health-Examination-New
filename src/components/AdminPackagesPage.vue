<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElButton, ElDialog, ElForm, ElFormItem, ElInput, ElInputNumber } from 'element-plus'
import { Plus, RefreshRight, SwitchButton } from '@element-plus/icons-vue'
import type { ExamPackage, ExamItem } from '@/types'
import { useUserStore } from '@/stores/user'
import { getPackageList, getPackageDetail, createPackage, updatePackage, togglePackageStatus, deletePackage } from '@/api/package'
import { getExamItemList, createExamItem, updateExamItem, deleteExamItem } from '@/api/examitem'

const userStore = useUserStore()

const packages = ref<ExamPackage[]>([])
const loading = ref(false)
const page = ref(1)
const size = ref(10)
const total = ref(0)

const dialogVisible = ref(false)
const dialogMode = ref<'add' | 'edit'>('add')
const form = ref<Partial<ExamPackage>>({ status: 1, sortOrder: 0 })
const formRef = ref<InstanceType<typeof ElForm>>()
const submitting = ref(false)

// 检查项目管理
const currentPackageId = ref<number>(0)
const items = ref<ExamItem[]>([])
const itemsLoading = ref(false)
const itemDialogVisible = ref(false)
const itemDialogMode = ref<'add' | 'edit'>('add')
const itemForm = ref<Partial<ExamItem>>({ sortOrder: 0 })
const itemFormRef = ref<InstanceType<typeof ElForm>>()
const itemSubmitting = ref(false)

async function loadPackages() {
  loading.value = true
  try {
    const res = await getPackageList(page.value, size.value)
    packages.value = res.records
    total.value = res.total
  } catch (err: any) {
    alert('加载套餐列表失败: ' + err.message)
  } finally {
    loading.value = false
  }
}

function openAddDialog() {
  dialogMode.value = 'add'
  form.value = { status: 1, sortOrder: 0 }
  currentPackageId.value = 0
  items.value = []
  dialogVisible.value = true
}

async function openEditDialog(id: number) {
  dialogMode.value = 'edit'
  currentPackageId.value = id
  try {
    const detail = await getPackageDetail(id)
    form.value = { ...detail }
    items.value = detail.items || []
    dialogVisible.value = true
  } catch (err: any) {
    alert('获取套餐详情失败: ' + err.message)
  }
}

async function handleSubmit() {
  if (!formRef.value) return
  await formRef.value.validate()
  submitting.value = true
  try {
    if (dialogMode.value === 'add') {
      await createPackage(form.value)
      alert('新增成功')
    } else {
      await updatePackage(form.value)
      alert('修改成功')
    }
    dialogVisible.value = false
    loadPackages()
  } catch (err: any) {
    alert('操作失败: ' + err.message)
  } finally {
    submitting.value = false
  }
}

async function handleToggleStatus(pkg: ExamPackage) {
  const newStatus = pkg.status === 1 ? 0 : 1
  const action = newStatus === 1 ? '上架' : '下架'
  if (!confirm(`确定要${action}套餐 "${pkg.name}" 吗？`)) return
  try {
    await togglePackageStatus(pkg.id, newStatus)
    alert(`${action}成功`)
    loadPackages()
  } catch (err: any) {
    alert('操作失败: ' + err.message)
  }
}

async function handleDelete(pkg: ExamPackage) {
  if (!confirm(`确定要删除套餐 "${pkg.name}" 吗？此操作不可恢复！`)) return
  try {
    await deletePackage(pkg.id)
    alert('删除成功')
    loadPackages()
  } catch (err: any) {
    alert('删除失败: ' + err.message)
  }
}

// 检查项目操作
function openItemAddDialog() {
  itemDialogMode.value = 'add'
  itemForm.value = { packageId: currentPackageId.value, sortOrder: items.value.length + 1 }
  itemDialogVisible.value = true
}

function openItemEditDialog(item: ExamItem) {
  itemDialogMode.value = 'edit'
  itemForm.value = { ...item }
  itemDialogVisible.value = true
}

async function handleItemSubmit() {
  if (!itemFormRef.value) return
  await itemFormRef.value.validate()
  itemSubmitting.value = true
  try {
    if (itemDialogMode.value === 'add') {
      await createExamItem(currentPackageId.value, itemForm.value)
      alert('新增检查项目成功')
    } else if (itemForm.value.id) {
      await updateExamItem(currentPackageId.value, itemForm.value.id, itemForm.value)
      alert('修改检查项目成功')
    }
    itemDialogVisible.value = false
    // 重新加载套餐详情以刷新检查项目
    if (currentPackageId.value) {
      const detail = await getPackageDetail(currentPackageId.value)
      items.value = detail.items || []
    }
  } catch (err: any) {
    alert('操作失败: ' + err.message)
  } finally {
    itemSubmitting.value = false
  }
}

async function handleItemDelete(item: ExamItem) {
  if (!confirm(`确定要删除检查项目 "${item.name}" 吗？`)) return
  try {
    await deleteExamItem(currentPackageId.value, item.id)
    alert('删除成功')
    const detail = await getPackageDetail(currentPackageId.value)
    items.value = detail.items || []
  } catch (err: any) {
    alert('删除失败: ' + err.message)
  }
}

function handleLogout() {
  if (confirm('确定要退出登录吗？')) {
    userStore.logout()
  }
}

onMounted(loadPackages)
</script>

<template>
  <div class="admin-page">
    <div class="admin-header">
      <h2 class="admin-title">套餐管理</h2>
      <div class="admin-actions">
        <el-button type="primary" size="small" :icon="Plus" circle @click="openAddDialog" />
        <el-button size="small" :icon="RefreshRight" circle @click="loadPackages" />
        <el-button type="danger" size="small" :icon="SwitchButton" circle @click="handleLogout" />
      </div>
    </div>

    <div class="admin-content">
      <div v-if="loading" class="loading-text">加载中...</div>
      <div v-else-if="packages.length === 0" class="empty-text">暂无套餐数据</div>
      <div v-else class="card-list">
        <div v-for="pkg in packages" :key="pkg.id" class="data-card">
          <div class="card-header-row">
            <span class="card-title">{{ pkg.name }}</span>
            <el-tag :type="pkg.status === 1 ? 'success' : 'info'" size="small">
              {{ pkg.status === 1 ? '上架' : '下架' }}
            </el-tag>
          </div>
          <div class="card-info">
            <p>价格：¥{{ pkg.price }}</p>
            <p v-if="pkg.description">描述：{{ pkg.description }}</p>
          </div>
          <div class="card-actions">
            <el-button type="primary" size="small" text @click="openEditDialog(pkg.id)">编辑</el-button>
            <el-button
              :type="pkg.status === 1 ? 'warning' : 'success'"
              size="small"
              text
              @click="handleToggleStatus(pkg)"
            >
              {{ pkg.status === 1 ? '下架' : '上架' }}
            </el-button>
            <el-button type="danger" size="small" text @click="handleDelete(pkg)">删除</el-button>
          </div>
        </div>
      </div>
    </div>

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="dialogMode === 'add' ? '新增套餐' : '编辑套餐'" width="90%">
      <el-form ref="formRef" :model="form" label-width="70px">
        <el-form-item label="名称" required>
          <el-input v-model="form.name" placeholder="请输入套餐名称" />
        </el-form-item>
        <el-form-item label="价格" required>
          <el-input-number v-model="form.price" :min="0" :precision="2" style="width: 100%" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" type="textarea" :rows="3" placeholder="请输入套餐描述" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.sortOrder" :min="0" style="width: 100%" />
        </el-form-item>
      </el-form>

      <!-- 检查项目管理（仅编辑模式） -->
      <div v-if="dialogMode === 'edit'" class="items-section">
        <div class="items-header">
          <h3 class="items-title">检查项目</h3>
          <el-button type="primary" size="small" :icon="Plus" circle @click="openItemAddDialog" />
        </div>
        <div v-if="items.length === 0" class="empty-text" style="padding: 16px 0;">暂无检查项目</div>
        <div v-else class="item-list">
          <div v-for="item in items" :key="item.id" class="item-row">
            <div class="item-info">
              <span class="item-name">{{ item.name }}</span>
              <el-tag v-if="item.type" size="small" type="info">{{ item.type }}</el-tag>
            </div>
            <div class="item-actions">
              <el-button type="primary" size="small" text @click="openItemEditDialog(item)">编辑</el-button>
              <el-button type="danger" size="small" text @click="handleItemDelete(item)">删除</el-button>
            </div>
          </div>
        </div>
      </div>

      <template #footer>
        <el-button size="small" @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" size="small" :loading="submitting" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 检查项目编辑弹窗 -->
    <el-dialog v-model="itemDialogVisible" :title="itemDialogMode === 'add' ? '新增检查项目' : '编辑检查项目'" width="90%">
      <el-form ref="itemFormRef" :model="itemForm" label-width="70px">
        <el-form-item label="名称" required>
          <el-input v-model="itemForm.name" placeholder="请输入项目名称" />
        </el-form-item>
        <el-form-item label="类型" required>
          <el-input v-model="itemForm.type" placeholder="如：检验、影像、心电、体格" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="itemForm.description" type="textarea" :rows="3" placeholder="请输入项目描述" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="itemForm.sortOrder" :min="0" style="width: 100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button size="small" @click="itemDialogVisible = false">取消</el-button>
        <el-button type="primary" size="small" :loading="itemSubmitting" @click="handleItemSubmit">确定</el-button>
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

.items-section {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #e5e7eb;
}

.items-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.items-title {
  font-size: 15px;
  font-weight: 600;
  color: #374151;
}

.item-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.item-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  background: #f9fafb;
  border-radius: 8px;
}

.item-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.item-name {
  font-size: 14px;
  color: #1f2937;
}

.item-actions {
  display: flex;
  gap: 4px;
}
</style>
