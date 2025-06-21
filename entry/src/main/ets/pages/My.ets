import log from "@open/log"
import { BasicConstants } from "../common/constants/BasicConstants"
import { playListDB } from "../db/playListDB"
import { MVModel, mvRouterParamsModel, PlayListModel, SongModel } from "../models/DataModels"
import { LengthMetrics, PromptAction, router } from "@kit.ArkUI"
import { TopNavBar } from "../components/common/TopNavBar"
import { PlayListItem } from "../components/common/PlayListItem"
import { recentSongsDB } from "../db/recentSongsDB"
import { getSongUrlByIds } from "../common/apis/MusicApis"
import { dayJsDiff} from '../common/utils/CommonTools'
import { recentMVsDB } from "../db/recentMVsDB"
import { MvSwiper } from "../components/common/MvSwiper"


//我的页面
@Entry
@Component
export struct My {
  @StorageProp('safeTop') safeTop: number = 0;
  @State oriMyPlayLists:Array<PlayListModel> = []
  @State myPlayLists:Array<PlayListModel> = []
  @State showAllPlayList:boolean = false
  @State recentSongs:Array<SongModel> = []
  @State showAllRecentSongs:boolean = false
  @State tempPlayList:PlayListModel = new PlayListModel()
  @StorageProp('currentSong') currentSong: SongModel = new SongModel()
  @State showAllRecentMVs:boolean = false
  @State recentMVs:Array<MVModel> = []
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();  //提示弹窗

  getMyPlayLists = async ()=>{
    this.oriMyPlayLists = await playListDB.queryData('PLAYLIST')
    this.myPlayLists = this.oriMyPlayLists.slice(0,3)
  }
  getRecentSongs = async ()=>{
    const resSongs = await recentSongsDB.queryData('RECENT_SONGS')
    //只取近7天的数据
    this.recentSongs = resSongs.filter(item=>dayJsDiff(item.saveTime as number)<=7)
    //由于歌曲播放地址是动态变化的，所以数据库里不存播放地址，需要的时候再从服务器拿
    const songIds:number[] = []
    this.recentSongs.forEach(item=>{
      songIds.push(item.id)
    })
    const responseSongUrls = await getSongUrlByIds<Array<SongModel>, null>(songIds)
    responseSongUrls.data.forEach(item=>{
      this.recentSongs.forEach((song:SongModel)=>{
        if(item.id === song.id){
          song.url = item.url
        }
      })
    })
    this.tempPlayList.songs.push(...this.recentSongs)
  }
  getRecentMVs = async ()=>{
    const recentMVs = await recentMVsDB.queryData('RECENT_MVS')
    log.info(recentMVs)
    //只取近7天的数据
    this.recentMVs = recentMVs.filter(item=>dayJsDiff(item.saveTime as number)<=7)
  }
  goToPlay = (song:SongModel)=>{
    AppStorage.setOrCreate('currentPlayList',this.tempPlayList)
    router.pushUrl({
      url:'pages/Play',
      params:{
        param:song
      }
    })
  }

  deletePlayList = (id:number) =>{
    this.getUIContext().showAlertDialog({
        title: '确定删除此歌单吗？',
        message: '',
        autoCancel: true,
        primaryButton: {
          value: '取消',
          fontColor:$r('app.color.text_light'),
          action: () => {
          }
        },
        secondaryButton: {
          value: '确认',
          fontColor:$r('app.color.warning'),
          action: async () => {
            const index = this.oriMyPlayLists.findIndex(item=>item.id === id)
            const res = await playListDB.deleteDataById('PLAYLIST',id)
            if(res.code === 0){ //成功
              this.oriMyPlayLists.splice(index,1)
              this.myPlayLists = this.oriMyPlayLists.slice(0,3)
              this.promptAction.showToast({
                message: '删除歌单成功',
                duration: BasicConstants.TOAST_DURATION
              })
            }else { //失败
              this.promptAction.showToast({
                message: '删除歌单失败',
                duration: BasicConstants.TOAST_DURATION
              })
            }
          }
        }
      }
    )
  }

  onPageShow(): void {
    this.getMyPlayLists()
    this.getRecentSongs()
    this.getRecentMVs()
  }
  onPageHide(): void {
    this.oriMyPlayLists = []
    this.myPlayLists = []
  }

  @Builder myPlayListBuilder(){
    Column({space:10}){
      Row(){
        Row({space:5}){
          Text('我的歌单')
            .fontSize(BasicConstants.FONT_SIZE_LARGE)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_default'))
          Text(`(${this.oriMyPlayLists.length})`)
            .fontSize(BasicConstants.FONT_SIZE_NORMAL)
            .fontColor($r('app.color.text_light'))
        }
        .alignItems(VerticalAlign.Center)
        Row({space:20}){
          Row({space:5}){
            Text('新建')
              .fontSize(BasicConstants.FONT_SIZE_NORMAL)
              .fontColor($r('app.color.edit'))
            Image($r('app.media.icon_add'))
              .fillColor($r('app.color.edit'))
              .width(20)
              .height(20)
          }
          .onClick(()=>{
            router.pushUrl({
              url:'pages/CreateNewPlayList',
            })
          })
          Row(){
            Text('查看全部')
              .fontSize(BasicConstants.FONT_SIZE_NORMAL)
              .fontColor(this.oriMyPlayLists.length > 3 ? $r('app.color.edit') : $r('app.color.disabled'))
            Image($r('app.media.icon_arrow_right'))
              .fillColor(this.oriMyPlayLists.length > 3 ? $r('app.color.edit') : $r('app.color.disabled'))
              .width(20)
              .height(20)
          }
          .onClick(()=>{
            if(this.oriMyPlayLists.length>3){
              this.showAllPlayList = true
            }
          })
          .bindSheet($$this.showAllPlayList, this.allPlayListsBuilder(), {
            title:{title:'全部歌单'},
            height:'80%',
            showClose:true,
            radius:{topStart:LengthMetrics.vp(10),topEnd:LengthMetrics.vp(10)}
          })
        }
      }
      .padding({right:10})
      .width(BasicConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      List({space:10}){
        ForEach(this.myPlayLists,(item:PlayListModel)=>{
          PlayListItem({playList:item,deletePlayList:this.deletePlayList})
        },(item:PlayListModel)=>item.id.toString())
      }
      .padding({right:10})
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .fadingEdge(true)
      .width(BasicConstants.FULL_WIDTH)
    }
    .margin({top:20})
  }
  //所有歌单列表弹窗
  @Builder allPlayListsBuilder(){
    Column({space:10}){
      List({space:10}){
        ForEach(this.oriMyPlayLists,(item:PlayListModel)=>{
          PlayListItem({playList:item,deletePlayList:this.deletePlayList})
        },(item:PlayListModel)=>item.id.toString())
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .fadingEdge(true)
      .width(BasicConstants.FULL_WIDTH)
    }
    .padding({
      left:10,
      right:10,
      bottom:20
    })
  }
  @Builder recentSongsBuilder(){
    Column({space:10}){
      Row(){
        Row({space:5}){
          Text('最近播放')
            .fontSize(BasicConstants.FONT_SIZE_LARGE)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_default'))
          Text(`(${this.recentSongs.length})`)
            .fontSize(BasicConstants.FONT_SIZE_NORMAL)
            .fontColor($r('app.color.text_light'))
        }
        .alignItems(VerticalAlign.Center)
        Row(){
          Text('查看全部')
            .fontSize(BasicConstants.FONT_SIZE_NORMAL)
            .fontColor($r('app.color.edit'))
          Image($r('app.media.icon_arrow_right'))
            .fillColor($r('app.color.edit'))
            .width(20)
            .height(20)
        }
        .onClick(()=>{
          this.showAllRecentSongs = true
        })
        .bindSheet($$this.showAllRecentSongs, this.allRecentSongsBuilder(), {
          detents:[SheetSize.MEDIUM,SheetSize.LARGE],
          showClose:false,
          radius:{topStart:LengthMetrics.vp(10),topEnd:LengthMetrics.vp(10)}
        })
      }
      .padding({right:10})
      .width(BasicConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      List({space:10}){
        ForEach(this.recentSongs,(item:SongModel)=>{
          ListItem(){
            Column({space:5}){
              Text(item.name)
                .width(BasicConstants.FULL_WIDTH)
                .maxLines(1)
                .textOverflow({overflow:TextOverflow.Ellipsis})
                .fontSize(BasicConstants.FONT_SIZE_NORMAL)
                .fontColor($r('app.color.text_default'))
              Image(item.picUrl)
                .width(BasicConstants.FULL_WIDTH)
                .borderRadius(10)
                .onClick(()=>{
                  this.goToPlay(item)
                })
              Text(item.artistName.toString())
                .width(BasicConstants.FULL_WIDTH)
                .maxLines(1)
                .textOverflow({overflow:TextOverflow.Ellipsis})
                .fontSize(BasicConstants.FONT_SIZE_SMALL)
                .fontColor($r('app.color.text_light'))
            }
            .width('35%')
          }
        },(item:SongModel)=>item.id.toString())
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .fadingEdge(true)
      .width(BasicConstants.FULL_WIDTH)
    }
  }
  //所有最近播放列表弹窗
  @Builder allRecentSongsBuilder(){
    Column() {
      //列表头
      Row({space:10}) {
        Image($r("app.media.icon_play"))
          .width(25)
          .fillColor($r('app.color.icon_svg_selected'))
        Row() {
          Text(){
            Span('播放列表 ')
              .fontColor($r('app.color.text_default'))
              .fontSize(BasicConstants.FONT_SIZE_NORMAL)
            Span(`(${this.recentSongs.length})`)
              .fontColor($r('app.color.text_light'))
              .fontSize(BasicConstants.FONT_SIZE_SMALL)
          }
        }
        .margin({left:5})
        .layoutWeight(1)
        Image($r("app.media.icon_arrow_down"))
          .fillColor('#ffa49a9a')
          .width(25)
          .height(25)
          .onClick(() => {
            this.showAllRecentSongs = false
          })
      }
      .width(BasicConstants.FULL_WIDTH)
      .height(60)
      .alignItems(VerticalAlign.Center)
      .border({
        width: { bottom: 1 },
        color:$r('app.color.list_divider')
      })
      .padding({
        left:10,
        right:10
      })
      // 播放列表
      List() {
        ForEach(this.recentSongs, (item: SongModel) => {
          ListItem() {
            Row({space:10}) {
              Column({ space: 5 }) {
                Text(item.name)
                  .fontSize(BasicConstants.FONT_SIZE_SMALL)
                  .fontColor(item.id === this.currentSong.id ? $r('app.color.icon_svg_selected') : $r('app.color.text_default'))
                  .maxLines(1)
                  .textOverflow({overflow:TextOverflow.Ellipsis})
                Text(item.artistName.toString())
                  .fontSize(BasicConstants.FONT_SIZE_SMALL)
                  .fontColor(item.id === this.currentSong?.id ? $r('app.color.icon_svg_selected') : $r('app.color.text_light'))
                  .maxLines(1)
                  .textOverflow({overflow:TextOverflow.Ellipsis})
              }
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.Center)
            }
            .onClick(()=>{
              this.goToPlay(item)
            })
            .padding({
              left:10,
              right:10
            })
            .height(60)
            .width(BasicConstants.FULL_WIDTH)
          }
          .border({
            width: { bottom: 1 },
            color:$r('app.color.list_divider')
          })
        },(item:SongModel)=>item.id.toString())
      }
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
      .fadingEdge(true)
      .layoutWeight(1)
    }
    .width(BasicConstants.FULL_WIDTH)
    .padding({
      left:10,
      right:10
    })
  }
  @Builder recentMVsBuilder(){
    Column({space:10}){
      Row(){
        Row({space:5}){
          Text('最近观看')
            .fontSize(BasicConstants.FONT_SIZE_LARGE)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_default'))
          Text(`(${this.recentMVs.length})`)
            .fontSize(BasicConstants.FONT_SIZE_NORMAL)
            .fontColor($r('app.color.text_light'))
        }
        .alignItems(VerticalAlign.Center)
        Row(){
          Text('查看全部')
            .fontSize(BasicConstants.FONT_SIZE_NORMAL)
            .fontColor($r('app.color.edit'))
          Image($r('app.media.icon_arrow_right'))
            .fillColor($r('app.color.edit'))
            .width(20)
            .height(20)
        }
        .onClick(()=>{
          this.showAllRecentMVs = true
        })
        .bindSheet($$this.showAllRecentMVs, this.allRecentMVsBuilder(), {
          title:{title:'最近观看'},
          height:'80%',
          showClose:true,
          radius:{topStart:LengthMetrics.vp(10),topEnd:LengthMetrics.vp(10)}
        })
      }
      .width(BasicConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      MvSwiper({mvList:this.recentMVs})
    }
    .padding({right:10})
  }
  @Builder allRecentMVsBuilder(){
    Column(){
      List({space:20}){
        ForEach(this.recentMVs,(item:MVModel,index:number)=>{
          ListItem(){
            RelativeContainer(){
              Image(item.picUrl)
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
            .width(BasicConstants.FULL_WIDTH)
            .height(200)
            .borderRadius(10)
            .clip(true)
            .onClick(()=>{
              const param:mvRouterParamsModel = {
                index: index,
                mvList: this.recentMVs
              }
              router.pushUrl({
                url:'pages/PlayMV',
                params: {
                  param: param
                }
              })
            })
          }
        },(item:MVModel)=>item.id.toString())
      }
    }
    .width(BasicConstants.FULL_WIDTH)
    .padding({
      left:10,
      right:10
    })
    .margin({bottom:20})
  }

  build() {
    Stack({alignContent:Alignment.Top}){
      Scroll(){
        Column({space:30}){
          //我的歌单
          this.myPlayListBuilder()
          //最近播放
          this.recentSongsBuilder()
          //最近观看
          this.recentMVsBuilder()
        }
        .width(BasicConstants.FULL_WIDTH)
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .fadingEdge(true)
      .margin({
        top:20,
        bottom:20
      })
      TopNavBar({title:'个人中心'})
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