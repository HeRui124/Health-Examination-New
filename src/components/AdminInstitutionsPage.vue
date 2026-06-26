<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElButton, ElDialog, ElForm, ElFormItem, ElInput, ElInputNumber, ElCheckbox } from 'element-plus'
import { Plus, RefreshRight, SwitchButton } from '@element-plus/icons-vue'
import type { Institution, InstitutionPackage, ExamPackage } from '@/types'
import { useUserStore } from '@/stores/user'
import { getInstitutionList, getInstitutionDetail, createInstitution, updateInstitution, deleteInstitution } from '@/api/institution'
import { getInstitutionPackages, createInstitutionPackage, deleteInstitutionPackage } from '@/api/institution-package'
import { getPackageList } from '@/api/package'

const userStore = useUserStore()

const institutions = ref<Institution[]>([])
const loading = ref(false)
const page = ref(1)
const size = ref(10)
const total = ref(0)

const dialogVisible = ref(false)
const dialogMode = ref<'add' | 'edit'>('add')
const form = ref<Partial<Institution>>({ status: 1, sortOrder: 0 })
const formRef = ref<InstanceType<typeof ElForm>>()
const submitting = ref(false)

// 关联套餐管理
const currentInstitutionId = ref<number>(0)
const institutionPackages = ref<InstitutionPackage[]>([])
const allPackages = ref<ExamPackage[]>([])
const packageSelectVisible = ref(false)
const selectedPackageIds = ref<number[]>([])
const linkLoading = ref(false)

async function loadInstitutions() {
  loading.value = true
  try {
    const res = await getInstitutionList(page.value, size.value)
    institutions.value = res.records
    total.value = res.total
  } catch (err: any) {
    alert('加载机构列表失败: ' + err.message)
  } finally {
    loading.value = false
  }
}

function openAddDialog() {
  dialogMode.value = 'add'
  form.value = { status: 1, sortOrder: 0 }
  currentInstitutionId.value = 0
  institutionPackages.value = []
  dialogVisible.value = true
}

async function openEditDialog(id: number) {
  dialogMode.value = 'edit'
  currentInstitutionId.value = id
  try {
    const detail = await getInstitutionDetail(id)
    form.value = { ...detail }
    dialogVisible.value = true
    await loadInstitutionPackages(id)
  } catch (err: any) {
    alert('获取机构详情失败: ' + err.message)
  }
}

async function loadInstitutionPackages(institutionId: number) {
  linkLoading.value = true
  try {
    const [links, pkgs] = await Promise.all([
      getInstitutionPackages(institutionId),
      getPackageList(1, 100),
    ])
    institutionPackages.value = links
    allPackages.value = pkgs.records
  } catch (err: any) {
    console.warn('加载关联套餐失败:', err.message)
    institutionPackages.value = []
    allPackages.value = []
  } finally {
    linkLoading.value = false
  }
}

function openPackageSelectDialog() {
  const linkedIds = new Set(institutionPackages.value.map(lp => lp.packageId))
  selectedPackageIds.value = allPackages.value
    .filter(pkg => linkedIds.has(pkg.id))
    .map(pkg => pkg.id)
  packageSelectVisible.value = true
}

async function handleSavePackageLinks() {
  if (!currentInstitutionId.value) return
  linkLoading.value = true
  try {
    const linkedIds = new Set(institutionPackages.value.map(lp => lp.packageId))
    const selectedIds = new Set(selectedPackageIds.value)

    // 需要新增的
    for (const pkgId of selectedIds) {
      if (!linkedIds.has(pkgId)) {
        await createInstitutionPackage({ institutionId: currentInstitutionId.value, packageId: pkgId })
      }
    }
    // 需要删除的
    for (const lp of institutionPackages.value) {
      if (!selectedIds.has(lp.packageId)) {
        await deleteInstitutionPackage(lp.id)
      }
    }

    alert('关联套餐更新成功')
    packageSelectVisible.value = false
    await loadInstitutionPackages(currentInstitutionId.value)
  } catch (err: any) {
    alert('更新关联套餐失败: ' + err.message)
  } finally {
    linkLoading.value = false
  }
}

async function handleSubmit() {
  if (!formRef.value) return
  await formRef.value.validate()
  submitting.value = true
  try {
    if (dialogMode.value === 'add') {
      await createInstitution(form.value)
      alert('新增成功')
    } else {
      await updateInstitution(form.value)
      alert('修改成功')
    }
    dialogVisible.value = false
    loadInstitutions()
  } catch (err: any) {
    alert('操作失败: ' + err.message)
  } finally {
    submitting.value = false
  }
}

async function handleDelete(inst: Institution) {
  if (!confirm(`确定要删除机构 "${inst.name}" 吗？此操作不可恢复！`)) return
  try {
    await deleteInstitution(inst.id)
    alert('删除成功')
    loadInstitutions()
  } catch (err: any) {
    alert('删除失败: ' + err.message)
  }
}

async function handleToggleStatus(inst: Institution) {
  const newStatus = inst.status === 1 ? 0 : 1
  const action = newStatus === 1 ? '启用' : '停用'
  if (!confirm(`确定要${action}机构 "${inst.name}" 吗？`)) return
  try {
    await updateInstitution({ id: inst.id, status: newStatus })
    alert(`${action}成功`)
    loadInstitutions()
  } catch (err: any) {
    alert('操作失败: ' + err.message)
  }
}

function handleLogout() {
  if (confirm('确定要退出登录吗？')) {
    userStore.logout()
  }
}

onMounted(loadInstitutions)
</script>

<template>
  <div class="admin-page">
    <div class="admin-header">
      <h2 class="admin-title">机构管理</h2>
      <div class="admin-actions">
        <el-button type="primary" size="small" :icon="Plus" circle @click="openAddDialog" />
        <el-button size="small" :icon="RefreshRight" circle @click="loadInstitutions" />
        <el-button type="danger" size="small" :icon="SwitchButton" circle @click="handleLogout" />
      </div>
    </div>

    <div class="admin-content">
      <div v-if="loading" class="loading-text">加载中...</div>
      <div v-else-if="institutions.length === 0" class="empty-text">暂无机构数据</div>
      <div v-else class="card-list">
        <div v-for="inst in institutions" :key="inst.id" class="data-card">
          <div class="card-header-row">
            <span class="card-title">{{ inst.name }}</span>
            <el-tag :type="inst.status === 1 ? 'success' : 'info'" size="small">
              {{ inst.status === 1 ? '正常' : '停用' }}
            </el-tag>
          </div>
          <div class="card-info">
            <p v-if="inst.address">地址：{{ inst.address }}</p>
            <p v-if="inst.phone">电话：{{ inst.phone }}</p>
            <p v-if="inst.businessHours">营业时间：{{ inst.businessHours }}</p>
            <p v-if="inst.description">描述：{{ inst.description }}</p>
          </div>
          <div class="card-actions">
            <el-button type="primary" size="small" text @click="openEditDialog(inst.id)">编辑</el-button>
            <el-button
              :type="inst.status === 1 ? 'warning' : 'success'"
              size="small"
              text
              @click="handleToggleStatus(inst)"
            >
              {{ inst.status === 1 ? '停用' : '启用' }}
            </el-button>
            <el-button type="danger" size="small" text @click="handleDelete(inst)">删除</el-button>
          </div>
        </div>
      </div>
    </div>

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="dialogMode === 'add' ? '新增机构' : '编辑机构'" width="90%">
      <el-form ref="formRef" :model="form" label-width="70px">
        <el-form-item label="名称" required>
          <el-input v-model="form.name" placeholder="请输入机构名称" />
        </el-form-item>
        <el-form-item label="地址">
          <el-input v-model="form.address" placeholder="请输入机构地址" />
        </el-form-item>
        <el-form-item label="电话">
          <el-input v-model="form.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="营业时间">
          <el-input v-model="form.businessHours" placeholder="例如：08:00-18:00" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" type="textarea" :rows="3" placeholder="请输入机构描述" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.sortOrder" :min="0" style="width: 100%" />
        </el-form-item>
      </el-form>

      <!-- 关联套餐（仅编辑模式） -->
      <div v-if="dialogMode === 'edit'" class="items-section">
        <div class="items-header">
          <h3 class="items-title">关联套餐</h3>
          <el-button type="primary" size="small" :icon="Plus" circle @click="openPackageSelectDialog" />
        </div>
        <div v-if="linkLoading" class="loading-text" style="padding: 12px 0;">加载中...</div>
        <div v-else-if="institutionPackages.length === 0" class="empty-text" style="padding: 12px 0;">暂未关联套餐</div>
        <div v-else class="linked-package-list">
          <div v-for="lp in institutionPackages" :key="lp.id" class="linked-package-tag">
            <el-tag size="small" type="info">
              {{ allPackages.find(p => p.id === lp.packageId)?.name || `套餐#${lp.packageId}` }}
            </el-tag>
          </div>
        </div>
      </div>

      <template #footer>
        <el-button size="small" @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" size="small" :loading="submitting" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 选择关联套餐弹窗 -->
    <el-dialog v-model="packageSelectVisible" title="选择关联套餐" width="90%">
      <div v-if="allPackages.length === 0" class="empty-text">暂无可用套餐</div>
      <div v-else class="package-checkbox-list">
        <el-checkbox-group v-model="selectedPackageIds">
          <div v-for="pkg in allPackages" :key="pkg.id" class="package-checkbox-item">
            <el-checkbox :label="pkg.id">{{ pkg.name }}（¥{{ pkg.price }}）</el-checkbox>
          </div>
        </el-checkbox-group>
      </div>
      <template #footer>
        <el-button size="small" @click="packageSelectVisible = false">取消</el-button>
        <el-button type="primary" size="small" :loading="linkLoading" @click="handleSavePackageLinks">确定</el-button>
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

.linked-package-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.package-checkbox-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  max-height: 300px;
  overflow-y: auto;
}

.package-checkbox-item {
  padding: 8px;
  background: #f9fafb;
  border-radius: 8px;
}
</style>
