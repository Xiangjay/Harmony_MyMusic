import { router } from '@kit.ArkUI'
import log from '@open/log'
import { BasicConstants } from '../common/constants/BasicConstants'
import { formatData, myDataMerge } from '../common/utils/CommonTools'
import { Loading } from '../components/common/Loading'
import {
  commentsRouterParamsModel, PlayListModel, playListType, routerParams, commentsModel,
  commentsUser } from '../models/DataModels'
import {getCommentsById} from '../common/apis/MusicApis'
import { MyLazyDataSource } from '../common/utils/MyLazyDataSource'

@Extend(Text) function coverText(fontSize:number = BasicConstants.FONT_SIZE_NORMAL) {
  .fontSize(fontSize)
  .fontColor(Color.White)
  .width(BasicConstants.FULL_WIDTH)
  .maxLines(2)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

@Entry
@Component
struct Comments {
  @State routerParams:commentsRouterParamsModel = new commentsRouterParamsModel()
  @State playList: PlayListModel = new PlayListModel()
  @State commentsList:Array<commentsModel> = []
  @State isLoading:boolean = false
  private commentsLazyData:MyLazyDataSource<commentsModel> = new MyLazyDataSource()

  getComments = async (type:string) => {
    //通过id拿到所有评论
    const res = await getCommentsById<Array<commentsModel>,null>(type,this.playList.id)
    res.comments.forEach(item=>{
      this.commentsList.push(myDataMerge<commentsModel>(new commentsModel(),item))
    })
    this.commentsList.forEach((comment:commentsModel)=>{
      comment.user = myDataMerge<commentsUser>(new commentsUser(),comment.user)
    })
    this.commentsLazyData.pushAllData(this.commentsList)
  }

  aboutToAppear(): void {
    try {
      this.routerParams = (router.getParams() as routerParams<commentsRouterParamsModel>).param
      this.playList = this.routerParams.detail
      this.getComments(this.routerParams.type === playListType.playList ? 'playlist' : 'album')
    } catch {

    }
  }

  @Builder coverBuilder() {
    Stack({alignContent:Alignment.Top}){
      Image(this.playList?.picUrl)
        .width(BasicConstants.FULL_WIDTH)
        .height(BasicConstants.FULL_HEIGHT)
        .blur(1000)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      Column(){
        //后退按钮
        Row({space:5}) {
          Image($r('app.media.icon_back'))
            .width(30)
            .height(30)
            .fillColor(Color.White)
            .onClick(() => {
              router.back()
            })
          Row(){
            Text('评论 ')
              .fontColor(Color.White)
              .fontSize(BasicConstants.FONT_SIZE_NORMAL)
            Text(`(${this.playList.commentCount})`)
              .fontColor(Color.White)
              .opacity(0.6)
              .fontSize(BasicConstants.FONT_SIZE_SMALL)
          }
        }
        .justifyContent(FlexAlign.Start)
        .width(BasicConstants.FULL_WIDTH)
        .margin({bottom:20})
        Row() {
          Column() {
            Image(this.playList.picUrl)
              .borderRadius(5)
              .width(BasicConstants.FULL_WIDTH)
              .height(120)
          }
          .width(120)
          Column() {
            Text(this.playList.name)
              .coverText(BasicConstants.FONT_SIZE_LARGE)
            Text(this.playList.tags!.toString() || formatData(this.playList.publishTime!) + ' 发行')
              .coverText(BasicConstants.FONT_SIZE_SMALL)
              .opacity(0.6)
            Text(this.playList.description)
              .coverText()
              .opacity(0.8)
          }
          .padding({
            left: 10,
            top: 5,
            bottom: 5
          })
          .justifyContent(FlexAlign.SpaceBetween)
          .layoutWeight(1)
          .height(120)
        }
        .width(BasicConstants.FULL_WIDTH)
      }
      .padding({
        left: 10,
        right: 10
      })
    }
    .width(BasicConstants.FULL_WIDTH)
    .height('30%')
  }
  @Builder commentsBuilder(item:commentsModel){
    Row({space:10}){
      Column(){
        Image(item.user.avatarUrl)
          .width(50)
          .height(50)
          .borderRadius(50)
      }
      Column({space:10}){
        Row(){
          Column(){
            Text(item.user.nickname)
              .fontSize(BasicConstants.FONT_SIZE_NORMAL)
              .fontColor($r('app.color.text_default'))
            Text(formatData(item.time))
              .fontSize(BasicConstants.FONT_SIZE_SMALL)
              .fontColor($r('app.color.text_default'))
              .opacity(0.6)
          }
          .width('60%')
          .alignItems(HorizontalAlign.Start)
          Row({space:5}){
            Text(item.likedCount.toString())
              .fontSize(BasicConstants.FONT_SIZE_SMALL)
              .fontColor($r('app.color.text_default'))
              .opacity(0.6)
            Image($r('app.media.icon_dianzan'))
              .width(20)
              .fillColor($r('app.color.icon_svg_selected'))
          }
        }
        .width(BasicConstants.FULL_WIDTH)
        .justifyContent(FlexAlign.SpaceBetween)
        Row(){
          Text(item.content)
            .fontColor($r('app.color.text_default'))
            .fontSize(BasicConstants.FONT_SIZE_NORMAL)
        }
        .width(BasicConstants.FULL_WIDTH)
        .justifyContent(FlexAlign.Start)
      }
      .layoutWeight(1)
    }
    .padding({
      top:10,
      bottom:10
    })
    .alignItems(VerticalAlign.Top)
    .width(BasicConstants.FULL_WIDTH)
    .border({
      width: { bottom: 1 },
      color: '#12ec5c87'
    })
  }
  build() {
    Column(){
      if (this.isLoading) {
        Loading()
      } else{
        Column({ space: 10 }){
          //封面
          this.coverBuilder()
          //评论内容

          List(){
            LazyForEach(this.commentsLazyData,(item:commentsModel)=>{
              ListItem(){
                this.commentsBuilder(item)
              }
            },(item:commentsModel)=>item.commentId.toString())
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.None)
          .fadingEdge(true)
          .padding({
            left:10,
            right:10
          })
          .width(BasicConstants.FULL_WIDTH)
          // .margin({bottom:20})
          .layoutWeight(1)
        }
      }
    }
    .justifyContent(this.isLoading?FlexAlign.Center:FlexAlign.Start)
    .width(BasicConstants.FULL_WIDTH)
    .height(BasicConstants.FULL_HEIGHT)
    .backgroundColor($r('app.color.content_background'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
  }
}