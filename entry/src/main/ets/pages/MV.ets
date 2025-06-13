import { BasicConstants } from "../common/constants/BasicConstants"
import { countTransform, myDataMerge } from "../common/utils/CommonTools"
import { MVModel } from "../models/DataModels"
import { Loading } from "../components/common/Loading"
import {Title} from '../components/common/Title'
import { getAllMV } from "../common/apis/MVApis"
import log from "@open/log"
import { router } from "@kit.ArkUI"

@Entry
@Component
struct MV {
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
    Column(){
      Title({title:title})
      List(){
        ForEach(mvList,(mv:MVModel)=>{
          ListItem(){
            RelativeContainer(){
              Image(mv.cover)
                .width(BasicConstants.FULL_WIDTH)
                .height(200)
                .borderRadius(10)
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
            .margin({right:10})
            .borderRadius(10)
          }
        },(mv:MVModel)=>mv.id.toString())
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .width(BasicConstants.FULL_WIDTH)
      .height(200)
      .margin({top:10})
    }
  }
  aboutToAppear(): void {
    this.getAllMVList()
  }

  build() {
    Column(){
      if(!this.isLoading){
        Row(){
          Row({space:5}) {
            Image($r('app.media.icon_back'))
              .width(30)
              .height(30)
              .fillColor($r('app.color.back_icon'))
              .onClick(() => {
                router.back()
              })
            Text('MV')
              .fontColor($r('app.color.back_icon'))
              .fontSize(BasicConstants.FONT_SIZE_NORMAL)
              .fontWeight(FontWeight.Bold)
          }
          .justifyContent(FlexAlign.Start)
          .width(BasicConstants.FULL_WIDTH)
        }
        .padding({
          left:10
        })
        .margin({bottom:20})
        Scroll(){
          Column({space:20}){
            this.mvListBuilder('华语',this.chinaMVs)
            this.mvListBuilder('日韩',this.japanMVs)
            this.mvListBuilder('欧美',this.europeMVs)
            this.mvListBuilder('其他',this.otherMVs)
          }
          .padding({
            left:10,
          })
          .width(BasicConstants.FULL_WIDTH)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }else {
        Loading()
      }
    }
    .justifyContent(this.isLoading?FlexAlign.Center:FlexAlign.Start)
    .width(BasicConstants.FULL_WIDTH)
    .height(BasicConstants.FULL_HEIGHT)
    .backgroundColor($r('app.color.content_background'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
  }
}