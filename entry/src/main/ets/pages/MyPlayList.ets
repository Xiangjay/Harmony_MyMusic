import log from "@open/log"
import { BasicConstants } from "../common/constants/BasicConstants"
import { playListDB } from "../db/playListDB"
import { LocalPlayListModel} from "../models/DataModels"
import { PromptAction, router } from "@kit.ArkUI"
import { TopNavBar } from "../components/common/TopNavBar"
import { PlayListItem } from "../components/My/PlayListItem"

//我的页面全部歌单
@Entry
@Component
export struct MyPlayList {
  @StorageProp('safeTop') safeTop: number = 0;
  @State myPlayLists:Array<LocalPlayListModel> = []
  @State showPlayListDetail:boolean = false
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();  //提示弹窗
  private toastDuration:number = 500  //提示弹窗显示时间

  getMyPlayLists = async ()=>{
    this.myPlayLists = await playListDB.queryData('PLAYLIST')
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
          const index = this.myPlayLists.findIndex(item=>item.id === id)
          const res = await playListDB.deleteDataById('PLAYLIST',id)
          if(res.code === 0){ //成功
            this.myPlayLists.splice(index,1)
            this.promptAction.showToast({
              message: res.message,
              duration: this.toastDuration
            })
          }else { //失败
            this.promptAction.showToast({
              message: res.message,
              duration: this.toastDuration
            })
          }
        }
      }
    }
    )
  }

  aboutToAppear(): void {
    this.getMyPlayLists()
  }

  @Builder myPlayListBuilder(){
    Column({space:10}){
      Row(){
        Row({space:5}){
          Text('我的歌单')
            .fontSize(BasicConstants.FONT_SIZE_LARGE)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_default'))
          Text(`(${this.myPlayLists.length})`)
            .fontSize(BasicConstants.FONT_SIZE_NORMAL)
            .fontColor($r('app.color.text_light'))
        }
        .alignItems(VerticalAlign.Center)
      }
      .width(BasicConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      List({space:10}){
        ForEach(this.myPlayLists,(item:LocalPlayListModel)=>{
          PlayListItem({playList:item,deletePlayList:this.deletePlayList})
        },(item:LocalPlayListModel)=>item.id.toString())
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .fadingEdge(true)
      .width(BasicConstants.FULL_WIDTH)
    }
    .margin({top:20})
  }

  build() {
    Stack({alignContent:Alignment.Top}){
      Scroll(){
        Column(){
          //我的歌单
          this.myPlayListBuilder()
        }
        .width(BasicConstants.FULL_WIDTH)
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .fadingEdge(true)
      .margin({
        top:20,
      })
      TopNavBar({title:'全部歌单'})
    }
    .height(BasicConstants.FULL_HEIGHT)
    .width(BasicConstants.FULL_WIDTH)
    .backgroundColor($r('app.color.content_background'))
    .padding({
      top: this.safeTop,
      left:10,
      right:10
    })
  }
}