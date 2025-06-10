//路由参数类型
export class routerParamsType<T>{
  value:T
  constructor(value:T) {
    this.value = value
  }
}

//默认搜索关键词
export interface SearchKeyWordInterface {
  showKeyword: string;
}

/*
 * 推荐tab
*/
//精选歌单
export interface recommendSongList {
  id:number,
  type:number,
  name:string,
  picUrl:string,
  playCount:number,
  trackCount:number
}
//精选MV
export interface recommendMVList {
  id:number,
  type:number,
  copywriter:string,
  picUrl:string,
  playCount:number,
  artistName:string,
  artistId:number
}
//新歌推荐
export interface recommendNewSongs {
  id:number,
  name:string,
  picUrl:string,
  song:recommendNewSongsSong,
  artists:Array<string>  //这个返回的数据没有，为了页面展示用
}
//新歌推荐里的数据
export interface recommendNewSongsSong{
  artists:Array<albumArtist>,
  album:newestAlbum
}
//推荐电台
export interface recommendDjProgram{
  name:string,
  id: number,
  type: string,
  picUrl:string,
  copywriter:string,
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
export interface newestAlbum{
  name:string,
  id: number,
  type: string,
  siz: number,
  picUrl:string,
  publishTime:number
  artist:albumArtist
}
//最新专辑里的歌手
export interface albumArtist {
  name:string,
  id:number,
  picUrl:string,
  albumSize:number
}
//最新MV
export interface newestMV{
  name:string,
  id: number,
  playCount:number,
  cover:string,
  artistName:string
}

/*
 * 排行榜tab
*/
//排行榜tab里歌手数据
export interface topArtist{
  name:string,
  id: number,
  picUrl:string,
  albumSize:number,
  musicSize: number,
  score:number
}
//从后台获取歌手排行榜返回的数据格式
export interface topArtistsList{
  artists:Array<topArtist>
}
//排行榜tab里需要的的歌手排行榜数据
export interface areaTopArtists{
  area:string,
  artists: Array<topArtist>
}

/*
 * 音乐页面
 * 需要先通过歌单ID获取歌单详情，然后需要拿到歌单详情里的所有歌曲ID(trackId)，然后才能得到歌曲播放地址
*/
//获取歌单详情返回的数据格式
export class responseSongList{
  id:number = 0
  name:string = ''
  ar: Array<artist> = []
  al?:album
}
export class artist{
  id:number = 0
  name:string = ''
}
export class album{
  id:number = 0
  name:string = ''
  picUrl?:string
}
//页面需要的歌曲列表数据类型
// @Observed
export class playListModel{
  id:number = 0
  name?:string
  songs:songModel[] = []
  picUrl?:string
  playMode:playMode = playMode.auto //播放模式
}
//程序需要的歌曲数据类型
// @Observed
export class songModel{
  id:number = 0 //歌曲Id
  name:string = ''  //歌曲名字
  url:string = ''   //播放地址
  artists:Array<artist> = []  //歌手
  showArtists:string[] = []   //页面展示用的歌手
  showPic?:string     //用于播放音乐时展示的图片
  album?: album   //所属专辑
  isPlaying:boolean = false //播放状态
  time:number = 0   //当前播放时间
  duration:number = 0   //歌曲总时长
}
//播放模式
export enum playMode{
  auto = 0,
  random = 1,
  repeat = 2
}
//通过歌曲ID从后台返回的歌曲格式，主要是为了拿到url
export interface responseSongUrl{
  id:number,
  url:string,
  time:number
}
//通过歌手ID从后台返回的数据格式，主要为了拿歌手的图片，用于播放歌曲时展示
export interface responseSinger{
  artist:singer
}
export interface singer{
  id:number,
  name:string,
  cover:string,
  avatar:string
}

export interface responseSongDetail{
  songs:Array<songDetail>
}
export interface songDetail{
  id:number,
  name:string,
  dt:number,
  al:album
}