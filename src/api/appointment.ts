import request from './request'
import type { AxiosResponse } from 'axios'
import type { ApiResponse, PageData, Appointment } from '@/types'

// 查询当前用户的预约列表
// 注意：PATIENT 角色返回 Appointment[] 数组，DOCTOR/ADMIN 返回 PageData 分页对象
export function getAppointmentList(page = 1, size = 10): Promise<PageData<Appointment>> {
  return request.get<ApiResponse<PageData<Appointment> | Appointment[]>>(`/api/exam/appointments?page=${page}&size=${size}`)
    .then((res: AxiosResponse<ApiResponse<PageData<Appointment> | Appointment[]>>) => {
      const data = res.data.data
      if (Array.isArray(data)) {
        // PATIENT：后端直接返回数组，统一包装为 PageData 格式
        return { total: data.length, page: 1, size: data.length, records: data }
      }
      return data as PageData<Appointment>
    })
}

// 查询预约详情
export function getAppointmentDetail(id: number) {
  return request.get<ApiResponse<Appointment>>(`/api/exam/appointments/${id}`)
    .then((res: AxiosResponse<ApiResponse<Appointment>>) => res.data.data)
}

// 新增预约（userId 由后端从 Token 自动获取）
export function createAppointment(data: {
  packageId: number
  institutionId?: number
  appointmentDate: string
  timeSlot?: string
  remark?: string
}) {
  return request.post<ApiResponse<Appointment>>(`/api/exam/appointments`, data)
    .then((res: AxiosResponse<ApiResponse<Appointment>>) => res.data.data)
}

// 取消预约
export function cancelAppointment(id: number) {
  return request.put<ApiResponse<void>>(`/api/exam/appointments/${id}/cancel`)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data.data)
}

// 标记体检完成
export function completeAppointment(id: number) {
  return request.put<ApiResponse<void>>(`/api/exam/appointments/${id}/complete`)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data.data)
}
