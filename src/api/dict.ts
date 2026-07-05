import request from './request'
import type { AxiosResponse } from 'axios'
import type { ApiResponse, PageData, DictType, DictItem } from '@/types'

// ==================== 字典类型管理 ====================

// 分页查询字典类型列表
export function getDictTypeList(page = 1, size = 10) {
  return request.get<ApiResponse<PageData<DictType>>>(`/api/system/dict-types?page=${page}&size=${size}`)
    .then((res: AxiosResponse<ApiResponse<PageData<DictType>>>) => res.data.data)
}

// 查询字典类型详情
export function getDictTypeById(id: number) {
  return request.get<ApiResponse<DictType>>(`/api/system/dict-types/${id}`)
    .then((res: AxiosResponse<ApiResponse<DictType>>) => res.data.data)
}

// 新增字典类型
export function createDictType(data: Partial<DictType>) {
  return request.post<ApiResponse<void>>('/api/system/dict-types', data)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}

// 更新字典类型
export function updateDictType(data: Partial<DictType>) {
  return request.put<ApiResponse<void>>('/api/system/dict-types', data)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}

// 删除字典类型
export function deleteDictType(id: number) {
  return request.delete<ApiResponse<void>>(`/api/system/dict-types/${id}`)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}

// ==================== 字典项管理 ====================

// 根据字典类型ID分页查询字典项列表
export function getDictItemsByType(typeId: number, page = 1, size = 20) {
  return request.get<ApiResponse<PageData<DictItem>>>(`/api/system/dict-items/by-type/${typeId}?page=${page}&size=${size}`)
    .then((res: AxiosResponse<ApiResponse<PageData<DictItem>>>) => res.data.data)
}

// 查询字典项详情
export function getDictItemById(id: number) {
  return request.get<ApiResponse<DictItem>>(`/api/system/dict-items/${id}`)
    .then((res: AxiosResponse<ApiResponse<DictItem>>) => res.data.data)
}

// 新增字典项
export function createDictItem(data: Partial<DictItem>) {
  return request.post<ApiResponse<void>>('/api/system/dict-items', data)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}

// 更新字典项
export function updateDictItem(data: Partial<DictItem>) {
  return request.put<ApiResponse<void>>('/api/system/dict-items', data)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}

// 删除字典项
export function deleteDictItem(id: number) {
  return request.delete<ApiResponse<void>>(`/api/system/dict-items/${id}`)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}
