import {BasicConstants} from '../common/constants/BasicConstants'
import { router } from '@kit.ArkUI'

@Component
export struct Empty {
  @Prop message:string = '敬请期待~'
  @Prop isPage:boolean = true
  build() {
    RelativeContainer(){
      if (this.isPage){
        //返回按钮
        Image($r('app.media.icon_back'))
          .width(30)
          .height(30)
          .margin({left:10})
          .onClick(()=>{
            console.log('111')
            router.back()
          })
          .alignRules({
            'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
            'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
          })
      }
      Column(){
        Image($r('app.media.empty'))
          .width(230)
          .borderRadius(10)
        Text(this.message)
          .fontSize(BasicConstants.FONT_SIZE_LARGE)
          .fontColor($r('app.color.text_default'))
          .margin({
            top:20
          })
      }
      .alignRules({
        'center': { 'anchor': '__container__', 'align': VerticalAlign.Center },
        'middle': { 'anchor': '__container__', 'align': HorizontalAlign.Center }
      })
    }
    .width(BasicConstants.FULL_WIDTH)
    .height(BasicConstants.FULL_HEIGHT)
  }
}