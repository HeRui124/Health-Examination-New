import request from './request'
import type { AxiosResponse } from 'axios'
import type { ApiResponse, PageData, ExamItem } from '@/types'

// 查询检查项目列表
export function getExamItemList(packageId: number, page = 1, size = 10) {
  return request.get<ApiResponse<PageData<ExamItem>>>(`/api/exam/packages/${packageId}/items?page=${page}&size=${size}`)
    .then((res: AxiosResponse<ApiResponse<PageData<ExamItem>>>) => res.data.data)
}

// 查询检查项目详情
export function getExamItemDetail(packageId: number, id: number) {
  return request.get<ApiResponse<ExamItem>>(`/api/exam/packages/${packageId}/items/${id}`)
    .then((res: AxiosResponse<ApiResponse<ExamItem>>) => res.data.data)
}

// 新增检查项目
export function createExamItem(packageId: number, data: Partial<ExamItem>) {
  return request.post<ApiResponse<void>>(`/api/exam/packages/${packageId}/items`, data)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}

// 更新检查项目
export function updateExamItem(packageId: number, id: number, data: Partial<ExamItem>) {
  return request.put<ApiResponse<void>>(`/api/exam/packages/${packageId}/items/${id}`, data)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}

// 删除检查项目
export function deleteExamItem(packageId: number, id: number) {
  return request.delete<ApiResponse<void>>(`/api/exam/packages/${packageId}/items/${id}`)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data)
}
