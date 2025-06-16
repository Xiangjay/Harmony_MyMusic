import { BasicConstants } from "../../common/constants/BasicConstants"

@Component
export struct Loading {
  @Prop showIcon:boolean = true

  build() {
    Row() {
      if(this.showIcon){
        Image($r('app.media.loading'))
          .width(50)
      }
      Text('努力加载中......')
        .fontSize(BasicConstants.FONT_SIZE_NORMAL)
        .fontColor('#91ee91')
    }
    .clip(true)
    .borderRadius(5)
    .backgroundColor(this.showIcon ? '#ffffff' : Color.Transparent)
  }
}