import request from './request'
import type { AxiosResponse } from 'axios'
import type { ApiResponse, Doctor } from '@/types'

export function getDoctorDetail(id: number) {
  return request.get<ApiResponse<Doctor>>(`/api/user/doctors/${id}`)
    .then((res: AxiosResponse<ApiResponse<Doctor>>) => res.data.data)
}
