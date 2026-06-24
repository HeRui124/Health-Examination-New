import request from './request'
import type { ApiResponse, LoginResult } from '@/types'
import type { AxiosResponse } from 'axios'

export function login(data: { username: string; password: string }) {
  return request
    .post<ApiResponse<LoginResult>>('/api/auth/login', data)
    .then((res: AxiosResponse<ApiResponse<LoginResult>>) => res.data.data)
}
