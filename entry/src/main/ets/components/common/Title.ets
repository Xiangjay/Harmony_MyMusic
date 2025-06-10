import { BasicConstants } from "../../common/constants/BasicConstants"

@Component
export struct Title {
  @State title:string = ''
  build() {
    Text(this.title)
      .fontColor($r('app.color.text_default'))
      .fontSize(BasicConstants.FONT_SIZE_LARGE)
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Start)
      .width(BasicConstants.FULL_WIDTH)
  }
}