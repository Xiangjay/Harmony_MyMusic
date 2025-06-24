import { LengthMetrics, PromptAction, router } from '@kit.ArkUI'
import { BasicConstants } from '../common/constants/BasicConstants'
import { numberToTime } from '../common/utils/CommonTools'
import {avPlayerManager} from '../common/utils/AVPlayerManager'
import { PlayListModel, routerParams, SongModel, PlayMode } from '../models/DataModels'
import { TopNavBar } from '../components/common/TopNavBar'
import { MyLazyDataSource } from "../common/utils/MyLazyDataSource";
import { playListDB } from '../db/playListDB'
import { relationalStore } from '@kit.ArkData'
import { SongListItem } from '../components/common/SongListItem'
import { subWindow } from '../common/utils/SubWindowTool'

//歌曲播放页面
@Entry
@Component
struct Play {
  @StorageProp('safeTop') safeTop: number = 0
  @StorageProp('windowHeight') windowHeight: number = 0;
  @StorageProp('windowWidth') windowWidth: number = 0
  @StorageProp('currentSong') currentSong: SongModel = new SongModel()
  @StorageProp('currentPlayList') currentPlayList:PlayListModel = new PlayListModel()
  @State playIndex:number = 0
  //播放列表弹窗用
  @State playListHeight: string = '0%'
  @State playListOpacity: number = 0
  @State showSongList:boolean = false
  @State visible:Visibility = Visibility.None  //控制播放列表的遮罩层
  private animationDuration:number = 300
  //懒加载数据
  private musicLazyData:MyLazyDataSource<SongModel> = new MyLazyDataSource()
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();  //提示弹窗


  aboutToAppear(): void {
    //进来时销毁播放小窗口
    if(subWindow.hasSubWindow){
      subWindow.destroySubWindow()
    }
    this.currentSong = (router.getParams() as routerParams<SongModel>).param
    this.playIndex = this.currentPlayList.songs.findIndex(song=>song.id === this.currentSong.id)
    //把数据放入懒加载数据类型中
    this.musicLazyData.pushAllData(this.currentPlayList.songs)
    if(this.currentSong.url){
      avPlayerManager.playSong(this.currentSong)
    }else {
      this.promptAction.showToast({
        message: '抱歉此歌无版权，暂不可播放',
        duration: 500
      })
      setTimeout(()=>{
        router.back()
      },1000)
    }
  }
  aboutToDisappear(): void {
    //离开时创建播放小窗口
    if(!subWindow.hasSubWindow){
      subWindow.createSubWindow('playSubWindow','pages/PlaySubWindow')
    }
  }

  playPrev(){
    switch (this.currentPlayList.playMode) {
      case PlayMode.random: //随机模式
        this.playIndex = Math.floor(Math.random() * this.currentPlayList.songs.length)
        break;
      default:  //自动播放模式和单曲循环模式时，当用户点击上一首和下一首是和自动播放模式一样的
        if(this.playIndex != 0){
          this.playIndex--
        }else{
          this.playIndex = this.currentPlayList.songs.length - 1
        }
        break;
    }
    this.currentSong = this.currentPlayList.songs[this.playIndex]
    avPlayerManager.playSong(this.currentSong)
  }
  playNext(){
    switch (this.currentPlayList.playMode) {
      case PlayMode.random: //随机模式
        this.playIndex = Math.floor(Math.random() * this.currentPlayList.songs.length)
        break;

      default:  //自动播放模式和单曲循环模式时，当用户点击上一首和下一首是和自动播放模式一样的
        if(this.playIndex !== this.currentPlayList.songs.length - 1){
          this.playIndex++
        }else{
          this.playIndex = 0
        }
        break;
    }
    this.currentSong = this.currentPlayList.songs[this.playIndex]
    avPlayerManager.playSong(this.currentSong)
  }
  changeSong = (index:number)=>{
    this.playIndex = index
    this.currentSong = this.currentPlayList.songs[this.playIndex]
    avPlayerManager.playSong(this.currentSong)
  }
  removeSong(index:number){
    if(this.playIndex === index){ //  删除的是正在播放的歌曲
      if(this.currentPlayList.songs.length > 1){ //  当前播放列表有多首歌曲
        this.currentPlayList.songs.splice(index,1)
        AppStorage.setOrCreate('currentPlayList',this.currentPlayList)  //修改后要重新存到全局
        //  删除完以后如果播放索引大于等于了当前播放列表长度，那么从第一首开始播放
        if(this.playIndex >= this.currentPlayList.songs.length){
          this.playIndex = 0
        }
        this.currentSong = this.currentPlayList.songs[this.playIndex]
        avPlayerManager.playSong(this.currentSong)
      } else{ //  当前播放列表只有一首歌曲，则重置数据和播放器
        this.currentSong = new SongModel()
        AppStorage.setOrCreate('currentSong',this.currentSong)
        avPlayerManager.reset()
      }
    }else {
      if(this.playIndex > index){ //  要删除的歌曲在正在播放的歌曲前面
        this.playIndex --
      }
      this.currentPlayList.songs.splice(index,1)
      AppStorage.setOrCreate('currentPlayList',this.currentPlayList)  //修改后要重新存到全局
    }
  }

  addSong2Local = async (song:SongModel)=>{
    //获取所有本地列表
    const myPlayLists = await playListDB.queryData('PLAYLIST')
    if(myPlayLists.length === 0){ //没有本地歌单，那么就弹窗提示
      this.getUIContext().showAlertDialog({
        title: '暂无本地歌单',
        message: '请先添加歌单/专辑到本地歌单，或者在个人中心新建歌单',
        autoCancel: true,
        primaryButton: {
          value: '取消',
          fontColor:$r('app.color.text_light'),
          action: () => {}
        },
        secondaryButton: {
          value: '去个人中心',
          fontColor:$r('app.color.edit'),
          action: () => {
            this.showSongList = false
            router.pushUrl({
              url:'pages/My'
            })
          }
        }
      })
      return
    }
    const playListNames:string[] = []
    myPlayLists.forEach(item=>{
      playListNames.push(item.name)
    })
    //选择本地歌单弹窗
    this.getUIContext().showTextPickerDialog({
      range: playListNames,
      selected: 0,
      canLoop: false,
      cancelButtonStyle:{fontColor:$r('app.color.disabled')},
      onAccept: async (value: TextPickerResult) => {
        const index = value.index as number //选择的索引
        //取出当前选择的歌单
        const resPlayList = await playListDB.queryData('PLAYLIST', undefined, myPlayLists[index].id)
        let selectedPlayList = resPlayList[0]
        //看看选择的歌单中是否已经有该歌曲
        const duplicated = selectedPlayList.songs.some(item=>item.id === song.id)
        if(duplicated){
          this.promptAction.showToast({
            message: '该歌单已有此歌曲',
            duration: BasicConstants.TOAST_DURATION
          })
          return
        }
        selectedPlayList.songs.unshift(song)  //把这首歌加进去
        const valueBucket: relationalStore.ValuesBucket = {
          SONGS:JSON.stringify(selectedPlayList.songs),
          SAVETIME: new Date().getTime()
        };
        const res = await playListDB.updateDataById('PLAYLIST',myPlayLists[index].id,valueBucket) //更新到数据库
        if(res.code === 0){ //成功
          this.promptAction.showToast({
            message: res.message,
            duration: BasicConstants.TOAST_DURATION
          })
        }else { //失败
          this.promptAction.showToast({
            message: res.message,
            duration: BasicConstants.TOAST_DURATION
          })
        }
      }
    });
  }

  @Builder deleteButton(index: number) {
    Button('删除')
      .backgroundColor('#ec5c87')
      .fontColor('#fff')
      .width(80)
      .height(BasicConstants.FULL_HEIGHT)
      .type(ButtonType.Normal)
      .onClick (()=>{
        this.removeSong(index)
        if(this.currentPlayList.songs.length === 0){ //如果当前没有歌单了则返回上一页
          router.back()
        }
      })
  }
  @Builder coverImgBuilder(){
    Stack({ alignContent: Alignment.Top }) {
      Row() {
        //CD背景图
        Row() {
          Image(this.currentSong.picUrl)
            .width('70%')
            .borderRadius(400)
        }
        .backgroundImage($r("app.media.icon_cd"))
        .backgroundImageSize(ImageSize.Cover)
        .justifyContent(FlexAlign.Center)
        .width(BasicConstants.FULL_WIDTH)
        .borderRadius(400)
        .clip(true)
        .aspectRatio(1)
      }
      .margin({top: 60})
      .width('90%')
      .aspectRatio(1)
      .justifyContent(FlexAlign.Center)
      .padding(20)
      // 唱针
      Image($r('app.media.ic_stylus'))
        .width(200)
        .aspectRatio(1)
        .rotate({
          angle: -55,
          centerX: 100,
          centerY: 30
        })
        .animation({
          duration: this.animationDuration
        })
    }
  }
  @Builder processBarBuilder(){
    Row({ space: 5 }) {
      Text(numberToTime(this.currentSong.time))
        .fontSize(BasicConstants.FONT_SIZE_XSMALL)
        .fontColor('#fcfcfc')
      Slider({
        value: this.currentSong.time,
        min: 0,
        max: this.currentSong.duration
      })
        .onChange((value:number)=>{
          avPlayerManager.seekPlay(value)
        })
        .layoutWeight(1)
        .blockColor(Color.White)
        .selectedColor(Color.White)
        .trackColor('#ccc5c5c5')
        .trackThickness(2)
      Text(numberToTime(this.currentSong.duration))
        .fontSize(BasicConstants.FONT_SIZE_XSMALL)
        .fontColor('#fcfcfc')
    }
    .width(BasicConstants.FULL_WIDTH)
    .padding(20)
  }
  @Builder playButtonsBuilder(){
    Row() {
      if(this.currentPlayList.playMode === PlayMode.auto){
        Image($r("app.media.icon_auto"))
          .fillColor(Color.White)
          .width(30)
          .onClick(()=>{
            this.currentPlayList.playMode = PlayMode.random
          })
      } else if(this.currentPlayList.playMode === PlayMode.random){
        Image($r("app.media.icon_random"))
          .fillColor(Color.White)
          .width(30)
          .onClick(()=>{
            this.currentPlayList.playMode = PlayMode.repeat
          })
      } else if(this.currentPlayList.playMode === PlayMode.repeat){
        Image($r("app.media.icon_repeat"))
          .fillColor(Color.White)
          .width(30)
          .onClick(()=>{
            this.currentPlayList.playMode = PlayMode.auto
          })
      }
      Image($r("app.media.icon_prev"))
        .fillColor(this.currentPlayList.songs.length > 1 ? Color.White : $r('app.color.disabled'))
        .width(30)
        .onClick(()=>{
          avPlayerManager.playPrev()
        })
      // 播放按钮
      Image(this.currentSong.isPlaying ? $r("app.media.icon_paused") : $r("app.media.icon_play"))
        .fillColor(Color.White)
        .width(50)
        .onClick(()=>{
          this.currentSong.isPlaying ? avPlayerManager.paused() : avPlayerManager.playSong(this.currentSong)
        })
      // 下一首
      Image($r("app.media.icon_next"))
        .fillColor(this.currentPlayList.songs.length > 1 ? Color.White : $r('app.color.disabled'))
        .width(30)
        .onClick(()=>{
          avPlayerManager.playNext()
        })
      //播放列表
      Image($r("app.media.icon_play_list"))
        .fillColor(Color.White)
        .width(30)
        .onClick(() => {
          this.showSongList = true
        })
        .bindSheet($$this.showSongList, this.songListBuilder(), {
          detents:[SheetSize.MEDIUM,SheetSize.LARGE],
          backgroundColor:$r('app.color.main_tab_background'),
          showClose:false,
          radius:{topStart:LengthMetrics.vp(10),topEnd:LengthMetrics.vp(10)}
        })
    }
    .width('100%')
    .padding({
      bottom: 20
    })
    .justifyContent(FlexAlign.SpaceAround)
  }
  @Builder songListBuilder(){
    Column() {
      //列表头
      Row({space:10}) {
        Image($r("app.media.icon_play"))
          .width(25)
          .fillColor($r('app.color.icon_svg_selected'))
        Row() {
          Text(){
            Span('播放列表 ')
              .fontColor($r('app.color.text_default'))
              .fontSize(BasicConstants.FONT_SIZE_NORMAL)
            Span(`(${this.currentPlayList.songs.length})`)
              .fontColor($r('app.color.text_light'))
              .fontSize(BasicConstants.FONT_SIZE_SMALL)
          }
        }
        .margin({left:5})
        .layoutWeight(1)
        Image($r("app.media.icon_arrow_down"))
          .fillColor('#ffa49a9a')
          .width(25)
          .height(25)
          .onClick(() => {
            this.showSongList = false
          })
      }
      .width(BasicConstants.FULL_WIDTH)
      .height(60)
      .alignItems(VerticalAlign.Center)
      .border({
        width: { bottom: 1 },
        color:$r('app.color.list_divider')
      })
      .padding({
        left:10,
        right:10
      })
      // 播放列表
      List() {
        LazyForEach(this.musicLazyData, (item: SongModel, index: number) => {
          ListItem() {
            SongListItem({song:item,currentSongId:this.currentSong.id,index:index,playList:this.currentPlayList,changeSong:this.changeSong,addSong2Local:this.addSong2Local})
            // Row({space:10}) {
            //   Row(){
            //     if(item.id === this.currentSong.id){
            //       Image($r('app.media.icon_playing'))
            //         .width(20)
            //         .fillColor($r('app.color.icon_svg_selected'))
            //     }else{
            //       Text((index + 1).toString())
            //         .fontColor($r('app.color.text_light'))
            //     }
            //   }
            //   .width(30)
            //   Row() {
            //     Column({ space: 5 }) {
            //       Text(item.name)
            //         .fontSize(BasicConstants.FONT_SIZE_SMALL)
            //         .fontColor(item.id === this.currentSong.id ? $r('app.color.icon_svg_selected') : $r('app.color.text_default'))
            //         .maxLines(1)
            //         .textOverflow({overflow:TextOverflow.Ellipsis})
            //       Text(item.artistName.toString())
            //         .fontSize(BasicConstants.FONT_SIZE_SMALL)
            //         .fontColor(item.id === this.currentSong?.id ? $r('app.color.icon_svg_selected') : $r('app.color.text_light'))
            //         .maxLines(1)
            //         .textOverflow({overflow:TextOverflow.Ellipsis})
            //     }
            //     .alignItems(HorizontalAlign.Start)
            //     .justifyContent(FlexAlign.Center)
            //   }
            //   .onClick(()=>{
            //     this.changeSong(index)
            //   })
            //   .layoutWeight(1)
            //   Row(){
            //     Image($r('app.media.icon_add'))
            //       .width(20)
            //       .height(20)
            //       .fillColor($r('app.color.icon_svg_selected'))
            //       .onClick(()=>{
            //         this.addSong2Local(item)
            //       })
            //   }
            // }
            // .padding({
            //   left:10,
            //   right:10
            // })
            // .height(60)
            // .width(BasicConstants.FULL_WIDTH)
            // .alignItems(VerticalAlign.Center)
          }
          .swipeAction({
            end: this.deleteButton(index)
          })
          .border({
            width: { bottom: 1 },
            color:$r('app.color.list_divider')
          })
        },(item:SongModel)=>item.id.toString())
      }
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
      .fadingEdge(true)
      .layoutWeight(1)
    }
    .width(BasicConstants.FULL_WIDTH)
    .padding({
      left:10,
      right:10
    })
  }

  build() {
    Stack({alignContent:Alignment.Top}){
      // 变色背景
      Image(this.currentSong.picUrl)
        .width(BasicConstants.FULL_WIDTH)
        .height(BasicConstants.FULL_HEIGHT)
        .blur(1000)
      Column(){
        //返回按钮
        Row(){
          TopNavBar({color:'#ffffff'})
        }
        .width(BasicConstants.FULL_WIDTH)
        .padding({left:10})
        Column(){
          //封面
          this.coverImgBuilder()
          //歌曲信息
          Column({space:10}){
            Text(this.currentSong.name)
              .fontColor('#fcfcfc')
              .fontSize(BasicConstants.FONT_SIZE_LARGE)
            Text(this.currentSong.artistName.toString())
              .fontColor('#fcfcfc')
              .fontSize(BasicConstants.FONT_SIZE_NORMAL)
          }
          .margin({top:20})
          .width(BasicConstants.FULL_WIDTH)
          .padding({left:20,right:20})

          Column() {
            //进度条
            this.processBarBuilder()
            //播放按钮
            this.playButtonsBuilder()
          }
          .width(BasicConstants.FULL_WIDTH)
        }
      }
      .padding({
        top:this.safeTop
      })
    }
    .width(BasicConstants.FULL_WIDTH)
    .height(BasicConstants.FULL_HEIGHT)
  }
}