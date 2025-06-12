//路由参数类型
export class routerParamsType<T>{
  value:T
  constructor(value:T) {
    this.value = value
  }
}

//程序需要的歌单数据类型
@Observed
export class PlayListModel{
  id:number = 0
  name:string = ''
  songs:SongModel[] = []
  picUrl:string = ''
  playMode:PlayMode = PlayMode.auto //播放模式
  playCount:number = 0
  trackCount:number = 0
  description:string = ''
  tags:string[] = []
  subscribedCount:number = 0
  shareCount:number = 0
}

//程序需要的歌曲数据类型
@Observed
export class SongModel{
  id:number = 0 //歌曲Id
  name:string = ''  //歌曲名字
  url:string = ''   //播放地址
  artists:Array<Artist> = []  //歌手
  showArtists:string[] = []   //页面展示用的歌手
  showPic:string = ''     //用于播放音乐时展示的图片
  album: Album = new Album()   //所属专辑
  isPlaying:boolean = false //播放状态
  time:number = 0   //当前播放时间
  duration:number = 0   //歌曲总时长
  song?:newSong = new newSong()  //单独给新歌推荐用
}
//单独给新歌推荐用，为了拿到歌手数据
class newSong {
  artists:Array<Artist> = []
}
//播放模式
export enum PlayMode{
  auto = 0,
  random = 1,
  repeat = 2
}
//歌手
export class Artist{
  id:number = 0
  name:string = ''
}
//专辑
export class Album{
  id:number = 0
  name:string = ''
  picUrl:string = ''
}

/*
 * 推荐tab
*/
//默认搜索关键词
export interface SearchKeyWordInterface {
  showKeyword: string;
}
//精选MV
export class recommendMVList {
  id:number = 0
  type:number = 0
  picUrl:string = ''
  playCount:number = 0
  artistName:string = ''
  artistId:number = 0
  copywriter:string = ''
}
//推荐电台
export class recommendDjProgram{
  name:string = ''
  id: number = 0
  type: number = 0
  picUrl:string = ''
}

/*
 * 最新tab
*/
//swiper
export interface banner{
  bannerId:string,
  pic:string,
  typeTitle:string
}
//最新专辑
export class newestAlbum{
  name:string = ''
  id: number = 0
  type: string = ''
  size: number = 0
  picUrl:string = ''
  publishTime:number = 0
  artist:Artist = new Artist()
}
//最新MV
export class newestMV{
  name:string = ''
  id: number = 0
  playCount:number = 0
  cover:string = ''
  artistName:string = ''
}

/*
 * 排行榜tab
*/
//排行榜tab里歌手数据
export class topArtists{
  name:string = ''
  id: number = 0
  picUrl:string = ''
  albumSize:number = 0
  musicSize: number = 0
  score:number = 0
}
export interface topArtistsList{
  artists:Array<topArtists>
}