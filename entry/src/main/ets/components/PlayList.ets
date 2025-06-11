import { BasicConstants } from "../common/constants/BasicConstants"
import { avPlayerManager } from "../common/utils/AVPlayerManager"
import { playListModel, songModel } from "../models/DataModel"
import { router } from "@kit.ArkUI"

@Component
export struct PlayList {
  @Prop playList:playListModel
  @Prop closable:boolean = false
  @StorageProp('currentSong') currentSong: songModel = new songModel()
  //播放列表弹窗用
  @Prop playListHeight: string = '0%'
  @Prop playListOpacity: number = 0
  @State visible:Visibility = Visibility.None  //控制播放列表的遮罩层
  private animationDuration:number = 300

  @Builder
  deleteButton(index: number) {
    Button('删除')
      .backgroundColor('#ec5c87')
      .fontColor('#fff')
      .width(80)
      .height(BasicConstants.FULL_HEIGHT)
      .type(ButtonType.Normal)
      .onClick (()=>{

      })
  }
  build() {

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
                Span(`(${this.playList.songs.length})`)
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
            ForEach(this.playList.songs, (item: songModel, index: number) => {
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
}