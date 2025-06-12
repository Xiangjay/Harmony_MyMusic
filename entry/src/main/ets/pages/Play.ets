import { playListModel, routerParamsType, songModel,playMode} from '../../../backup/DataModel'
import { router } from '@kit.ArkUI'
import {getSingerDetailById} from '../common/apis/MusicApis'
import {responseSinger} from '../../../backup/DataModel'
import { BasicConstants } from '../common/constants/BasicConstants'
import { numberToTime } from '../common/utils/CommonTools'
import {avPlayerManager} from '../common/utils/AVPlayerManager'
import log from '@open/log'

@Entry
@Component
struct Play {
  private params = router.getParams()
  @StorageProp('currentSong') currentSong: songModel = new songModel()
  @StorageProp('currentPlayList') currentPlayList:playListModel = new playListModel()
  @State playIndex:number = 0
  //播放列表弹窗用
  @State playListHeight: string = '0%'
  @State playListOpacity: number = 0
  @State visible:Visibility = Visibility.None  //控制播放列表的遮罩层
  private animationDuration:number = 300

  //通过当前歌曲的歌手Id，获取歌手图片，这里如果是合唱的话默认显示第一位歌手图片
  getSingerById = async () =>{
    const singerId = this.currentSong.artists[0].id
    const res = await getSingerDetailById<responseSinger,null>(singerId)
    this.currentSong.showPic = res.data.artist.cover
  }
  aboutToAppear(): void {
    this.currentSong = (this.params as routerParamsType<songModel>).value
    this.playIndex = this.currentPlayList.songs.findIndex(song=>song.id === this.currentSong.id)
    if(!this.currentSong.showPic){  //如果没有专辑封面那就用歌手头像当歌曲图片
      this.getSingerById()
    }
    avPlayerManager.playSong(this.currentSong)
  }

  playPrev(){
    switch (this.currentPlayList.playMode) {
      case playMode.random: //随机模式
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
      case playMode.random: //随机模式
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
        this.currentSong = new songModel()
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

  @Builder
  deleteButton(index: number) {
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
          Image(this.currentSong.showPic)
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
      if(this.currentPlayList.playMode === playMode.auto){
        Image($r("app.media.icon_auto"))
          .fillColor(Color.White)
          .width(30)
          .onClick(()=>{
            this.currentPlayList.playMode = playMode.random
          })
      } else if(this.currentPlayList.playMode === playMode.random){
        Image($r("app.media.icon_random"))
          .fillColor(Color.White)
          .width(30)
          .onClick(()=>{
            this.currentPlayList.playMode = playMode.repeat
          })
      } else if(this.currentPlayList.playMode === playMode.repeat){
        Image($r("app.media.icon_repeat"))
          .fillColor(Color.White)
          .width(30)
          .onClick(()=>{
            this.currentPlayList.playMode = playMode.auto
          })
      }
      Image($r("app.media.icon_prev"))
        .fillColor(Color.White)
        .width(30)
        .onClick(()=>{
          this.playPrev()
          // avPlayerManager.playPrev()
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
        .fillColor(Color.White)
        .width(30)
        .onClick(()=>{
          if(this.currentPlayList.songs.length > 1){
            // this.playNext()
            this.playNext()
          }
        })
      //播放列表
      Image($r("app.media.icon_play_list"))
        .fillColor(Color.White)
        .width(30)
        .onClick(() => {
          this.visible = Visibility.Visible
          this.playListHeight = '60%'
          this.playListOpacity = 1
        })
    }
    .width('100%')
    .padding({
      bottom: 20
    })
    .justifyContent(FlexAlign.SpaceAround)
  }
  //歌单列表
  @Builder playListBuilder(){
    Column(){
      Column() {
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
                  .fontColor('#ffa49a9a')
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
                this.playListHeight = '0%'
                this.playListOpacity = 0
              })
          }
          .padding({
            left:15,
            right:15
          })
          .width(BasicConstants.FULL_WIDTH)
          .height(60)
          .alignItems(VerticalAlign.Center)
          .border({
            width: { bottom: 1 },
            color: '#12ec5c87'
          })
          .borderRadius({
            topLeft: 5,
            topRight: 5
          })
          // 播放列表
          List() {
            ForEach(this.currentPlayList.songs, (item: songModel, index: number) => {
              ListItem() {
                Row({space:10}) {
                  Row(){
                    if(item.id === this.currentSong.id){
                      Image($r('app.media.icon_playing'))
                        .width(20)
                        .fillColor($r('app.color.icon_svg_selected'))
                    }else{
                      Text((index + 1).toString())
                        .fontColor('#ffa49a9a')
                    }
                  }
                  .width(20)
                  Row() {
                    Column({ space: 5 }) {
                      Text(item.name)
                        .fontSize(BasicConstants.FONT_SIZE_SMALL)
                        .fontColor(item.id === this.currentSong.id ? $r('app.color.icon_svg_selected') : $r('app.color.text_default'))
                        .maxLines(1)
                        .textOverflow({overflow:TextOverflow.Ellipsis})
                      Text(item.showArtists.toString())
                        .fontSize(BasicConstants.FONT_SIZE_SMALL)
                        .fontColor(item.id === this.currentSong.id ? $r('app.color.icon_svg_selected') : '#ffa49a9a')
                        .maxLines(1)
                        .textOverflow({overflow:TextOverflow.Ellipsis})
                    }
                    .alignItems(HorizontalAlign.Start)
                    .justifyContent(FlexAlign.Center)
                  }
                  .onClick(()=>{
                    avPlayerManager.playSong(item)
                  })
                  .layoutWeight(1)
                  Row(){
                    Image($r('app.media.icon_add'))
                      .width(20)
                      .height(20)
                      .fillColor($r('app.color.icon_svg_selected'))
                  }
                }
                .height(50)
                .width(BasicConstants.FULL_WIDTH)
                .padding({
                  left:15,
                  right:15
                })
                .alignItems(VerticalAlign.Center)
              }
              .swipeAction({
                end: this.deleteButton(index)
              })
              .border({
                width: { bottom: 1 },
                color: '#12ec5c87'
              })
            })
          }
          .edgeEffect(EdgeEffect.None)
          .fadingEdge(true)
          .layoutWeight(1)
        }
      }
      .opacity(this.playListOpacity)
      .height(this.playListHeight)
      .animation({
        duration: this.animationDuration
      })
      .backgroundColor($r('app.color.content_background'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .onClick(()=>{
      this.playListHeight = '0%'
      this.playListOpacity = 0
    })
    .width(BasicConstants.FULL_WIDTH)
    .height(BasicConstants.FULL_HEIGHT)
    .opacity(this.playListOpacity)
    .animation({
      duration:this.animationDuration,
      onFinish:()=>{
       this.visible = this.playListOpacity === 1 ? Visibility.Visible : Visibility.None
      }
    })
    .visibility(this.visible)
    .justifyContent(FlexAlign.End)
    .backgroundColor('#32ffffff')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }){
      Stack({alignContent:Alignment.Top}){
        // 变色背景
        Image(this.currentSong.showPic)
          .width(BasicConstants.FULL_WIDTH)
          .height(BasicConstants.FULL_HEIGHT)
          .blur(1000)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        Column(){
          //封面
          this.coverImgBuilder()
          //歌曲信息
          Column({space:10}){
            Text(this.currentSong.name)
              .fontColor('#fcfcfc')
              .fontSize(BasicConstants.FONT_SIZE_LARGE)
            Text(this.currentSong.showArtists.toString())
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
        //返回按钮
        Row(){
          Image($r('app.media.icon_back'))
            .width(30)
            .height(30)
            .fillColor(Color.White)
            .margin({left:10})
            .onClick(()=>{
              router.back()
            })
        }
        .justifyContent(FlexAlign.Start)
        .width(BasicConstants.FULL_WIDTH)
      }
      this.playListBuilder()
    }
    .width(BasicConstants.FULL_WIDTH)
    .height(BasicConstants.FULL_HEIGHT)
  }
}