import { router, window } from '@kit.ArkUI'
import log from '@open/log'
import { routerParams,MVModel, mvRouterParamsModel,responseArtistModel } from '../models/DataModels'
import { BasicConstants } from '../common/constants/BasicConstants'
import { TopNavBar } from '../components/common/TopNavBar'
import { getMvDetailById, getMvInfoById, getMvUrlById } from '../common/apis/MVApis'
import { countTransform, myDataMerge } from '../common/utils/CommonTools'
import { Loading } from '../components/common/Loading'
import { getSingerDetailById } from '../common/apis/MusicApis'
import {MvContent} from '../components/MV/MvContent'

@Extend(Text) function infoText(size:number = BasicConstants.FONT_SIZE_NORMAL,color:ResourceColor = Color.White) {
  .fontSize(size)
  .fontColor(color)
}

class testMV{
  url:string = ''
  pic:string = ''
}

@Entry
@Component
struct PlayMV {
  @State routerParams:mvRouterParamsModel = new mvRouterParamsModel()
  @StorageProp('safeTop') safeTop: number = 0;
  windowClass: window.Window = AppStorage.get("windowClass") as window.Window;	//拿到全局window对象
  private swiperController: SwiperController = new SwiperController()
  @State isLoading:boolean = true
  @State mvList:MVModel[] = []
  @State currentMvId:number = 0
  @State currentPlayIndex:number = 0
  @State currentMV:MVModel = new MVModel()

  getMVDetail = async (mvId:number) =>{
    let mv:MVModel = new MVModel()
    const mvDetail = await getMvDetailById<MVModel,null>(mvId)
    mv = myDataMerge<MVModel>(mv,mvDetail.data)
    const mvInfo = await getMvInfoById<MVModel,null>(mvId)
    mv = myDataMerge<MVModel>(mv,mvInfo)
    const mvUrl = await getMvUrlById<MVModel,null>(mvId)
    mv = myDataMerge<MVModel>(mv,mvUrl.data)
    const avatar = await getSingerDetailById<responseArtistModel,null>(mv.artistId)
    mv.artistAvatar = avatar.data.artist.avatar
    mv.controller = new VideoController()
    this.mvList.push(mv)
  }

  getMvList = async (list:Array<MVModel>)=>{
    for (let i = 0; i < list.length; i++) {
      //对每一个MV发送请求获取数据
      await this.getMVDetail(list[i].id);
      //请求都发送完了
      if(i === list.length -1){
        this.mvList[this.currentPlayIndex].isPlaying = true
        this.isLoading = false
      }
    }
  }

  aboutToAppear(): void {
    this.windowClass.setSpecificSystemBarEnabled('navigationIndicator', true)  //底部导航条不隐藏
    try {
      this.routerParams = (router.getParams() as routerParams<mvRouterParamsModel>).param
      this.currentMvId = this.routerParams.id
      this.currentPlayIndex = this.routerParams.index
      this.getMvList(this.routerParams.mvList)
    }catch {

    }
  }

  @Builder contentBuilder(){
    Swiper(this.swiperController){
      ForEach(this.mvList,(mv:MVModel)=>{
        MvContent({ mv:mv })
      },(mv:MVModel)=>mv.id.toString())
    }
    .indicator(false)
    .loop(true)
    .vertical(true)
    .width(BasicConstants.FULL_WIDTH)
    .height(BasicConstants.FULL_HEIGHT)
    .index(this.currentPlayIndex)
    .onChange((index: number) => {
      this.currentPlayIndex = index;
      this.mvList.forEach((mv:MVModel,mvIndex:number)=>{
        mv.showPlayButton = false
        if(mvIndex === index){
          mv.isPlaying = true
        }else {
          mv.isPlaying = false
        }
      })
    })
  }
  @Builder rightButtonsBuilder(mv:MVModel){
    Column({space:20}){
      Column({space:5}){
        Image($r('app.media.icon_dianzan'))
          .width(30)
          .fillColor(Color.White)
        Text(countTransform(mv.playCount))
          .infoText(BasicConstants.FONT_SIZE_SMALL)
      }
      Column({space:5}){
        Image($r('app.media.icon_comment'))
          .width(30)
          .fillColor(Color.White)
        Text(countTransform(mv.commentCount))
          .infoText(BasicConstants.FONT_SIZE_SMALL)
      }
      Column({space:5}){
        Image($r('app.media.icon_share'))
          .width(30)
          .fillColor(Color.White)
        Text(countTransform(mv.shareCount))
          .infoText(BasicConstants.FONT_SIZE_SMALL)
      }
    }
    .padding({right:10})
    .alignRules({
      'top': { 'anchor': '__container__', 'align': VerticalAlign.Center },
      'right': { 'anchor': '__container__', 'align': HorizontalAlign.End }
    })
  }
  @Builder bottomInfoBuilder(mv:MVModel){
    Column({space:10}){
      Row({space:5}){
        Image(mv.artistAvatar)
          .width(40)
          .borderRadius(50)
        Text(mv.artistName)
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
        Text(mv.name)
          .infoText()
      }
      .width(BasicConstants.FULL_WIDTH)
      .alignItems(VerticalAlign.Center)
      Text(mv.publishTime)
        .infoText(BasicConstants.FONT_SIZE_SMALL,'#a9a9a9')
        .width(BasicConstants.FULL_WIDTH)
    }
    .padding({
      left:10,
      bottom:10
    })
    .width('80%')
    .alignRules({
      'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
      'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
    })
  }

  build() {
    if (!this.isLoading){
      Stack({alignContent:Alignment.Top}){
        this.contentBuilder()
        //返回按钮
        Row(){
          TopNavBar({color:'#ffffff'})
        }
        .padding({
          top:this.safeTop,
          left: 10
        })
      }
      .width(BasicConstants.FULL_WIDTH)
      .height(BasicConstants.FULL_HEIGHT)
      .backgroundColor(Color.Black)
    } else {
      Loading()
    }
  }
}