import { BasicConstants } from "../common/constants/BasicConstants"
import { avPlayerManager } from "../common/utils/AVPlayerManager"
import { playListModel, songModel } from "../models/DataModel"
import { router } from "@kit.ArkUI"

@Component
export struct PlayList {
  @StorageProp('currentSong') currentSong: songModel = new songModel()
  @StorageProp('currentPlayList') currentPlayList:playListModel = new playListModel()
  @Link playIndex:number
  //播放列表弹窗用
  @State panelHeight: string = '0%'
  @State panelOpacity: number = 0
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
  build() {
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
          .layoutWeight(1)
          Image($r("app.media.icon_arrow_down"))
            .fillColor('#ffa49a9a')
            .width(25)
            .height(25)
            .onClick(() => {
              this.panelHeight = '0%'
              this.panelOpacity = 0
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
              .onClick(()=>{
                avPlayerManager.playSong(item)
              })
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
    .height(this.panelHeight)
    .animation({
      duration: 300
    })
    .backgroundColor($r('app.color.content_background'))
    .opacity(this.panelOpacity)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}