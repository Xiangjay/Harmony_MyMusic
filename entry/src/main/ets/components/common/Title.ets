import { BasicConstants } from "../../common/constants/BasicConstants"

@Component
export struct Title {
  @State title:string = ''
  build() {
    Row(){
      Text(this.title)
        .fontColor($r('app.color.text_default'))
        .fontSize(BasicConstants.FONT_SIZE_LARGE)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(BasicConstants.FULL_WIDTH)
  }
}