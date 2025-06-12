import { BasicConstants } from "../../common/constants/BasicConstants"

@Component
export struct Loading {
  build() {
    Row() {
      Image($r('app.media.loading'))
        .width(50)
      Text('努力加载中......')
        .fontSize(BasicConstants.FONT_SIZE_NORMAL)
        .fontColor('#91ee91')
        .margin({ right: 10 })
    }
    .clip(true)
    .borderRadius(5)
    .backgroundColor('#ffffff')
  }
}