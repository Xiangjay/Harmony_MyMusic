import { BasicConstants } from "../../common/constants/BasicConstants";

@CustomDialog
@Component
export struct EditDialog {
  @Prop playListName:string = '' //这里如果用@Link接收会闪退
  controller?: CustomDialogController;  //不能删，会报错
  private confirm = (name:string)=>{} //这里要把改后的结果通过参数传回去
  private cancel = ()=>{}

  build() {
    Column({space:10}) {
      Text('歌单名称')
        .fontSize(BasicConstants.FONT_SIZE_NORMAL)
        .fontColor($r('app.color.text_default'))
        .width(BasicConstants.FULL_WIDTH)
        .textAlign(TextAlign.Start)
        .margin({ top:20 })
      TextInput({text: $$this.playListName })
      Row() {
        Button('取消')
          .onClick(() => {
            this.cancel()
          })
          .backgroundColor(Color.Transparent)
          .fontColor($r('app.color.disabled'))
        Divider()
          .vertical(true)
        Button('确认')
          .enabled(this.playListName !== '')
          .onClick(() => {
            this.confirm(this.playListName);
          })
          .backgroundColor(Color.Transparent)
          .fontColor($r('app.color.edit'))
      }
      .height(40)
      .width(BasicConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: 10 })
    }
    .width('90%')
  }
}