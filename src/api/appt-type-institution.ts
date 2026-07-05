import request from './request'
import type { AxiosResponse } from 'axios'
import type { ApiResponse, ApptTypeInstitution } from '@/types'

// 查询某机构已关联的预约类型列表
export function getApptTypeInstitutions(institutionId: number) {
  return request.get<ApiResponse<ApptTypeInstitution[]>>(`/api/exam/appt-type-institutions?institutionId=${institutionId}`)
    .then((res: AxiosResponse<ApiResponse<ApptTypeInstitution[]>>) => res.data.data)
}

// 新增预约类型-机构关联
export function createApptTypeInstitution(data: { institutionId: number; apptType: string }) {
  return request.post<ApiResponse<void>>('/api/exam/appt-type-institutions', data)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}

// 删除预约类型-机构关联
export function deleteApptTypeInstitution(id: number) {
  return request.delete<ApiResponse<void>>(`/api/exam/appt-type-institutions/${id}`)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}
