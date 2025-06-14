import { router } from '@kit.ArkUI'
import { BasicConstants } from '../../common/constants/BasicConstants'

@Component
export struct TopNavBar {
  @Prop title:string
  @Prop color:ResourceStr = $r('app.color.back_icon')

  build() {
    Row(){
      Row({space:5}) {
        Image($r('app.media.icon_back'))
          .width(30)
          .height(30)
          .fillColor(this.color)
          .onClick(() => {
            router.back()
          })
        Text(this.title)
          .fontColor(this.color)
          .fontSize(BasicConstants.FONT_SIZE_LARGE)
          .fontWeight(FontWeight.Bold)
      }
      .justifyContent(FlexAlign.Start)
      .width(BasicConstants.FULL_WIDTH)
    }
  }
}