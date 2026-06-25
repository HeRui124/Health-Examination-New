import request from './request'
import type { AxiosResponse } from 'axios'
import type { ApiResponse, PageData, Report, ReportItem } from '@/types'

// 查询当前用户的报告列表
export function getReportList(page = 1, size = 10) {
  return request.get<ApiResponse<PageData<Report>>>(`/api/report/list?page=${page}&size=${size}`)
    .then((res: AxiosResponse<ApiResponse<PageData<Report>>>) => res.data.data)
}

// 查询报告详情
export function getReportDetail(id: number) {
  return request.get<ApiResponse<Report>>(`/api/report/${id}`)
    .then((res: AxiosResponse<ApiResponse<Report>>) => res.data.data)
}

// 生成报告（直接发布）
export function generateReport(data: {
  userId: number
  appointmentId: number
  summary: string
  conclusion: string
}) {
  return request.post<ApiResponse<Report>>('/api/report/generate', data)
    .then((res: AxiosResponse<ApiResponse<Report>>) => res.data.data)
}

// 查看报告全部检查项目明细
export function getReportItemsAll(reportId: number) {
  return request.get<ApiResponse<ReportItem[]>>(`/api/report/${reportId}/items/all`)
    .then((res: AxiosResponse<ApiResponse<ReportItem[]>>) => res.data.data)
}

// 批量录入检查项目明细
export function batchCreateReportItems(reportId: number, items: Omit<ReportItem, 'id' | 'reportId'>[]) {
  return request.post<ApiResponse<void>>(`/api/report/${reportId}/items/batch`, items)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data.data)
}

// 修改报告（摘要/结论）
export function updateReport(id: number, data: {
  summary?: string
  conclusion?: string
}) {
  return request.put<ApiResponse<void>>(`/api/report/${id}`, data)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data.data)
}

// 修改检查项结果
export function updateReportItem(reportId: number, itemId: number, data: {
  examItemId?: number
  examItemName?: string
  result?: string
  referenceRange?: string
  abnormalFlag?: number
}) {
  return request.put<ApiResponse<void>>(`/api/report/${reportId}/items/${itemId}`, data)
    .then((res: AxiosResponse<ApiResponse<void>>) => res.data.data)
}
