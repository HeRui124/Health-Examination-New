import request from './request'
import type { AxiosResponse } from 'axios'
import type { ApiResponse, InstitutionPackage } from '@/types'

// 查询某机构已关联的套餐列表
export function getInstitutionPackages(institutionId: number) {
  return request.get<ApiResponse<InstitutionPackage[]>>(`/api/exam/institution-packages?institutionId=${institutionId}`)
    .then((res: AxiosResponse<ApiResponse<InstitutionPackage[]>>) => res.data.data)
}

// 新增机构-套餐关联
export function createInstitutionPackage(data: { institutionId: number; packageId: number }) {
  return request.post<ApiResponse<void>>('/api/exam/institution-packages', data)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}

// 删除机构-套餐关联
export function deleteInstitutionPackage(id: number) {
  return request.delete<ApiResponse<void>>(`/api/exam/institution-packages/${id}`)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}
