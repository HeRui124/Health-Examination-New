import request from './request'
import type { AxiosResponse } from 'axios'
import type { ApiResponse, PageData, Institution } from '@/types'

// 查询已启用的机构列表（患者端）
export function getActiveInstitutions() {
  return request.get<ApiResponse<Institution[]>>(`/api/exam/institutions/active`)
    .then((res: AxiosResponse<ApiResponse<Institution[]>>) => res.data.data)
}

// 分页查询机构列表
export function getInstitutionList(page = 1, size = 10) {
  return request.get<ApiResponse<PageData<Institution>>>(`/api/exam/institutions?page=${page}&size=${size}`)
    .then((res: AxiosResponse<ApiResponse<PageData<Institution>>>) => res.data.data)
}

// 查询机构详情
export function getInstitutionDetail(id: number) {
  return request.get<ApiResponse<Institution>>(`/api/exam/institutions/${id}`)
    .then((res: AxiosResponse<ApiResponse<Institution>>) => res.data.data)
}

// 根据预约类型查询机构列表
export function getInstitutionsByAppointmentType(type: string) {
  return request.get<ApiResponse<Institution[]>>(`/api/exam/appointment-types/${type}/institutions`)
    .then((res: AxiosResponse<ApiResponse<Institution[]>>) => res.data.data)
}

// ==================== 机构管理（管理员） ====================

export function createInstitution(data: Partial<Institution>) {
  return request.post<ApiResponse<void>>('/api/exam/institutions', data)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}

export function updateInstitution(data: Partial<Institution>) {
  return request.put<ApiResponse<void>>('/api/exam/institutions', data)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}

export function deleteInstitution(id: number) {
  return request.delete<ApiResponse<void>>(`/api/exam/institutions/${id}`)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}
