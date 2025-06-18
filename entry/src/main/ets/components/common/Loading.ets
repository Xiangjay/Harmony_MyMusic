import { BasicConstants } from "../../common/constants/BasicConstants"

@Component
export struct Loading {
  @Prop showIcon:boolean = true

  build() {
    Row() {
      if(this.showIcon){
        LoadingProgress()
          .color('#91ee91')
          .width(50).height(50)
        Text('努力加载中......')
          .fontSize(BasicConstants.FONT_SIZE_NORMAL)
          .fontColor('#91ee91')
      }
    }
  }
}