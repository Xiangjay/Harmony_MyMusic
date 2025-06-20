import log from "@open/log"
import { BasicConstants } from "../common/constants/BasicConstants"
import { playListDB } from "../db/playListDB"
import {  PlayListModel } from "../models/DataModels"
import { LengthMetrics, PromptAction, router } from "@kit.ArkUI"
import { TopNavBar } from "../components/common/TopNavBar"
import { PlayListItem } from "../components/common/PlayListItem"

//我的页面
@Entry
@Component
export struct My {
  @StorageProp('safeTop') safeTop: number = 0;
  @State oriMyPlayLists:Array<PlayListModel> = []
  @State myPlayLists:Array<PlayListModel> = []
  @State showAll:boolean = false
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();  //提示弹窗

  getMyPlayLists = async ()=>{
    this.oriMyPlayLists = await playListDB.queryData('PLAYLIST')
    this.myPlayLists = this.oriMyPlayLists.slice(0,3)
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
                duration: BasicConstants.TOASTDURATION
              })
            }else { //失败
              this.promptAction.showToast({
                message: '删除歌单失败',
                duration: BasicConstants.TOASTDURATION
              })
            }
          }
        }
      }
    )
  }

  onPageShow(): void {
    this.getMyPlayLists()
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
              this.showAll = true
            }
          })
          .bindSheet($$this.showAll, this.allPlayListsBuilder(), {
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

  build() {
    Stack({alignContent:Alignment.Top}){
      Scroll(){
        Column({space:30}){
          //我的歌单
          this.myPlayListBuilder()
        }
        .width(BasicConstants.FULL_WIDTH)
        .height(BasicConstants.FULL_HEIGHT)
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