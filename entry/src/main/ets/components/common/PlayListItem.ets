import log from '@open/log'
import { BasicConstants } from '../../common/constants/BasicConstants'
import { musicRouterParamsModel, PlayListModel, playListType } from '../../models/DataModels'
import { router} from '@kit.ArkUI'

@Extend(Text) function coverText(fontSize:number = BasicConstants.FONT_SIZE_NORMAL) {
  .fontSize(fontSize)
  .fontColor($r('app.color.text_default'))
  .width(BasicConstants.FULL_WIDTH)
  .maxLines(2)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

@Component
export struct PlayListItem {
  @ObjectLink playList:PlayListModel
  @State showSongs:boolean = false
  private deletePlayList = (id:number)=>{}  //my页面的父组件方法
  private onSelectPlayList = (id:number)=>{}  //music页面的父组件方法
  private page:string = this.getUIContext().getRouter().getState().name

  build() {
    ListItem(){
      Row({space:10}){
        Row({space:10}){
          Image(this.playList.picUrl)
            .width(100)
            .height(120)
            .borderRadius(5)
          Column(){
            Column({space:5}){
              Text(this.playList.name)
                .coverText()
              Text(this.playList.description)
                .coverText(BasicConstants.FONT_SIZE_SMALL)
                .opacity(0.8)
              Text(this.playList.tags.toString())
                .coverText(BasicConstants.FONT_SIZE_SMALL)
                .opacity(0.6)
            }
            .alignItems(HorizontalAlign.Start)
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
          if(this.page === 'My'){
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
          }else if(this.page === 'Music'){
            this.onSelectPlayList(this.playList.id)
          }
        })
        Row({space:5}){
          if(this.page === 'My'){
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