import log from '@open/log'
import { BasicConstants } from '../../common/constants/BasicConstants'
import { playListDB } from '../../db/playListDB'
import { musicRouterParamsModel,
  PlayListModel,
  playListType, SongModel } from '../../models/DataModels'
import { PromptAction, router } from '@kit.ArkUI'
import { relationalStore } from '@kit.ArkData'
import {EditDialog} from './EditDialog'

@Extend(Text) function coverText(fontSize:number = BasicConstants.FONT_SIZE_NORMAL) {
  .fontSize(fontSize)
  .fontColor(Color.White)
  .width(BasicConstants.FULL_WIDTH)
  .maxLines(2)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

@Component
export struct PlayListItem {
  @ObjectLink playList:PlayListModel
  @Prop inWhichPage:string = 'my'
  @State showSongs:boolean = false
  private deletePlayList = (id:number)=>{}  //父组件方法
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  private toastDuration:number = 500  //弹窗显示时间
  private onSelectPlayList = (id:number)=>{}

  onCancel = ()=>{
    this.editDialogController?.close()
  }
  onChangePlayListName = async (name:string)=>{
    if(this.playList.name != name){
      const valueBucket: relationalStore.ValuesBucket = {
        NAME:name,
        SAVETIME: new Date().getTime()
      };
      const res = await playListDB.updateDataById('PLAYLIST',this.playList.id,valueBucket)
      if(res.code === 0){ //成功
        this.playList.name = name
        this.editDialogController?.close()
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
    }else{
      this.editDialogController?.close()
    }
  }
  //修改歌单名弹窗
  editDialogController: CustomDialogController | null = new CustomDialogController({
    builder: EditDialog({
      playListName: this.playList.name,
      confirm: this.onChangePlayListName,
      cancel:this.onCancel
    }),
    autoCancel: true,
    cornerRadius: 10,
  })

  deleteSong = (id:number)=>{
    this.getUIContext().showAlertDialog({
        title: '确定删除此歌曲吗？',
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
            const songs = this.playList.songs.filter(item=>item.id!=id)
            const valueBucket: relationalStore.ValuesBucket = {
              SONGS:JSON.stringify(songs),
              SAVETIME: new Date().getTime()
            };
            const res = await playListDB.updateDataById('PLAYLIST',this.playList.id,valueBucket)
            if(res.code === 0){ //成功
              this.playList.songs = songs
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
    // this.playList.songs = this.playList.songs.filter(item=>item.id!=id)
    //这里注意用常规的splice方法虽然改变了数组的长度，但是系统还是检查不到变化，只能用上面的方法改变songs的地址才能监测到
    // const index = this.playList.songs.findIndex(item=>item.id === id)
    // this.playList.songs.splice(index,1)
  }

  // 在自定义组件即将析构销毁时将dialogController置空
  aboutToDisappear() {
    this.editDialogController = null; // 将dialogController置空
  }

  @Builder playListDetailBuilder(){
    Column({space:10}){
      Row({space:10}){
        Text(this.playList.name)
          .fontSize(BasicConstants.FONT_SIZE_LARGE)
          .fontColor($r('app.color.text_default'))
          .maxLines(1)
          .textOverflow({overflow:TextOverflow.Ellipsis})
          .constraintSize({maxWidth:'80%'})
        Image($r('app.media.icon_edit'))
          .width(20)
          .height(20)
          .fillColor($r('app.color.edit'))
          .onClick(()=>{
            this.editDialogController?.open()
          })
      }
      .alignItems(VerticalAlign.Center)
      .width(BasicConstants.FULL_WIDTH)
      List(){
        ForEach(this.playList.songs,(song:SongModel,index:number)=>{
          ListItem() {
            Row({space:10}) {
              Text((index + 1).toString())
                .fontColor($r('app.color.text_light'))
                .width(30)
              Column({ space: 5 }) {
                Text(song.name)
                  .fontSize(BasicConstants.FONT_SIZE_NORMAL)
                  .fontColor($r('app.color.text_default'))
                  .maxLines(1)
                  .textOverflow({overflow:TextOverflow.Ellipsis})
                Text(song.artistName.toString())
                  .fontSize(BasicConstants.FONT_SIZE_SMALL)
                  .fontColor($r('app.color.text_light'))
                  .maxLines(1)
                  .textOverflow({overflow:TextOverflow.Ellipsis})
              }
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.Center)
              .layoutWeight(1)
              Image($r('app.media.icon_delete'))
                .width(20)
                .height(20)
                .fillColor($r('app.color.delete'))
                .onClick(()=>{
                  this.deleteSong(song.id)
                })
            }
            .height(60)
            .width(BasicConstants.FULL_WIDTH)
            .alignItems(VerticalAlign.Center)
          }
          .border({
            width: { bottom: 1 },
            color:$r('app.color.list_divider')
          })
        },(song:SongModel)=>song.id.toString())
      }
      .edgeEffect(EdgeEffect.Spring)
      .fadingEdge(true)
      .scrollBar(BarState.Off)
    }
    .padding({
      top:10,
      left:15,
      right:15
    })
    .width(BasicConstants.FULL_WIDTH)
    .height(BasicConstants.FULL_HEIGHT)
  }

  build() {
    ListItem(){
      Row({space:10}){
        Row({space:10}){
          Image(this.playList.picUrl)
            .width(100)
            .height(120)
            .borderRadius(5)
          Column(){
            Text(this.playList.name)
              .fontSize(BasicConstants.FONT_SIZE_NORMAL)
              .fontColor($r('app.color.text_default'))
              .maxLines(2)
              .textOverflow({overflow:TextOverflow.Ellipsis})
            Text(this.playList.description)
              .fontSize(BasicConstants.FONT_SIZE_SMALL)
              .fontColor($r('app.color.text_default'))
              .maxLines(2)
              .textOverflow({overflow:TextOverflow.Ellipsis})
              .opacity(0.8)
            Text(`${this.playList.songs.length} 首`)
              .fontSize(BasicConstants.FONT_SIZE_NORMAL)
              .fontColor($r('app.color.text_default'))
          }
          .height(BasicConstants.FULL_HEIGHT)
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.SpaceBetween)
          .layoutWeight(1)
        }
        .layoutWeight(1)
        .onClick(()=>{
          if(this.inWhichPage === 'my'){
            const param:musicRouterParamsModel = {
              id:this.playList.id,
              type:playListType.local,
            }
            router.pushUrl({
              url:'pages/Music',
              params: {
                param: param
              }
            })
          }else{
            this.onSelectPlayList(this.playList.id)
          }
        })
        Row({space:5}){
          if(this.inWhichPage === 'my'){
            Image($r('app.media.icon_edit'))
              .width(20)
              .height(20)
              .fillColor($r('app.color.edit'))
              .onClick(()=>{
                router.pushUrl({
                  url:'pages/CreateNewPlayList',
                  params: {
                    param: this.playList
                  }
                })
              })
            Image($r('app.media.icon_delete'))
              .width(20)
              .height(20)
              .fillColor($r('app.color.delete'))
              .onClick(()=>{
                this.deletePlayList(this.playList.id)
              })
          }
        }
      }
      .width(BasicConstants.FULL_WIDTH)
      .height(120)
    }
  }
}