import { media } from "@kit.MediaKit";
import { playListModel, songModel,playMode} from '../../models/DataModel'

export class AVPlayerManager{
  //音频播放器
  private audioPlayer: media.AVPlayer | null = null

  // currentSong:songModel = new songModel()
  currentSong:songModel = AppStorage.get('currentSong')!

  //初始化音乐播放器并监听播放状态
  async initAudioPlayer(){
    //初始化播放器的时候先全局存一个当前歌曲
    AppStorage.setOrCreate<songModel>('currentSong',new songModel())
    if(!this.audioPlayer){
      this.audioPlayer = await media.createAVPlayer()
    }
    //监听播放器状态
    this.audioPlayer.on('stateChange',(state:string)=>{
      if(state === 'initialized'){
        this.audioPlayer?.prepare()
      } else if(state === 'prepared'){
        this.audioPlayer?.play()
        this.currentSong.isPlaying = true
      } else if(state === 'completed'){ //当一首歌播放结束时，要根据播放模式选择下一首要播放的歌曲
        const currentPlayList:playListModel = AppStorage.get('currentPlayList')!  //先从全局拿当前播放列表
        switch (currentPlayList.playMode) {
          case playMode.random: //随机模式
            let playIndex:number = Math.floor(Math.random() * currentPlayList.songs.length)
            this.playSong(currentPlayList.songs[playIndex])
            break;
          case playMode.repeat: //重新播放当前歌曲
            this.audioPlayer?.play()
            break;
          default:  //自动模式
            const currentIndex = currentPlayList.songs.findIndex(song=>song.id === this.currentSong.id)
            if(currentIndex !== currentPlayList.songs.length - 1){
              this.changeSong(currentPlayList.songs[currentIndex+1])
            }else{
              this.changeSong(currentPlayList.songs[0])
            }
            break;
        }
      } else if(state === 'released'){
        // this.currentSong.reset()
      }
    })
    //监听时长变化
    this.audioPlayer.on('durationUpdate',(duration)=>{
      this.currentSong.duration = duration
    })
    //播放时监听播放时间
    this.audioPlayer.on('timeUpdate',(time)=>{
      this.currentSong.time = time
    })
  }

  //播放歌曲
  async playSong(song:songModel){
    this.currentSong = AppStorage.get('currentSong')!   //先从全局拿正在播放的currentSong
    if(song.id === this.currentSong.id){  //要播放的歌曲就是当前currentSong，那就继续播放
      this.audioPlayer?.play()
      this.currentSong.isPlaying = true
    }else {
      this.changeSong(song)
    }
  }
  //  切换歌曲
  async changeSong(song:songModel){
    this.currentSong = song
    this.currentSong.isPlaying = true
    AppStorage.setOrCreate<songModel>('currentSong',this.currentSong) //全局保存正在播放的歌曲
    await this.audioPlayer?.reset()  // 切换歌曲需要先重置播放器
    this.audioPlayer!.url = song.url
  }

  //调整播放进度
  seekPlay(value:number){
    this.audioPlayer?.seek(value)
  }
  //  暂停播放
  paused(){
    this.audioPlayer?.pause()
    this.currentSong.isPlaying = false
  }

  //重置播放器
  reset(){
    this.audioPlayer?.reset()
  }
}

export const avPlayerManager = new AVPlayerManager()