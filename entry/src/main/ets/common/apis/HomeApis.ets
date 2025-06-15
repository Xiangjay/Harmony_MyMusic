import {myHttp} from '../http/Http'

//获取搜索框默认搜索关键词
export function getDefaultKeywords<T,K>(){
  return myHttp<T,K>('/search/default')
}
//获取推荐tab里的推荐歌单
export function getRecommendSongList<T,K>(){
  return myHttp<T,K>('/personalized')
}
//获取推荐tab里的推荐MV
export function getRecommendMVList<T,K>(){
  return myHttp<T,K>('/personalized/mv')
}
//获取推荐tab里的新歌推荐
export function getRecommendNewSongs<T,K>(){
  return myHttp<T,K>('/personalized/newsong?limit=10')
}
//获取推荐tab里的推荐电台
export function getRecommendDjPrograms<T,K>(){
  return myHttp<T,K>('/personalized/djprogram')
}
//获取最新tab里最新MV列表
export function getNewestMVList<T,K>(){
  return myHttp<T,K>('/mv/first?limit=5')
}
//获取最新tab里最新专辑列表
export function getNewestAlbumsList<T,K>(){
  return myHttp<T,K>('/album/newest')
}

//获取排行榜tab里的歌手排行榜
export function getTopArtistList<T,K>(type:number = 1){
  return myHttp<T,K>(`/toplist/artist?type=${type}`)
}

//获取最新tab里的swiper
export function getMusicBanner<T,K>(){
  return myHttp<T,K>('/banner?type=1')
}