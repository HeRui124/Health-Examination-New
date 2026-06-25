// ==================== 通用响应类型 ====================

export interface ApiResponse<T> {
  code: number
  message: string
  data: T
}

export interface PageData<T> {
  total: number
  page: number
  size: number
  records: T[]
}

// ==================== 字典项相关 ====================

export interface DictItem {
  id: number
  dictTypeId: number
  label: string
  value: string
  sortOrder: number
  status: number
}

// ==================== 用户相关 ====================

export type UserRole = 'ADMIN' | 'DOCTOR' | 'PATIENT'

export interface User {
  id: number
  username: string
  realName: string
  phone?: string
  email?: string
  avatar?: string
  role: UserRole
  status: number
}

export interface LoginResult {
  accessToken: string
  refreshToken: string
  expiresIn: number
}

export interface Patient {
  id: number
  userId: number
  name: string
  gender: number
  birthday?: string
  idCard?: string
  address?: string
  emergencyContact?: string
  emergencyPhone?: string
}

export interface Doctor {
  id: number
  userId: number
  packageId?: number
  department?: string
  title?: string
  specialty?: string
  introduction?: string
}

// ==================== 套餐相关 ====================

export interface ExamPackage {
  id: number
  name: string
  price: number
  description?: string
  status: number
  sortOrder: number
  items?: ExamItem[]
}

// ==================== 机构相关 ====================

export interface Institution {
  id: number
  name: string
  address?: string
  phone?: string
  businessHours?: string
  description?: string
  status: number
  sortOrder: number
}

// ==================== 检查项目相关 ====================

export interface ExamItem {
  id: number
  packageId: number
  name: string
  type?: string
  description?: string
  sortOrder: number
}

// ==================== 预约相关 ====================

export type AppointmentStatus = 0 | 1 | 2 | 3
export type AppointmentStatusText = '待确认' | '已确认' | '已取消' | '已完成'

export interface Appointment {
  id: number
  userId: number
  packageId: number
  institutionId?: number
  appointmentDate: string
  timeSlot?: string
  status: AppointmentStatus
  remark?: string
}

export interface AppointmentVO extends Appointment {
  packageName?: string
  institutionName?: string
}

// ==================== 报告相关 ====================

export type ReportStatus = 0 | 1 | 2
export type ReportStatusText = '草稿' | '已生成' | '已发布'

export interface Report {
  id: number
  userId: number
  appointmentId?: number
  doctorId?: number
  summary?: string
  conclusion?: string
  status: ReportStatus
  generateTime?: string
}

export interface ReportItem {
  id: number
  reportId: number
  examItemId?: number
  examItemName?: string
  result?: string
  referenceRange?: string
  abnormalFlag: number
}
