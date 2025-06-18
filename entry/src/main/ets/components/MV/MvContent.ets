import log from '@open/log'
import { getMvCommentsById } from '../../common/apis/MVApis'
import { BasicConstants } from '../../common/constants/BasicConstants'
import { countTransform, formatData, myDataMerge } from '../../common/utils/CommonTools'
import { commentsModel, commentsUser, MVModel, responseComments } from '../../models/DataModels'
import { Loading } from '../common/Loading'

@Extend(Text) function infoText(size:number = BasicConstants.FONT_SIZE_NORMAL,color:ResourceColor = Color.White) {
  .fontSize(size)
  .fontColor(color)
}

@Component
export struct MvContent {
  @ObjectLink @Watch('watchMv')mv:MVModel //从父组件拿到mv并监听其属性变化，这里主要是为了监听isPlaying的变化，用来控制是否播放该视频
  //评论弹窗用
  @State commentsListHeight: string = '0%'
  @State commentsListOpacity: number = 0
  private animationDuration:number = 300
  @State isLoading:boolean = false
  @State pageSize:number = 20
  @State offsetNum:number = 0 //数据偏移量
  @State hasMore:boolean = true
  @State listScrolled:boolean = false //标记是否人为滚动列表

  watchMv(){  //通过watch监听isPlaying属性的变化
    this.mv.isPlaying ? this.mv.controller?.start() : this.mv.controller?.pause()
  }

  getComments = async () =>{
    const responseData = myDataMerge<responseComments>(new responseComments(),await getMvCommentsById<responseComments,null>(this.mv.id,this.offsetNum,this.pageSize))
    this.hasMore = responseData.more
    const commentsList:Array<commentsModel> = []
    responseData.comments.forEach(item=>{
      commentsList.push(myDataMerge<commentsModel>(new commentsModel(),item))
    })
    commentsList.forEach((comment:commentsModel)=>{
      comment.user = myDataMerge<commentsUser>(new commentsUser(),comment.user)
    })
    //把数据放入懒加载数据类型中，程序就不需要拿评论数据了
    this.mv.commentsLazyData?.pushAllData(commentsList)
    this.isLoading = false
  }

  aboutToAppear(): void {
    this.getComments()
  }
  
  @Builder rightButtonsBuilder(){
    Column({space:20}){
      Column({space:5}){
        Image($r('app.media.icon_dianzan'))
          .width(30)
          .fillColor(this.mv.liked === false ? Color.White : '#ff0000')
          .onClick(()=>{
            this.mv.liked = !this.mv.liked
            this.mv.likedCount +=1
          })
        Text(countTransform(this.mv.playCount))
          .infoText(BasicConstants.FONT_SIZE_SMALL)
      }
      Column({space:5}){
        Image($r('app.media.icon_comment'))
          .width(30)
          .fillColor(Color.White)
          .onClick(()=>{
            this.mv.showComments = true
            this.commentsListHeight = '100%'
            this.commentsListOpacity = 1
          })
        Text(countTransform(this.mv.commentCount))
          .infoText(BasicConstants.FONT_SIZE_SMALL)
      }
      Column({space:5}){
        Image($r('app.media.icon_share'))
          .width(30)
          .fillColor(Color.White)
        Text(countTransform(this.mv.shareCount))
          .infoText(BasicConstants.FONT_SIZE_SMALL)
      }
    }
    .padding({right:10})
    .alignRules({
      'top': { 'anchor': '__container__', 'align': VerticalAlign.Center },
      'right': { 'anchor': '__container__', 'align': HorizontalAlign.End }
    })
  }
  @Builder bottomInfoBuilder(){
    Column({space:10}){
      Row({space:5}){
        Image(this.mv.artistAvatar)
          .width(40)
          .borderRadius(50)
        Text(this.mv.artistName)
          .infoText()
      }
      .width(BasicConstants.FULL_WIDTH)
      .alignItems(VerticalAlign.Center)
      Row({space:5}){
        Row(){
          Text('MV')
            .infoText()
        }
        .padding(5)
        .backgroundColor('#3a3e41')
        Text(this.mv.name)
          .infoText()
      }
      .width(BasicConstants.FULL_WIDTH)
      .alignItems(VerticalAlign.Center)
      Text(this.mv.publishTime)
        .infoText(BasicConstants.FONT_SIZE_SMALL,'#a9a9a9')
        .width(BasicConstants.FULL_WIDTH)
    }
    .padding({
      left:20,
      bottom:20
    })
    .width('80%')
    .alignRules({
      'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
      'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
    })
  }
  @Builder commentsBuilder(){
    Stack({alignContent:Alignment.Bottom}){
      Column(){
        Column(){ //遮罩层，点击隐藏评论

        }
        .width(BasicConstants.FULL_WIDTH)
        .height('50%')
        .backgroundColor(Color.Transparent)
        .onClick(()=>{
          this.commentsListHeight = '0%'
          this.commentsListOpacity = 0
          this.mv.showComments = false
        })
        Column(){
          List(){
            LazyForEach(this.mv.commentsLazyData,(item:commentsModel)=>{
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
              this.getComments()
            }
          })
        }
        .backgroundColor('#3a3e41')
        .width(BasicConstants.FULL_WIDTH)
        .height('50%')
      }
      .height(this.commentsListHeight)
      .opacity(this.commentsListOpacity)
      .animation({
        duration:this.animationDuration,
      })
      .width(BasicConstants.FULL_WIDTH)
      if(this.isLoading){
        Row(){
          Loading({showIcon:false})
        }
        .margin({bottom:20})
      }
    }
    .alignRules({
      'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
      'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
    })
  }

  build() {
    RelativeContainer(){
      Video({
        src: this.mv.url,
        controller: this.mv.controller
      })
        .autoPlay(this.mv.isPlaying)
        .objectFit(ImageFit.Contain)
        .loop(false)
        .controls(false)
        .width(BasicConstants.FULL_WIDTH)
        .height(BasicConstants.FULL_HEIGHT)
        .alignRules({
          'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
          'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
        })
        .onClick(()=>{
          if(this.mv.isPlaying){
            this.mv.isPlaying = false
            this.mv.showPlayButton = true
          }else{
            this.mv.isPlaying = true
            this.mv.showPlayButton = false
          }
        })
      //右侧按钮
      this.rightButtonsBuilder()
      //底部MV信息
      this.bottomInfoBuilder()
      //播放按钮
      if(this.mv.showPlayButton){
        Image($r('app.media.icon_play'))
          .width(80)
          .height(80)
          .alignRules({
            'center': { 'anchor': '__container__', 'align': VerticalAlign.Center },
            'middle': { 'anchor': '__container__', 'align': HorizontalAlign.Center }
          })
          .onClick(()=>{
            this.mv.isPlaying = true
            this.mv.showPlayButton = false
          })
      }
      //评论列表
      this.commentsBuilder()
    }
    .width(BasicConstants.FULL_WIDTH)
    .height(BasicConstants.FULL_HEIGHT)
  }
}