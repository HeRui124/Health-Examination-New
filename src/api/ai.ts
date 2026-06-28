import request from './request'
import type { AxiosResponse } from 'axios'
import type { ApiResponse } from '@/types'

export interface ChatRequest {
  message: string
  chatId?: string
}

export interface ChatResponse {
  answer: string
  chatId: string
}

export function chat(data: ChatRequest) {
  return request
    .post<ApiResponse<ChatResponse>>('/api/ai/chat', data)
    .then((res: AxiosResponse<ApiResponse<ChatResponse>>) => res.data.data)
}
