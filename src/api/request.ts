import axios, { type AxiosInstance, type AxiosError, type InternalAxiosRequestConfig, type AxiosResponse } from 'axios'
import type { ApiResponse } from '@/types'

// 创建 axios 实例
const request: AxiosInstance = axios.create({
  baseURL: '',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
})

// 请求拦截器：自动注入 Token
request.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = localStorage.getItem('accessToken')
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error: AxiosError) => {
    return Promise.reject(error)
  }
)

// 响应拦截器：统一处理错误
request.interceptors.response.use(
  (response: AxiosResponse<ApiResponse<unknown>>) => {
    const res = response.data as ApiResponse<unknown>
    if (res.code !== 200) {
      // 业务错误，抛出异常让调用方处理
      return Promise.reject(new Error(res.message || '请求失败'))
    }
    return response
  },
  (error: AxiosError) => {
    let msg = '网络错误'
    if (error.response) {
      const status = error.response.status
      switch (status) {
        case 401:
          msg = '登录已过期，请重新登录'
          // 可以在这里处理登出逻辑
          localStorage.removeItem('accessToken')
          break
        case 403:
          msg = '没有权限执行此操作'
          break
        case 404:
          msg = '请求的资源不存在'
          break
        case 500:
          msg = '服务器内部错误'
          break
        default:
          msg = `请求失败 (${status})`
      }
    } else if (error.request) {
      msg = '无法连接到服务器，请检查网络'
    }
    return Promise.reject(new Error(msg))
  }
)

export default request
