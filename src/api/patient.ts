import request from './request'
import type { AxiosResponse } from 'axios'
import type { ApiResponse, Patient } from '@/types'

// 查询患者详情
export function getPatientDetail(id: number) {
  return request.get<ApiResponse<Patient>>(`/api/user/patients/${id}`)
    .then((res: AxiosResponse<ApiResponse<Patient>>) => res.data.data)
}

// 更新患者档案
export function updatePatientDetail(id: number, data: Partial<Patient>) {
  return request.put<ApiResponse<Patient>>(`/api/user/patients/${id}`, data)
    .then((res: AxiosResponse<ApiResponse<Patient>>) => res.data.data)
}
