import log from "@open/log";
import { getAllPrograms } from "../../common/apis/HomeApis";
import { BasicConstants } from "../../common/constants/BasicConstants";
import { myDataMerge } from "../../common/utils/CommonTools";
import { allProgramsModel, musicRouterParamsModel, PlayListType, ProgramModel } from "../../models/DataModels";
import { Loading } from "../common/Loading";
import { Title } from "../common/Title";
import { router } from "@kit.ArkUI";

@Component
export struct Program {
  @State programs:Array<ProgramModel> = []
  @State isLoading:boolean = true
  getAllPrograms = async () => {
    const res = await getAllPrograms<Array<allProgramsModel>,null>()
    res.toplist.forEach(item=>{
      this.programs.push(myDataMerge<ProgramModel>(new ProgramModel(),item.program))
    })
    this.isLoading = false
  }
  aboutToAppear(): void {
    this.getAllPrograms()
  }
  build() {
    Scroll(){
      Column({space:10}){
        if (!this.isLoading){
          Title({title:'前10节目'})
          Column({space:10}){
            ForEach(this.programs,(program:ProgramModel)=>{
              Row({space:20}){
                Image(program.coverUrl)
                  .width('30%')
                  .height(BasicConstants.FULL_HEIGHT)
                  .borderRadius(5)
                  .alt($r('app.media.img_loading'))
                  .onClick(()=>{
                    const param:musicRouterParamsModel = {
                      id:program.id,
                      type:PlayListType.dj
                    }
                    router.pushUrl({
                      url:'pages/Music',
                      params: {
                        param: param
                      }
                    })
                  })
                Column(){
                  Text(program.name)
                    .fontColor($r('app.color.text_default'))
                    .fontSize(BasicConstants.FONT_SIZE_NORMAL)
                  Text(program.description)
                    .fontColor($r('app.color.text_light'))
                    .fontSize(BasicConstants.FONT_SIZE_NORMAL)
                    .maxLines(3)
                    .textOverflow({overflow:TextOverflow.Ellipsis})
                }
                .padding({
                  top:5,
                  bottom:5
                })
                .height(BasicConstants.FULL_HEIGHT)
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.SpaceBetween)
                .layoutWeight(1)
              }
              .height(120)
            },(program:ProgramModel)=>program.id.toString())
          }
        }else {
          Loading()
        }
      }
      .padding({ top: 20,bottom:20,right:10 })
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Fade)
    .fadingEdge(true)
    .margin({bottom:BasicConstants.MAIN_TAB_BAR_HEIGHT})
    .height(BasicConstants.FULL_HEIGHT)
    .width(BasicConstants.FULL_WIDTH)
  }
}