import { MyLazyDataSource } from "../common/utils/MyLazyDataSource"

//路由参数类型
export class routerParams<T>{
  param:T
  constructor(param:T) {
    this.param = param
  }
}
export class musicRouterParamsModel{
  id:number = 0
  type:PlayListType = PlayListType.playList
}
export class commentsRouterParamsModel{
  id:number = 0
  type:PlayListType = PlayListType.playList
  detail:PlayListModel = new PlayListModel()
}
export class mvRouterParamsModel{
  index:number = 0
  mvList:Array<MVModel> = []
}

export enum PlayListType{
  playList = 'playlist',
  album = 'album',
  local = 'local',
  singer = 'singer',
  dj = 'dj'
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
  description:string = ''
  tags:string[] = []
  commentCount:number = 0
  shareCount:number = 0
  artist:Artist = new Artist() //专辑用
  publishTime:number = 0 //专辑用
  updateFrequency:string = '' //排行榜用
  saveTime?:number = 0 //个人中心用
}

//程序需要的歌曲数据类型
@Observed
export class SongModel{
  id:number = 0 //歌曲Id
  name:string = ''  //歌曲名字
  url:string = ''   //播放地址
  picUrl:string = ''     //用于播放音乐时展示的图片
  artists:Array<Artist> = []  //歌手
  artistName:string[] = []   //页面展示用的歌手
  album: Album = new Album()   //所属专辑
  isPlaying:boolean = false //播放状态
  time:number = 0   //当前播放时间
  duration:number = 0   //歌曲总时长
  saveTime?:number = 0 //个人中心用
}
export class responseSingerDetail{
  identify:identify = {imageDesc:''}
  artist:Artist = new Artist()
  songs:Array<SongModel> = []
  fansCnt:number = 0
}
interface identify{
  imageDesc:string
}
//排行榜tab里页面需要展示的的歌手排行榜数据类型
export interface areaSongs{
  area:string,
  songs: Array<SongModel>
}
//新歌推荐后台返回的数据类型
export class RecommendSongModel{
  id:number = 0 //歌曲Id
  name:string = ''  //歌曲名字
  url:string = ''   //播放地址
  picUrl:string = ''
  duration:number = 0   //歌曲总时长
  song:SongModel = new SongModel()
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
  picUrl:string = ''
  briefDesc:string = ''
  albumSize:number = 0
  musicSize:number = 0
  fansCnt:number = 0
}
//专辑
export class Album{
  id:number = 0
  name:string = ''
  picUrl:string = ''
  publishTime:number = 0
}


/*
 * 推荐tab
*/
//默认搜索关键词
export interface SearchKeyWordInterface {
  showKeyword: string;
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

/*
 * 排行榜tab
*/
//排行榜tab里歌手数据
export class topArtistsModel{
  name:string = ''
  id: number = 0
  picUrl:string = ''
  albumSize:number = 0
  musicSize: number = 0
  score:number = 0
}
//后台返回的数据类型
export interface responseTopArtistsList{
  artists: Array<topArtistsModel>
}
//排行榜tab里页面需要展示的的歌手排行榜数据类型
export interface areaTopArtists{
  area:string,
  artists: Array<topArtistsModel>
}

//后台返回的评论数据类型，为了拿到more
export class responseComments{
  more:boolean = true
  comments:Array<commentsModel> = []
}
//评论数据
export class commentsModel{
  commentId:number = 0
  content:string = ''
  time:number = 0
  user:commentsUser = new commentsUser()
  likedCount:number = 0
}
//评论的用户
export class commentsUser{
  userId:number = 0
  nickname:string = ''
  avatarUrl:string = ''
}

/*
 * MV tab
*/
@Observed
export class MVModel{
  id:number = 0
  name:string = ''
  cover:string = ''
  playCount:number = 0
  briefDesc:string = ''
  duration:number = 0
  artistName:string = ''
  artistId:number = 0
  artistAvatar:string = ''
  shareCount:number = 0
  commentCount:number = 0
  publishTime:number = 0
  likedCount:number = 0
  url:string = ''
  picUrl:string = ''  //推荐页面用
  copywriter:string = ''  //推荐页面用
  //以下为播放页面用
  isPlaying?:boolean = false //是否在播放
  controller?:VideoController = new VideoController() //视频播放的控制器
  showPlayButton?:boolean = false  //是否现在视频中间的播放按钮，播放按钮要单独控制，不要跟isPlaying绑定
  liked?:boolean = false
  comments?:Array<commentsModel> = []
  commentsLazyData?:MyLazyDataSource<commentsModel> = new MyLazyDataSource()  //评论懒加载数据
  showComments?:boolean = false
  saveTime?:number = 0
}
//mv拿用户数据用
export interface responseArtistModel{
  artist:Artist
}

//自定义数据库增删改查返回的数据类型
export interface DataBaseResponseModel{
  code:number //0代表成功，1代表失败，-1代表没有数据库
  message:string
}

//排行榜数据类型，排行榜也是歌单的一种
@Observed
export class RankModel{
  id:number = 0
  name:string = ''
  updateFrequency:string = ''
  coverImgUrl:string = ''
  description:string = ''
  songs:SongModel[] = []
}

//节目数据类型
export class ProgramModel{
  id:number = 0
  name:string = ''
  description:string = ''
  coverUrl:string = ''
  duration:number = 0
  likedCount:number = 0
  shareCount:number = 0
  commentCount:number = 0
  mainSong:SongModel = new SongModel()
  songs:Array<SongModel> = []
}
//节目榜数据类型
export interface allProgramsModel{
  program:ProgramModel
}