import {myHttp} from '../http/Http'
//MV页面用，用于拿到该地区的所有MV，并返回5个MV
export function getAllMV<T,K>(area:string){
  return myHttp<T,K>(`/mv/all?area=${encodeURI(area)}&limit=5`)
}
//通过MVid获取MV详细信息
export function getMvDetailById<T,K>(mvId:number){
  return myHttp<T,K>(`/mv/detail?mvid=${mvId}`)
}
//通过MVid获取MV点赞数
export function getMvInfoById<T,K>(mvId:number){
  return myHttp<T,K>(`/mv/detail/info?mvid=${mvId}`)
}
//通过MVid获取MV播放地址
export function getMvUrlById<T,K>(mvId:number){
  return myHttp<T,K>(`/mv/url?id=${mvId}`)
}