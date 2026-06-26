import request from './request'
import type { ApiResponse, LoginResult, User, PageData } from '@/types'
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

// ==================== 用户管理（管理员） ====================

export function getUserList(page = 1, size = 10, keyword = '') {
  let url = `/api/auth/users?page=${page}&size=${size}`
  if (keyword) url += `&keyword=${encodeURIComponent(keyword)}`
  return request.get<ApiResponse<PageData<User>>>(url)
    .then((res: AxiosResponse<ApiResponse<PageData<User>>>) => res.data.data)
}

export function getUserDetail(id: number) {
  return request.get<ApiResponse<User>>(`/api/auth/users/${id}`)
    .then((res: AxiosResponse<ApiResponse<User>>) => res.data.data)
}

export function updateUser(id: number, data: Partial<User>) {
  return request.put<ApiResponse<void>>(`/api/auth/users/${id}`, data)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}

export function updateUserStatus(id: number, status: number) {
  return request.put<ApiResponse<void>>(`/api/auth/users/${id}/status?status=${status}`)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}

export function resetUserPassword(id: number, newPassword: string) {
  return request.put<ApiResponse<void>>(`/api/auth/users/${id}/reset-password?newPassword=${newPassword}`)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}

export function deleteUser(id: number) {
  return request.delete<ApiResponse<void>>(`/api/auth/users/${id}`)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}
