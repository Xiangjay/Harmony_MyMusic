import { media } from "@kit.MediaKit";
import {SongModel,PlayListModel,PlayMode} from '../../models/DataModels'
import { aVSessionManger } from "./AVSessionManager";
import log from '@open/log'

export class AVPlayerManager{
  //音频播放器
  private audioPlayer: media.AVPlayer | null = null

  currentSong:SongModel = AppStorage.get('currentSong')!

  //初始化音乐播放器并监听播放状态
  async initAudioPlayer(){
    //初始化播放器的时候先全局存一个当前歌曲
    AppStorage.setOrCreate<SongModel>('currentSong',new SongModel())
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
        const currentPlayList:PlayListModel = AppStorage.get('currentPlayList')!  //先从全局拿当前播放列表
        switch (currentPlayList.playMode) {
          case PlayMode.random: //随机模式
            let playIndex:number = Math.floor(Math.random() * currentPlayList.songs.length)
            this.playSong(currentPlayList.songs[playIndex])
            break;
          case PlayMode.repeat: //重新播放当前歌曲
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
        this.currentSong = new SongModel()
        AppStorage.setOrCreate('currentSong',this.currentSong)
      }
    })
    //监听时长变化
    this.audioPlayer.on('durationUpdate',(duration)=>{
      this.currentSong.duration = duration
      //设置播控数据元数据
      // aVSessionManger.setAVMetadata(this.currentSong)
    })
    //播放时监听播放时间
    this.audioPlayer.on('timeUpdate',(time)=>{
      this.currentSong.time = time
      aVSessionManger.setAVPlayBackState(this.currentSong,AppStorage.get('currentPlayList')!)  //设置播控中心播放状态
    })
  }

  //播放歌曲
  async playSong(song:SongModel){
    aVSessionManger.startBackgroundTask() //申请长时任务
    this.currentSong = AppStorage.get('currentSong')!   //先从全局拿正在播放的currentSong
    aVSessionManger.setAVPlayBackState(song,AppStorage.get('currentPlayList')!)  //设置播控中心播放状态
    if(song.id === this.currentSong?.id){  //要播放的歌曲就是当前currentSong，那就继续播放
      this.audioPlayer?.play()
      this.currentSong.isPlaying = true
    }else {
      this.changeSong(song)
    }
  }
  //  切换歌曲
  async changeSong(song:SongModel){
    this.currentSong = song
    this.currentSong.isPlaying = true
    AppStorage.setOrCreate<SongModel>('currentSong',this.currentSong) //全局保存正在播放的歌曲
    await this.audioPlayer?.reset()  // 切换歌曲需要先重置播放器
    this.audioPlayer!.url = song.url
    //设置播控数据元数据
    aVSessionManger.setAVMetadata(this.currentSong)
  }

  //调整播放进度
  seekPlay(value:number){
    this.audioPlayer?.seek(value)
  }
  //  暂停播放
  paused(){
    this.audioPlayer?.pause()
    this.currentSong.isPlaying = false
    aVSessionManger.setAVPlayBackState(this.currentSong,AppStorage.get('currentPlayList')!)  //设置播控中心播放状态
  }

  //上一首
  playPrev(){
    const currentPlayList:PlayListModel = AppStorage.get('currentPlayList')!
    let playIndex:number = currentPlayList.songs.findIndex(song=>song.id === this.currentSong.id)
    switch (currentPlayList.playMode) {
      case PlayMode.random: //随机模式
        playIndex = Math.floor(Math.random() * currentPlayList.songs.length)
        break;
      default:  //自动播放模式和单曲循环模式时，当用户点击上一首和下一首是和自动播放模式一样的
        if(playIndex != 0){
          playIndex--
        }else{
          playIndex = currentPlayList.songs.length - 1
        }
        break;
    }
    this.currentSong = currentPlayList.songs[playIndex]
    this.playSong(this.currentSong)
    // this.playSong(currentPlayList.songs[playIndex])
  }
  //下一首
  playNext(){
    const currentPlayList:PlayListModel = AppStorage.get('currentPlayList')!
    let playIndex:number = currentPlayList.songs.findIndex(song=>song.id === this.currentSong.id)
    switch (currentPlayList.playMode) {
      case PlayMode.random: //随机模式
        playIndex = Math.floor(Math.random() * currentPlayList.songs.length)
        break;
      default:  //自动播放模式和单曲循环模式时，当用户点击上一首和下一首是和自动播放模式一样的
        if(playIndex !== currentPlayList.songs.length - 1){
          playIndex++
        }else{
          playIndex = 0
        }
        break;
    }
    this.currentSong = currentPlayList.songs[playIndex]
    this.playSong(this.currentSong)
    // this.playSong(currentPlayList.songs[playIndex])
  }
  //重置播放器
  reset(){
    this.audioPlayer?.reset()
  }
  //注销播放器
  async release(){
    await this.audioPlayer?.release()
  }
}

export const avPlayerManager = new AVPlayerManager()