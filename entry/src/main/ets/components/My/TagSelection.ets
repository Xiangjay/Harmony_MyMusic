import { BasicConstants } from "../../common/constants/BasicConstants"

interface Tag{
  name:string
  checked:boolean
}
@Component
export struct TagSelection {
  @Prop tag:Tag
  private selectTags = (tag:Tag)=>{}
  build() {
    GridItem() {
      Text(this.tag.name)
        .fontSize(BasicConstants.FONT_SIZE_SMALL)
        .fontColor($r('app.color.text_default'))
        .padding({top:5,bottom:5})
    }
    .width(80)
    .borderRadius(20)
    .borderWidth(2)
    .borderColor(this.tag.checked? $r('app.color.edit') : $r('app.color.disabled'))
    .onClick(()=>{
      this.tag.checked = !this.tag.checked
      this.selectTags(this.tag)
    })
  }
}