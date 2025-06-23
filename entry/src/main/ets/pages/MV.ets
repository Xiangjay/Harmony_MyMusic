import { BasicConstants } from "../common/constants/BasicConstants"
import { countTransform, myDataMerge } from "../common/utils/CommonTools"
import { MVModel, mvRouterParamsModel } from "../models/DataModels"
import { Loading } from "../components/common/Loading"
import {Title} from '../components/common/Title'
import { getAllMV } from "../common/apis/MVApis"
import { TopNavBar } from "../components/common/TopNavBar"
import { router } from "@kit.ArkUI"

//MV列表页面
@Entry
@Component
struct MV {
  @StorageProp('safeTop') safeTop: number = 0;
  @State isLoading:boolean = true
  @State chinaMVs:Array<MVModel> = []
  @State europeMVs:Array<MVModel> = []
  @State japanMVs:Array<MVModel> = []
  @State otherMVs:Array<MVModel> = []

  getAllMVList = async ()=>{
    const resChina = await Promise.all([await getAllMV<Array<MVModel>,null>('大陆'),await getAllMV<Array<MVModel>,null>('港台')])
    const responseChinaMVs:Array<MVModel> = resChina[0].data.concat(resChina[1].data)
    responseChinaMVs.sort((a,b)=>{
      return b.playCount - a.playCount
    })
    responseChinaMVs.forEach(item=>{
      this.chinaMVs.push(myDataMerge<MVModel>(new MVModel(),item))
    })

    const resEurope = await getAllMV<Array<MVModel>,null>('欧美')
    resEurope.data.forEach(item=>{
      this.europeMVs.push(myDataMerge<MVModel>(new MVModel(),item))
    })
    this.europeMVs.sort((a,b)=>{
      return b.playCount - a.playCount
    })

    const resJapan = await getAllMV<Array<MVModel>,null>('日韩')
    resJapan.data.forEach(item=>{
      this.japanMVs.push(myDataMerge<MVModel>(new MVModel(),item))
    })
    this.japanMVs.sort((a,b)=>{
      return b.playCount - a.playCount
    })

    const resOther = await getAllMV<Array<MVModel>,null>('其他')
    resOther.data.forEach(item=>{
      this.otherMVs.push(myDataMerge<MVModel>(new MVModel(),item))
    })
    this.otherMVs.sort((a,b)=>{
      return b.playCount - a.playCount
    })
    this.isLoading = false
  }

  @Builder mvListBuilder(title:string,mvList:Array<MVModel>){
    Column({space:10}){
      Title({title:title})
      List({space:10}){
        ForEach(mvList,(mv:MVModel,index:number)=>{
          ListItem(){
            RelativeContainer(){
              Image(mv.cover)
                .width(BasicConstants.FULL_WIDTH)
                .height(200)
                .alt($r('app.media.img_loading'))
              Text(mv.name)
                .fontSize(BasicConstants.FONT_SIZE_NORMAL)
                .fontColor($r('app.color.label_text'))
                .width(BasicConstants.FULL_WIDTH)
                .maxLines(1)
                .textOverflow({overflow:TextOverflow.Ellipsis})
                .backgroundColor($r('app.color.label_background'))
                .padding(5)
                .alignRules({
                  'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
                  'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
                })
              Text(countTransform(mv.playCount) + '播放')
                .fontSize(BasicConstants.FONT_SIZE_SMALL)
                .fontColor($r('app.color.label_text'))
                .backgroundColor($r('app.color.label_background'))
                .padding(5)
                .borderRadius(5)
                .margin({top:5,left:5 })
                .alignRules({
                  'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
                  'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
                })
              Text(mv.artistName)
                .fontSize(BasicConstants.FONT_SIZE_SMALL)
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
            .borderRadius(10)
            .clip(true)
            .width('80%')
            .onClick(()=>{
              const param:mvRouterParamsModel = {
                index: index,
                mvList: mvList
              }
              router.pushUrl({
                url:'pages/PlayMV',
                params: {
                  param: param
                }
              })
            })
          }
        },(mv:MVModel)=>mv.id.toString())
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .fadingEdge(true)
      .width(BasicConstants.FULL_WIDTH)
      .height(200)
    }
  }

  aboutToAppear(): void {
    this.getAllMVList()
  }

  build() {
    Column(){
      if(!this.isLoading){
        TopNavBar({title:'MV'})
        Scroll(){
          Column({space:30}){
            this.mvListBuilder('华语',this.chinaMVs)
            this.mvListBuilder('日韩',this.japanMVs)
            this.mvListBuilder('欧美',this.europeMVs)
            this.mvListBuilder('其他',this.otherMVs)
          }
          .width(BasicConstants.FULL_WIDTH)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Fade)
        .margin({
          top:20,
          bottom:20
        })
      }else {
        Column(){
          Loading()
        }
        .height(BasicConstants.FULL_HEIGHT)
        .width(BasicConstants.FULL_WIDTH)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }
    }
    .height(BasicConstants.FULL_HEIGHT)
    .width(BasicConstants.FULL_WIDTH)
    .backgroundColor($r('app.color.content_background'))
    .padding({
      top: this.safeTop,
      left:10
    })
  }
}