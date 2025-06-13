import {myHttp} from '../http/Http'
//通过歌单id获取歌单详细信息
export function getAllMV<T,K>(area:string){
  return myHttp<T,K>(`/mv/all?area=${encodeURI(area)}&limit=5`)
}