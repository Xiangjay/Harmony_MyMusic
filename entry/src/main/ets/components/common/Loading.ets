import { BasicConstants } from "../../common/constants/BasicConstants"

@Component
export struct Loading {
  @Prop showIcon:boolean = true

  build() {
    Row() {
      if(this.showIcon){
        LoadingProgress()
          .color($r('app.color.edit'))
          .width(50).height(50)
        Text($r('app.string.loading'))
          .fontSize(BasicConstants.FONT_SIZE_NORMAL)
          .fontColor($r('app.color.edit'))
      }
    }
  }
}