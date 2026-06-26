import request from './request'
import type { AxiosResponse } from 'axios'
import type { ApiResponse, PageData, ExamPackage, ExamItem } from '@/types'

// 分页查询套餐列表
export function getPackageList(page = 1, size = 10) {
  return request.get<ApiResponse<PageData<ExamPackage>>>(`/api/exam/packages?page=${page}&size=${size}`)
    .then((res: AxiosResponse<ApiResponse<PageData<ExamPackage>>>) => res.data.data)
}

// 查询套餐详情
export function getPackageDetail(id: number) {
  return request.get<ApiResponse<ExamPackage>>(`/api/exam/packages/${id}`)
    .then((res: AxiosResponse<ApiResponse<ExamPackage>>) => res.data.data)
}

// 根据机构查询套餐列表（返回数组，非分页）
export function getPackagesByInstitution(institutionId: number) {
  return request.get<ApiResponse<ExamPackage[]>>(`/api/exam/institutions/${institutionId}/packages`)
    .then((res: AxiosResponse<ApiResponse<ExamPackage[]>>) => res.data.data)
}

// ==================== 套餐管理（管理员） ====================

export function createPackage(data: Partial<ExamPackage>) {
  return request.post<ApiResponse<void>>('/api/exam/packages', data)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}

export function updatePackage(data: Partial<ExamPackage>) {
  return request.put<ApiResponse<void>>('/api/exam/packages', data)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}

export function togglePackageStatus(id: number, status: number) {
  return request.put<ApiResponse<void>>(`/api/exam/packages/${id}/status?status=${status}`)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}

export function deletePackage(id: number) {
  return request.delete<ApiResponse<void>>(`/api/exam/packages/${id}`)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}
