import {myHttp} from '../http/Http'
//通过歌单id获取歌单详细信息
export function getSongListDetailById<T,K>(id:number){
  return myHttp<T,K>(`/playlist/detail?id=${id}`)
}
//通过歌单id获取歌单里所有歌曲详细信息
export function getSongListSongsById<T,K>(id:number){
  return myHttp<T,K>(`/playlist/track/all?id=${id}`)
}
//通过歌曲id获取歌曲播放url
export function getSongUrlByIds<T,K>(songIds:number[]){
  return myHttp<T,K>(`/song/url?id=${songIds}`)
}
//通过歌曲id获取歌曲详细信息，这里主要为了拿歌曲时长
export function getSongDetailByIds<T,K>(songIds:number[]){
  return myHttp<T,K>(`/song/detail?ids=${songIds}`)
}
//通过歌手id获取歌手详细信息
export function getSingerDetailById<T,K>(singerId:number){
  return myHttp<T,K>(`/artist/detail?id=${singerId}`)
}
//通过专辑id获取专辑详细信息
export function getAlbumDetailById<T,K>(albumId:number){
  return myHttp<T,K>(`/album?id=${albumId}`)
}
//通过专辑id获取专辑动态信息
export function getAlbumDynamicById<T,K>(albumId:number){
  return myHttp<T,K>(`/album/detail/dynamic?id=${albumId}`)
}
//通过歌单或专辑id获取评论
export function getCommentsById<T,K>(type:string,id:number){
  return myHttp<T,K>(`/comment/${type}?id=${id}`)
}
