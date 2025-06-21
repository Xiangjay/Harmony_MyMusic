import { router, window } from '@kit.ArkUI'
import log from '@open/log'
import { routerParams,MVModel, mvRouterParamsModel,responseArtistModel} from '../models/DataModels'
import { BasicConstants } from '../common/constants/BasicConstants'
import { TopNavBar } from '../components/common/TopNavBar'
import { getMvDetailById, getMvInfoById, getMvUrlById } from '../common/apis/MVApis'
import { myDataMerge } from '../common/utils/CommonTools'
import { Loading } from '../components/common/Loading'
import { getSingerDetailById } from '../common/apis/MusicApis'
import {MvContent} from '../components/MV/MvContent'
import { recentMVsDB } from '../db/recentMVsDB'
import { relationalStore } from '@kit.ArkData'

//视频播放页面
@Entry
@Component
struct PlayMV {
  @State routerParams:mvRouterParamsModel = new mvRouterParamsModel()
  @StorageProp('safeTop') safeTop: number = 0;
  windowClass: window.Window = AppStorage.get("windowClass") as window.Window;	//拿到全局window对象
  private swiperController: SwiperController = new SwiperController()
  @State isLoading:boolean = true
  @State mvLoading:boolean = false
  @State mvList:MVModel[] = []
  @State currentPlayIndex:number = 0
  @State currentMv:MVModel = new MVModel()
  @State pageSize:number = 5
  @State offsetNum:number = 0 //数据偏移量

  getMVDetail = async (mvId:number) =>{
    let mv:MVModel = new MVModel()
    const mvDetail = await getMvDetailById<MVModel,null>(mvId)  //拿到MV详情
    mv = myDataMerge<MVModel>(mv,mvDetail.data)
    const mvInfo = await getMvInfoById<MVModel,null>(mvId)  //拿到MV点赞数和评论数
    mv = myDataMerge<MVModel>(mv,mvInfo)
    const mvUrl = await getMvUrlById<MVModel,null>(mvId)  //拿到MV播放地址
    mv = myDataMerge<MVModel>(mv,mvUrl.data)
    const avatar = await getSingerDetailById<responseArtistModel,null>(mv.artistId) //拿到MV歌手头像
    mv.artistAvatar = avatar.data.artist.picUrl
    mv.controller = new VideoController() //初始化MvController
    this.mvList.push(mv)
    if(this.mvList.length === this.routerParams.mvList.length){ //所有mv数据都拿完了
      this.playMV()
      this.isLoading = false
    }
  }
  getMvList = async (list:Array<MVModel>)=>{
    for (let i = 0; i < list.length; i++) {
      //对每一个MV发送请求获取数据
      await this.getMVDetail(list[i].id);
    }
  }
  playMV = async ()=>{
    this.currentMv = this.mvList[this.currentPlayIndex]
    const valueBucket: relationalStore.ValuesBucket = {
      ID:this.currentMv.id,
      NAME: this.currentMv.name,
      PICURL: this.currentMv.picUrl || this.currentMv.cover,
      ARTISTNAME:JSON.stringify(this.currentMv.artistName),
      ARTISTID:JSON.stringify(this.currentMv.artistId),
      URL:this.currentMv.url,
      SAVETIME:new Date().getTime()
    }
    const recentMVs = await recentMVsDB.queryData('RECENT_MVS',undefined,this.currentMv.id)
    if (recentMVs.length != 0) {
      const existed = recentMVs.some(item=>item.id === this.currentMv.id)
      if(!existed){
        recentMVsDB.insertData('RECENT_MVS',valueBucket)
      }else {
        const valueBucket: relationalStore.ValuesBucket = {
          SAVETIME:new Date().getTime()
        }
        recentMVsDB.updateDataById('RECENT_MVS',this.currentMv.id,valueBucket)
      }
    }else {
      recentMVsDB.insertData('RECENT_MVS',valueBucket)
    }
    this.mvList.forEach((mv:MVModel)=>{
      mv.showPlayButton = false
      mv.isPlaying = false
      mv.showComments = false
    })
    this.currentMv.isPlaying = true
  }

  aboutToAppear(): void {
    this.windowClass.setSpecificSystemBarEnabled('navigationIndicator', true)  //底部导航条不隐藏
    try {
      this.routerParams = (router.getParams() as routerParams<mvRouterParamsModel>).param
      this.currentPlayIndex = this.routerParams.index
      this.getMvList(this.routerParams.mvList)
    }catch {

    }
  }

  @Builder swiperBuilder(){
    Swiper(this.swiperController){
      ForEach(this.mvList,(mv:MVModel)=>{
        MvContent({ mv:mv})
      },(mv:MVModel)=>mv.id.toString())
    }
    .indicator(false)
    .loop(true)
    .vertical(true)
    .width(BasicConstants.FULL_WIDTH)
    .height(BasicConstants.FULL_HEIGHT)
    .index(this.currentPlayIndex)
    .disableSwipe(this.currentMv.showComments)  //评论列表打开时禁止滑动切换
    .onChange((index: number) => {
      this.currentPlayIndex = index;
      this.playMV()
    })
  }

  build() {
    if (!this.isLoading){
      Stack({alignContent:Alignment.Top}){
        this.swiperBuilder()
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
      Column(){
        Loading()
      }
      .height(BasicConstants.FULL_HEIGHT)
      .width(BasicConstants.FULL_WIDTH)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
  }
}