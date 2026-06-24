import request from './request'
import type { AxiosResponse } from 'axios'
import type { ApiResponse, PageData, DictItem } from '@/types'

// 根据字典类型查询字典项列表
export function getDictItemsByType(typeId: number) {
  return request.get<ApiResponse<PageData<DictItem>>>(`/api/system/dict-items/by-type/${typeId}?page=1&size=20`)
    .then((res: AxiosResponse<ApiResponse<PageData<DictItem>>>) => res.data.data)
}
