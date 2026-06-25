import request from './request'
import type { ApiResponse, LoginResult } from '@/types'
import type { AxiosResponse } from 'axios'

export function login(data: { username: string; password: string }) {
  return request
    .post<ApiResponse<LoginResult>>('/api/auth/login', data)
    .then((res: AxiosResponse<ApiResponse<LoginResult>>) => res.data.data)
}

export function register(data: {
  username: string
  password: string
  realName: string
  phone?: string
  email?: string
  role: string
}) {
  return request
    .post<ApiResponse<void>>('/api/auth/register', data)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}
