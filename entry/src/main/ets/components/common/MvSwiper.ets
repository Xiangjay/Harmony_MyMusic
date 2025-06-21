import { BasicConstants } from "../../common/constants/BasicConstants"
import { MVModel, mvRouterParamsModel } from "../../models/DataModels"
import { router } from "@kit.ArkUI"

@Component
export struct MvSwiper {
  @Prop mvList:Array<MVModel>
  build() {
    Swiper(){
      ForEach(this.mvList,(item:MVModel,index:number)=>{
        RelativeContainer(){
          Image(item.picUrl || item.cover)
            .width(BasicConstants.FULL_WIDTH)
            .height(BasicConstants.FULL_HEIGHT)
            .objectFit(ImageFit.Cover)
          Text(item.name)
            .fontSize(BasicConstants.FONT_SIZE_NORMAL)
            .fontColor($r('app.color.label_text'))
            .maxLines(1)
            .textOverflow({overflow:TextOverflow.Ellipsis})
            .backgroundColor($r('app.color.label_background'))
            .padding(5)
            .alignRules({
              'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
              'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
            })
          Text(item.artistName)
            .fontSize(BasicConstants.FONT_SIZE_NORMAL)
            .fontColor($r('app.color.label_text'))
            .backgroundColor($r('app.color.label_background'))
            .padding(5)
            .borderRadius(5)
            .margin({top:5,right:5 })
            .alignRules({
              'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
              'right': { 'anchor': '__container__', 'align': HorizontalAlign.End }
            })
        }
        .clip(true)
        .borderRadius(10)
        .height(200)
        .onClick(()=>{
          const param:mvRouterParamsModel = {
            index: index,
            mvList: this.mvList
          }
          router.pushUrl({
            url:'pages/PlayMV',
            params: {
              param: param
            }
          })
        })
      },(item:MVModel)=>item.id.toString())
    }
    .autoPlay(true)
    .indicator(false)
  }
}