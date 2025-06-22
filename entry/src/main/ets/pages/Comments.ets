import { router } from '@kit.ArkUI'
import { BasicConstants } from '../common/constants/BasicConstants'
import { myDataMerge,dayJsFormatData } from '../common/utils/CommonTools'
import { Loading } from '../components/common/Loading'
import {
  commentsRouterParamsModel, PlayListModel, PlayListType, routerParams, commentsModel,
  commentsUser,
  responseComments} from '../models/DataModels'
import {getCommentsById} from '../common/apis/MusicApis'
import { MyLazyDataSource } from '../common/utils/MyLazyDataSource'
import { TopNavBar } from '../components/common/TopNavBar'

@Extend(Text) function coverText(fontSize:number = BasicConstants.FONT_SIZE_NORMAL) {
  .fontSize(fontSize)
  .fontColor(Color.White)
  .width(BasicConstants.FULL_WIDTH)
  .maxLines(2)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

//歌单、专辑评论页面
@Entry
@Component
struct Comments {
  @StorageProp('safeTop') safeTop: number = 0;
  @State routerParams:commentsRouterParamsModel = new commentsRouterParamsModel()
  @State playList: PlayListModel = new PlayListModel()
  @State playListType: PlayListType = PlayListType.playList
  @State isLoading:boolean = true
  //弹窗用
  @State commentsListHeight: string = '0%'
  @State commentsListOpacity: number = 0
  private animationDuration:number = 300
  //懒加载数据，由MyLazyDataSource管理评论列表
  private commentsLazyData:MyLazyDataSource<commentsModel> = new MyLazyDataSource()
  @State pageSize:number = 20
  @State offsetNum:number = 0 //数据偏移量
  @State hasMore:boolean = true
  @State listScrolled:boolean = false //标记是否人为滚动列表

  getComments = async (type:string) => {
    //通过id拿到所有评论
    const responseData = myDataMerge<responseComments>(new responseComments(),await getCommentsById<responseComments,null>(type,this.playList.id,this.offsetNum,this.pageSize))
    this.hasMore = responseData.more
    const commentsList:Array<commentsModel> = []
    responseData.comments.forEach(item=>{
      commentsList.push(myDataMerge<commentsModel>(new commentsModel(),item))
    })
    commentsList.forEach((comment:commentsModel)=>{
      comment.user = myDataMerge<commentsUser>(new commentsUser(),comment.user)
    })
    //把数据放入懒加载数据类型中，程序就不需要拿评论数据了
    this.commentsLazyData.pushAllData(commentsList)
    this.isLoading = false
  }

  aboutToAppear(): void {
    try {
      this.routerParams = (router.getParams() as routerParams<commentsRouterParamsModel>).param
      this.playList = this.routerParams.detail
      this.playListType = this.routerParams.type
      //歌单类型（歌单、专辑）
      this.getComments(this.playListType)
      this.commentsListHeight = '70%'
      this.commentsListOpacity = 1
    } catch {

    }
  }

  @Builder coverBuilder(){
    //封面
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
        Text(this.playList.tags!.toString() || dayJsFormatData(this.playList.publishTime) + ' 发行')
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
    .alignItems(VerticalAlign.Top)
    .width(BasicConstants.FULL_WIDTH)
  }
  @Builder commentsListBuilder(){
    Stack({alignContent:Alignment.Bottom}){
      Column(){
        List(){
          LazyForEach(this.commentsLazyData,(item:commentsModel)=>{
            ListItem(){
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
                      Text(dayJsFormatData(item.time))
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
              .padding(10)
              .alignItems(VerticalAlign.Top)
              .width(BasicConstants.FULL_WIDTH)
            }
            .border({
              width: { bottom: 1 },
              color:$r('app.color.list_divider')
            })
          },(item:commentsModel)=>item.commentId.toString())
        }
        .scrollBar(BarState.Off)
        .edgeEffect(this.hasMore? EdgeEffect.None : EdgeEffect.Spring)
        .fadingEdge(true)
        .layoutWeight(1)
        .onScrollStart(()=>{
          //因为onReachEnd在列表首次渲染时也会触发，所以这里标记下滚动事件，滚动后说明不是第一次加载
          this.listScrolled = true
        })
        .onReachEnd(()=>{
          if(this.hasMore && this.listScrolled){
            this.isLoading = true
            this.offsetNum += this.pageSize
            this.getComments(this.playListType)
          }
        })
      }
      .height(this.commentsListHeight)
      .opacity(this.commentsListOpacity)
      .padding({
        left:10,
        right:10
      })
      .animation({
        duration:this.animationDuration,
      })
      .width(BasicConstants.FULL_WIDTH)
      .backgroundColor($r('app.color.main_tab_background'))
      if(this.isLoading){
        Row(){
          Loading({showIcon:false})
        }
        .margin({bottom:20})
      }
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }){
      Stack({ alignContent: Alignment.Top }){
        Image(this.playList?.picUrl)
          .width(BasicConstants.FULL_WIDTH)
          .height(BasicConstants.FULL_HEIGHT)
          .blur(1000)
        Column({ space: 10 }) {
          //后退按钮
          TopNavBar({title:'评论',color:'#ffffff'})
          //封面
          this.coverBuilder()
        }
        .padding({
          top:this.safeTop,
          left: 10,
          right: 10
        })
        .width(BasicConstants.FULL_WIDTH)
        .height('30%')
      }
      this.commentsListBuilder()
    }
    .height(BasicConstants.FULL_HEIGHT)
    .width(BasicConstants.FULL_WIDTH)
  }
}