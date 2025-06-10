@Observed
export class globalMusic{
  id:number = 0 //歌曲Id
  name:string = ''  //歌曲名字
  url:string = ''   //播放地址
  artists:Array<artist> = []  //歌手
  showArtists:string[] = []   //页面展示用的歌手
  showPic?:string     //用于播放音乐时展示的图片
  album?: album   //所属专辑
  time:number = 0   //当前播放时间
  duration:number = 0   //歌曲总时长
  isPlay: boolean = false  //  播放状态
  //  播放列表，这里注意，程序需要有个播放列表，用来播放上一首和下一首，播放的时候从播放列表里找需要播放的歌曲，播放列表需要放在当前播放歌曲里
  playIndex:number = 0   //  当前播放索引
  playList:songModel[] = []  //  播放列表
}

export class songModel{
  id:number = 0 //歌曲Id
  name:string = ''  //歌曲名字
  url:string = ''   //播放地址
  artists:Array<artist> = []  //歌手
  showArtists:string[] = []   //页面展示用的歌手
  showPic?:string     //用于播放音乐时展示的图片
  album?: album   //所属专辑
  time:number = 0   //当前播放时间
  duration:number = 0   //歌曲总时长
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