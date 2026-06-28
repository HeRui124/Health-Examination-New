import request from './request'
import type { AxiosResponse } from 'axios'
import type { ApiResponse } from '@/types'

export interface FileUploadVO {
  objectKey: string
  fileUrl: string
  fileSize: number
  contentType: string
}

export function uploadFile(file: File) {
  const formData = new FormData()
  formData.append('file', file)
  return request
    .post<ApiResponse<FileUploadVO>>('/api/file/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    .then((res: AxiosResponse<ApiResponse<FileUploadVO>>) => res.data.data)
}
