import {myHttp} from '../http/Http'

//获取搜索框默认搜索关键词
export function getDefaultKeywords<T,K>(){
  return myHttp<T,K>('/search/default')
}
/*
 * 推荐tab
*/
//获取推荐歌单
export function getRecommendPlayList<T,K>(){
  return myHttp<T,K>('/personalized')
}
//获取推荐MV
export function getRecommendMVList<T,K>(){
  return myHttp<T,K>('/personalized/mv')
}
//获取新歌推荐
export function getRecommendNewSongs<T,K>(){
  return myHttp<T,K>('/personalized/newsong?limit=10')
}
//获取推荐节目
export function getRecommendPrograms<T,K>(limit:number = 5){
  return myHttp<T,K>(`/program/recommend?limit=${limit}`)
}
/*
 * 最新tab
*/
//获取最新MV
export function getNewestMVList<T,K>(){
  return myHttp<T,K>('/mv/first?limit=5')
}
//获取新歌速递
export function getNewestSongs<T,K>(type:number = 7){
  return myHttp<T,K>(`/top/song?type=${type}`)
}
//获取最新专辑
export function getNewestAlbumsList<T,K>(){
  return myHttp<T,K>('/album/newest')
}
/*
 * 排行榜tab
*/
//获取所有排行榜
export function getAllRanks<T,K>(){
  return myHttp<T,K>(`/toplist`)
}

//获取排行榜tab里的歌手排行榜
export function getTopArtistList<T,K>(type:number = 1){
  return myHttp<T,K>(`/toplist/artist?type=${type}`)
}

//获取最新tab里的swiper
export function getMusicBanner<T,K>(){
  return myHttp<T,K>('/banner?type=1')
}
/*
 * 排行tab
*/
export function getAllPrograms<T,K>(){
  return myHttp<T,K>('/dj/program/toplist?limit=10')
}