import { BasicConstants } from '../../common/constants/BasicConstants'
import { countTransform } from '../../common/utils/CommonTools'
import { MVModel } from '../../models/DataModels'

@Extend(Text) function infoText(size:number = BasicConstants.FONT_SIZE_NORMAL,color:ResourceColor = Color.White) {
  .fontSize(size)
  .fontColor(color)
}

@Component
export struct MvContent {
  @ObjectLink @Watch('watchMv')mv:MVModel

  watchMv(){  //通过watch监听isPlaying属性的变化
    this.mv.isPlaying ? this.mv.controller?.start() : this.mv.controller?.pause()
  }

  @Builder rightButtonsBuilder(mv:MVModel){
    Column({space:20}){
      Column({space:5}){
        Image($r('app.media.icon_dianzan'))
          .width(30)
          .fillColor(Color.White)
        Text(countTransform(mv.playCount))
          .infoText(BasicConstants.FONT_SIZE_SMALL)
      }
      Column({space:5}){
        Image($r('app.media.icon_comment'))
          .width(30)
          .fillColor(Color.White)
        Text(countTransform(mv.commentCount))
          .infoText(BasicConstants.FONT_SIZE_SMALL)
      }
      Column({space:5}){
        Image($r('app.media.icon_share'))
          .width(30)
          .fillColor(Color.White)
        Text(countTransform(mv.shareCount))
          .infoText(BasicConstants.FONT_SIZE_SMALL)
      }
    }
    .padding({right:10})
    .alignRules({
      'top': { 'anchor': '__container__', 'align': VerticalAlign.Center },
      'right': { 'anchor': '__container__', 'align': HorizontalAlign.End }
    })
  }
  @Builder bottomInfoBuilder(mv:MVModel){
    Column({space:10}){
      Row({space:5}){
        Image(mv.artistAvatar)
          .width(40)
          .borderRadius(50)
        Text(mv.artistName)
          .infoText()
      }
      .width(BasicConstants.FULL_WIDTH)
      .alignItems(VerticalAlign.Center)
      Row({space:5}){
        Row(){
          Text('MV')
            .infoText()
        }
        .padding(5)
        .backgroundColor('#3a3e41')
        Text(mv.name)
          .infoText()
      }
      .width(BasicConstants.FULL_WIDTH)
      .alignItems(VerticalAlign.Center)
      Text(mv.publishTime)
        .infoText(BasicConstants.FONT_SIZE_SMALL,'#a9a9a9')
        .width(BasicConstants.FULL_WIDTH)
    }
    .padding({
      left:20,
      bottom:20
    })
    .width('80%')
    .alignRules({
      'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
      'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
    })
  }
  build() {
    RelativeContainer(){
      Video({
        src: this.mv.url,
        controller: this.mv.controller
      })
        .autoPlay(this.mv.isPlaying)
        .objectFit(ImageFit.Contain)
        .loop(false)
        .controls(false)
        .width(BasicConstants.FULL_WIDTH)
        .height(BasicConstants.FULL_HEIGHT)
        .alignRules({
          'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
          'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
        })
        .onClick(()=>{
          if(this.mv.isPlaying){
            this.mv.isPlaying = false
            this.mv.showPlayButton = true
          }else{
            this.mv.isPlaying = true
            this.mv.showPlayButton = false
          }
        })
      //右侧按钮
      this.rightButtonsBuilder(this.mv)
      //底部MV信息
      this.bottomInfoBuilder(this.mv)
      //播放按钮
      if(this.mv.showPlayButton){
        Image($r('app.media.icon_play'))
          .width(80)
          .height(80)
          .alignRules({
            'center': { 'anchor': '__container__', 'align': VerticalAlign.Center },
            'middle': { 'anchor': '__container__', 'align': HorizontalAlign.Center }
          })
          .onClick(()=>{
            this.mv.isPlaying = true
            this.mv.showPlayButton = false
          })
      }
    }
    .width(BasicConstants.FULL_WIDTH)
    .height(BasicConstants.FULL_HEIGHT)
  }
}