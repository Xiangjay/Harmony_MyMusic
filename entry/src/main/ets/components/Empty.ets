import {BasicConstants} from '../common/constants/BasicConstants'

@Component
export struct Empty {
  build() {
    Column(){
      Image($r('app.media.empty'))
        .width(230)
        .borderRadius(10)
      Text('敬请期待~')
        .fontSize(BasicConstants.FONT_SIZE_LARGE)
        .fontColor($r('app.color.text_default'))
        .margin({
          top:20
        })
    }
    .justifyContent(FlexAlign.Center)
    .width(BasicConstants.FULL_WIDTH)
    .height(BasicConstants.FULL_HEIGHT)
  }
}