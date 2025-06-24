import { BasicConstants } from '../common/constants/BasicConstants'
import { PlayListModel, SongModel } from '../models/DataModels'
import { subWindow } from '../common/utils/SubWindowTool';
import { avPlayerManager } from '../common/utils/AVPlayerManager';
import { router } from '@kit.ArkUI';

@Extend(Image) function controlIcons(){
  .width(30)
  .height(30)
  .fillColor(Color.White)
}

@Entry
@Component
struct PlaySubWindow {
  @StorageProp('currentSong') currentSong: SongModel = new SongModel()
  @StorageProp('currentPlayList') currentPlayList:PlayListModel = new PlayListModel()

  build() {
    Stack({alignContent:Alignment.Top}){
      Image(this.currentSong.picUrl)
        .width(BasicConstants.FULL_WIDTH)
        .height(BasicConstants.FULL_HEIGHT)
        .blur(1000)
      Row({space:10}){
        Column() {
          Image(this.currentSong.picUrl)
            .width(45)
            .height(45)
            .borderRadius(400)
            .onClick(() => {
              //得先让子窗口失去焦点，https://developer.huawei.com/consumer/cn/doc/architecture-guides/news-v1_2-ts_1-0000002298237769
              subWindow.sub_windowClass?.setWindowFocusable(false)
                .then(()=>{
                  router.pushUrl({
                    url:'pages/Play',
                    params:{
                      param:this.currentSong
                    }
                  })
                })
            })
        }
        .backgroundImage($r("app.media.icon_cd"))
        .backgroundImageSize(ImageSize.Cover)
        .justifyContent(FlexAlign.Center)
        .width(60)
        .borderRadius(400)
        .clip(true)
        .aspectRatio(1)
        Row(){
          Text(`${this.currentSong.name} - ${this.currentSong.artistName}`)
            .fontColor($r('app.color.text_default'))
            .fontSize(BasicConstants.FONT_SIZE_NORMAL)
            .textOverflow({ overflow: TextOverflow.MARQUEE })
        }
        .layoutWeight(1)
        Row({space:5}){
          Image($r('app.media.icon_prev'))
            .controlIcons()
            .fillColor(this.currentPlayList.songs.length > 1 ? Color.White : $r('app.color.disabled'))
            .onClick(() => {
              avPlayerManager.playPrev()
            })
          Image(this.currentSong.isPlaying ? $r("app.media.icon_paused") : $r("app.media.icon_play"))
            .controlIcons()
            .onClick(()=>{
              this.currentSong.isPlaying ? avPlayerManager.paused() : avPlayerManager.playSong(this.currentSong)
            })
          Image($r('app.media.icon_next'))
            .controlIcons()
            .fillColor(this.currentPlayList.songs.length > 1 ? Color.White : $r('app.color.disabled'))
            .onClick(() => {
              avPlayerManager.playNext()
            })
          Image($r('app.media.icon_close'))
            .controlIcons()
            .onClick(()=>{
              subWindow.destroySubWindow()
            })
        }
      }
      .padding({right:5})
    }
    .borderRadius(400)
    .clip(true)
    .width(BasicConstants.FULL_WIDTH)
    .height(60)
  }
}