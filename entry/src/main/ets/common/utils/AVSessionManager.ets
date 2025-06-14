import { avSession } from '@kit.AVSessionKit'
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager'
import { wantAgent } from '@kit.AbilityKit';
// import { PlayListModel, SongModel,PlayMode } from '../../../../backup/DataModel';
import {SongModel,PlayListModel,PlayMode} from '../../models/DataModels'
import { avPlayerManager } from './AVPlayerManager';

class AVSessionManger{
  avSession:avSession.AVSession | null = null

  //初始化
  async initAvSession(context:Context){
    this.avSession = await avSession.createAVSession(context, 'bgAudio', 'audio')
    this.registerEvent()
  }

  //申请后台长时任务
  async startBackgroundTask(){
    //固定写法，https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/avsession-access-scene
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: "com.example.mymusic",
          abilityName: "EntryAbility"
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG],
    };
    const want = await wantAgent.getWantAgent(wantAgentInfo)
    await backgroundTaskManager.startBackgroundRunning(getContext(),backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK,want)
  }

  //设置元数据
  setAVMetadata(song:SongModel){
    //播控中心显示的图片、名称等
    this.avSession?.setAVMetadata({
      assetId:song.id.toString(),
      title:song.name,
      mediaImage:song.showPic,
      artist:song.showArtists.toString(),
      duration:song.duration
    })
  }
  //设置播放状态
  setAVPlayBackState(song:SongModel,currentPlayList:PlayListModel){
    //可以简单理解为播控中心里的播放器，在AVPlayer播放、暂停时调用
    let aVSessionPlayMode:avSession.LoopMode
    //把当前播放列表传进来，同步当前播放模式给播控中心
    switch (currentPlayList.playMode) {
      case PlayMode.random:
        aVSessionPlayMode = avSession.LoopMode.LOOP_MODE_SHUFFLE
        break;
      case PlayMode.repeat:
        aVSessionPlayMode = avSession.LoopMode.LOOP_MODE_SINGLE
        break;
      default:
        aVSessionPlayMode = avSession.LoopMode.LOOP_MODE_LIST
        break;
    }
    this.avSession?.setAVPlaybackState({
      state: song.isPlaying ? avSession.PlaybackState.PLAYBACK_STATE_PLAY : avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      position:{
        elapsedTime:song.time,
        updateTime:new Date().getTime()
      },
      duration:song.duration,
      loopMode:aVSessionPlayMode
    })
  }
  //注册事件
  registerEvent(){
    this.avSession?.on('play',()=>{
      let currentSong:SongModel = AppStorage.get('currentSong')!
      avPlayerManager.playSong(currentSong)
    })
    this.avSession?.on('pause',()=>{
      avPlayerManager.paused()
    })
    this.avSession?.on('seek',(value:number)=>{
      avPlayerManager.seekPlay(value)
    })
    this.avSession?.on('playPrevious',()=>{
      avPlayerManager.playPrev()
    })
    this.avSession?.on('playNext',()=>{
      avPlayerManager.playNext()
    })
    this.avSession?.on('setLoopMode',(mode:avSession.LoopMode)=>{
      /*
       *LOOP_MODE_SEQUENCE	0	顺序播放。
        LOOP_MODE_SINGLE	1	单曲循环。
        LOOP_MODE_LIST	2	表单循环。
        LOOP_MODE_SHUFFLE	3	随机播放。
        LOOP_MODE_CUSTOM	4	自定义播放。
      */
      let currentPlayList:PlayListModel = AppStorage.get('currentPlayList')!
      switch (mode) {
        case 1:
          currentPlayList.playMode = PlayMode.auto
          break;
        case 3:
          currentPlayList.playMode = PlayMode.repeat
          break;
        default: currentPlayList.playMode = PlayMode.random
          break;
      }
      //同步当前播放模式给全局
      AppStorage.setOrCreate('currentPlayList',currentPlayList)
    })
    this.avSession?.off('toggleFavorite')
    this.avSession?.activate()
  }
  //注销
  async destroy(){
    await this.avSession?.destroy()
  }
}

export const aVSessionManger:AVSessionManger = new AVSessionManger()