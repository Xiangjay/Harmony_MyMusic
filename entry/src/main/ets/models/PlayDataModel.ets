//程序需要的歌曲列表数据类型
@ObservedV2
export class localPlayListModel{
  @Trace id:number = 0
  @Trace name?:string
  @Trace songs:songModel[] = []
  @Trace picUrl?:string
  @Trace playMode:playMode = playMode.auto //播放模式
}
//程序需要的歌曲数据类型
@ObservedV2
export class songModel{
  @Trace id:number = 0 //歌曲Id
  @Trace name:string = ''  //歌曲名字
  @Trace url:string = ''   //播放地址
  @Trace artists:Array<artist> = []  //歌手
  @Trace showArtists:string[] = []   //页面展示用的歌手
  @Trace showPic?:string     //用于播放音乐时展示的图片
  @Trace album?: album   //所属专辑
  @Trace isPlaying:boolean = false //播放状态
  @Trace time:number = 0   //当前播放时间
  @Trace duration:number = 0   //歌曲总时长
}
//播放模式
export enum playMode{
  auto = 0,
  random = 1,
  repeat = 2
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