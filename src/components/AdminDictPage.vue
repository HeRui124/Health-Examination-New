<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElButton, ElTable, ElTableColumn, ElTag, ElDialog, ElForm, ElFormItem, ElInput, ElInputNumber, ElSwitch, ElMessageBox } from 'element-plus'
import { Plus, Edit, Delete, Refresh } from '@element-plus/icons-vue'
import type { DictType, DictItem } from '@/types'
import { getDictTypeList, createDictType, updateDictType, deleteDictType } from '@/api/dict'
import { getDictItemsByType, createDictItem, updateDictItem, deleteDictItem } from '@/api/dict'

// 左侧：字典类型
const dictTypes = ref<DictType[]>([])
const typeLoading = ref(false)
const selectedTypeId = ref<number | null>(null)

// 右侧：字典项
const dictItems = ref<DictItem[]>([])
const itemLoading = ref(false)

// 字典类型对话框
const typeDialogVisible = ref(false)
const typeDialogMode = ref<'add' | 'edit'>('add')
const typeForm = ref<Partial<DictType>>({})
const typeSubmitting = ref(false)

// 字典项对话框
const itemDialogVisible = ref(false)
const itemDialogMode = ref<'add' | 'edit'>('add')
const itemForm = ref<Partial<DictItem>>({})
const itemSubmitting = ref(false)

// 加载字典类型列表
async function loadDictTypes() {
  typeLoading.value = true
  try {
    const res = await getDictTypeList(1, 100)
    dictTypes.value = res.records
  } catch (err: any) {
    console.error('加载字典类型失败:', err.message)
  } finally {
    typeLoading.value = false
  }
}

// 选择字典类型，加载对应的字典项
async function selectDictType(typeId: number) {
  selectedTypeId.value = typeId
  await loadDictItems(typeId)
}

// 加载字典项列表
async function loadDictItems(typeId: number) {
  if (!typeId) return
  itemLoading.value = true
  try {
    const res = await getDictItemsByType(typeId, 1, 100)
    dictItems.value = res.records
  } catch (err: any) {
    console.error('加载字典项失败:', err.message)
  } finally {
    itemLoading.value = false
  }
}

// 打开字典类型新增/编辑对话框
function openTypeDialog(mode: 'add' | 'edit', row?: DictType) {
  typeDialogMode.value = mode
  if (mode === 'edit' && row) {
    typeForm.value = { ...row }
  } else {
    typeForm.value = { status: 1 }
  }
  typeDialogVisible.value = true
}

// 提交字典类型
async function submitTypeForm() {
  if (!typeForm.value.dictName || !typeForm.value.dictType) {
    alert('请填写完整信息')
    return
  }
  typeSubmitting.value = true
  try {
    if (typeDialogMode.value === 'add') {
      await createDictType(typeForm.value)
      alert('添加成功')
    } else {
      await updateDictType(typeForm.value)
      alert('更新成功')
    }
    typeDialogVisible.value = false
    await loadDictTypes()
  } catch (err: any) {
    alert('操作失败: ' + err.message)
  } finally {
    typeSubmitting.value = false
  }
}

// 删除字典类型
async function handleDeleteType(row: DictType) {
  try {
    await ElMessageBox.confirm(`确定要删除字典类型"${row.dictName}"吗？`, '提示', {
      type: 'warning'
    })
    await deleteDictType(row.id)
    alert('删除成功')
    await loadDictTypes()
    if (selectedTypeId.value === row.id) {
      selectedTypeId.value = null
      dictItems.value = []
    }
  } catch (err: any) {
    if (err !== 'cancel') {
      alert('删除失败: ' + err.message)
    }
  }
}

// 打开字典项新增/编辑对话框
function openItemDialog(mode: 'add' | 'edit', row?: DictItem | any) {
  if (!selectedTypeId.value) {
    alert('请先选择字典类型')
    return
  }
  itemDialogMode.value = mode
  if (mode === 'edit' && row) {
    itemForm.value = { ...row }
  } else {
    itemForm.value = { dictTypeId: selectedTypeId.value, sortOrder: 1, status: 1 }
  }
  itemDialogVisible.value = true
}

// 提交字典项
async function submitItemForm() {
  if (!itemForm.value.label || !itemForm.value.value) {
    alert('请填写完整信息')
    return
  }
  itemSubmitting.value = true
  try {
    if (itemDialogMode.value === 'add') {
      await createDictItem(itemForm.value)
      alert('添加成功')
    } else {
      await updateDictItem(itemForm.value)
      alert('更新成功')
    }
    itemDialogVisible.value = false
    if (selectedTypeId.value) {
      await loadDictItems(selectedTypeId.value)
    }
  } catch (err: any) {
    alert('操作失败: ' + err.message)
  } finally {
    itemSubmitting.value = false
  }
}

// 删除字典项
async function handleDeleteItem(row: DictItem | any) {
  try {
    await ElMessageBox.confirm(`确定要删除字典项"${row.label}"吗？`, '提示', {
      type: 'warning'
    })
    await deleteDictItem(row.id)
    alert('删除成功')
    if (selectedTypeId.value) {
      await loadDictItems(selectedTypeId.value)
    }
  } catch (err: any) {
    if (err !== 'cancel') {
      alert('删除失败: ' + err.message)
    }
  }
}

// 获取状态标签类型
function getStatusType(status: number) {
  return status === 1 ? 'success' : 'danger'
}

// 获取状态文本
function getStatusText(status: number) {
  return status === 1 ? '启用' : '禁用'
}

onMounted(() => {
  loadDictTypes()
})
</script>

<template>
  <div class="admin-dict-page">
    <!-- Header -->
    <div class="header">
      <h1 class="title">字典管理</h1>
      <div class="header-actions">
        <el-button circle size="small" @click="loadDictTypes">
          <el-icon><Refresh /></el-icon>
        </el-button>
      </div>
    </div>

    <!-- 左右分栏布局 -->
    <div class="dict-container">
      <!-- 左侧：字典类型列表 -->
      <div class="left-panel">
        <div class="panel-header">
          <h3 class="panel-title">字典类型</h3>
          <el-button size="small" type="primary" @click="openTypeDialog('add')">
            <el-icon><Plus /></el-icon>
            新增
          </el-button>
        </div>

        <div v-if="typeLoading" class="loading-state">
          <span>加载中...</span>
        </div>

        <div v-else class="type-list">
          <div
            v-for="type in dictTypes"
            :key="type.id"
            class="type-item"
            :class="{ active: selectedTypeId === type.id }"
            @click="selectDictType(type.id)"
          >
            <div class="type-info">
              <div class="type-name">{{ type.dictName }}</div>
              <div class="type-code">{{ type.dictType }}</div>
            </div>
            <div class="type-actions">
              <el-tag :type="getStatusType(type.status)" size="small">
                {{ getStatusText(type.status) }}
              </el-tag>
              <el-button size="small" text @click.stop="openTypeDialog('edit', type)">
                <el-icon><Edit /></el-icon>
              </el-button>
              <el-button size="small" text type="danger" @click.stop="handleDeleteType(type)">
                <el-icon><Delete /></el-icon>
              </el-button>
            </div>
          </div>

          <div v-if="dictTypes.length === 0" class="empty-state">
            <span>暂无字典类型</span>
          </div>
        </div>
      </div>

      <!-- 右侧：字典项列表 -->
      <div class="right-panel">
        <div class="panel-header">
          <h3 class="panel-title">
            {{ selectedTypeId ? '字典项' : '请选择字典类型' }}
          </h3>
          <el-button
            v-if="selectedTypeId"
            size="small"
            type="primary"
            @click="openItemDialog('add')"
          >
            <el-icon><Plus /></el-icon>
            新增
          </el-button>
        </div>

        <div v-if="!selectedTypeId" class="empty-hint">
          <p>请从左侧选择一个字典类型</p>
        </div>

        <div v-else-if="itemLoading" class="loading-state">
          <span>加载中...</span>
        </div>

        <div v-else class="item-table-container">
          <el-table :data="dictItems" stripe style="width: 100%">
            <el-table-column prop="label" label="标签" width="150" />
            <el-table-column prop="value" label="值" width="150" />
            <el-table-column prop="sortOrder" label="排序" width="80" align="center" />
            <el-table-column label="状态" width="100" align="center">
              <template #default="{ row }">
                <el-tag :type="getStatusType(row.status)" size="small">
                  {{ getStatusText(row.status) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="remark" label="备注" min-width="150" show-overflow-tooltip />
            <el-table-column label="操作" width="120" align="center" fixed="right">
              <template #default="{ row }">
                <el-button size="small" text @click="openItemDialog('edit', row as DictItem)">
                  <el-icon><Edit /></el-icon>
                  编辑
                </el-button>
                <el-button size="small" text type="danger" @click="handleDeleteItem(row as DictItem)">
                  <el-icon><Delete /></el-icon>
                  删除
                </el-button>
              </template>
            </el-table-column>
          </el-table>

          <div v-if="dictItems.length === 0" class="empty-state">
            <span>暂无字典项</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 字典类型对话框 -->
    <el-dialog
      v-model="typeDialogVisible"
      :title="typeDialogMode === 'add' ? '新增字典类型' : '编辑字典类型'"
      width="90%"
      :style="{ maxWidth: '500px' }"
    >
      <el-form :model="typeForm" label-width="80px">
        <el-form-item label="字典名称" required>
          <el-input v-model="typeForm.dictName" placeholder="请输入字典名称" />
        </el-form-item>
        <el-form-item label="字典编码" required>
          <el-input v-model="typeForm.dictType" placeholder="如：exam_appt_type" />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch
            v-model="typeForm.status"
            :active-value="1"
            :inactive-value="0"
            active-text="启用"
            inactive-text="禁用"
          />
        </el-form-item>
        <el-form-item label="备注">
          <el-input
            v-model="typeForm.remark"
            type="textarea"
            :rows="3"
            placeholder="请输入备注"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="typeDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="typeSubmitting" @click="submitTypeForm">
          确定
        </el-button>
      </template>
    </el-dialog>

    <!-- 字典项对话框 -->
    <el-dialog
      v-model="itemDialogVisible"
      :title="itemDialogMode === 'add' ? '新增字典项' : '编辑字典项'"
      width="90%"
      :style="{ maxWidth: '500px' }"
    >
      <el-form :model="itemForm" label-width="70px">
        <el-form-item label="标签" required>
          <el-input v-model="itemForm.label" placeholder="如：个人体检" />
        </el-form-item>
        <el-form-item label="值" required>
          <el-input v-model="itemForm.value" placeholder="如：individual" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="itemForm.sortOrder" :min="1" :max="999" />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch
            v-model="itemForm.status"
            :active-value="1"
            :inactive-value="0"
            active-text="启用"
            inactive-text="禁用"
          />
        </el-form-item>
        <el-form-item label="备注">
          <el-input
            v-model="itemForm.remark"
            type="textarea"
            :rows="3"
            placeholder="请输入备注"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="itemDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="itemSubmitting" @click="submitItemForm">
          确定
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.admin-dict-page {
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

.dict-container {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding: 0 20px;
  min-height: calc(100vh - 200px);
}

.left-panel,
.right-panel {
  background: white;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  border: 1px solid #f3f4f6;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.left-panel {
  width: 100%;
  max-height: 280px;
}

.right-panel {
  flex: 1;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-bottom: 1px solid #f3f4f6;
}

.panel-title {
  font-size: 16px;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.type-list {
  flex: 1;
  overflow-y: auto;
  padding: 8px;
  display: flex;
  flex-direction: row;
  overflow-x: auto;
  gap: 8px;
}

.type-item {
  min-width: 140px;
  flex-shrink: 0;
  margin-bottom: 0;
  flex-direction: column;
  align-items: flex-start;
}

.type-actions {
  margin-top: 8px;
  width: 100%;
  justify-content: space-between;
}

.type-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  margin-bottom: 8px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid transparent;
}

.type-item:hover {
  background: #f9fafb;
}

.type-item.active {
  background: #f0fdfa;
  border-color: #14b8a6;
}

.type-info {
  flex: 1;
}

.type-name {
  font-size: 14px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 4px;
}

.type-code {
  font-size: 12px;
  color: #9ca3af;
}

.type-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.loading-state {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 0;
  color: #9ca3af;
}

.empty-state {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 0;
  color: #9ca3af;
  font-size: 14px;
}

.empty-hint {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 60px 0;
  color: #9ca3af;
  font-size: 14px;
}

.item-table-container {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
}

/* 移动端表格优化 */
@media (max-width: 768px) {
  .item-table-container {
    padding: 8px;
  }

  /* 隐藏备注列，节省空间 */
  :deep(.el-table__body-wrapper) {
    overflow-x: auto;
  }
}

/* 移动端弹窗优化 */
@media (max-width: 768px) {
  :deep(.el-dialog) {
    margin-top: 5vh !important;
    margin-bottom: 5vh !important;
  }

  :deep(.el-dialog__header) {
    padding: 16px 20px;
  }

  :deep(.el-dialog__body) {
    padding: 20px;
  }

  :deep(.el-dialog__footer) {
    padding: 12px 20px;
  }

  :deep(.el-form-item__label) {
    font-size: 14px;
  }
}
</style>
