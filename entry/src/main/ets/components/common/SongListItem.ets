import log from "@open/log";
import { BasicConstants } from "../../common/constants/BasicConstants";
import { PlayListModel, SongModel } from "../../models/DataModels";
import { router } from "@kit.ArkUI";

@Component
export struct SongListItem {
  @Prop song:SongModel
  @Prop currentSongId:number
  @Prop index:number
  @Prop playList:PlayListModel
  private changeSong = (index:number)=>{} //Play页面父组件方法
  private addSong2Local = (song:SongModel)=>{}  //两个页面的父组件方法
  private page:string = this.getUIContext().getRouter().getState().name

  build() {
    Row({space:10}) {
      Row(){
        if(this.song.id === this.currentSongId){
          Image($r('app.media.icon_playing'))
            .width(20)
            .fillColor($r('app.color.icon_svg_selected'))
        }else{
          Text((this.index + 1).toString())
            .fontColor($r('app.color.text_light'))
        }
      }
      .width(30)
      Row() {
        Column({ space: 5 }) {
          Text(this.song.name)
            .fontSize(BasicConstants.FONT_SIZE_SMALL)
            .fontColor(this.song.id === this.currentSongId ? $r('app.color.icon_svg_selected') : $r('app.color.text_default'))
            .maxLines(1)
            .textOverflow({overflow:TextOverflow.Ellipsis})
          Text(this.song.artistName.toString())
            .fontSize(BasicConstants.FONT_SIZE_SMALL)
            .fontColor(this.song.id === this.currentSongId ? $r('app.color.icon_svg_selected') : $r('app.color.text_light'))
            .maxLines(1)
            .textOverflow({overflow:TextOverflow.Ellipsis})
        }
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
      }
      .onClick(()=>{
        if(this.page === 'Music'){
          //跳转播放时把当前播放列表存到全局
          AppStorage.setOrCreate('currentPlayList',this.playList)
          router.pushUrl({
            url:'pages/Play',
            params:{
              param:this.song
            }
          })
        }else if(this.page === 'Play'){
          this.changeSong(this.index)
        }
      })
      .layoutWeight(1)
      Row(){
        Image($r('app.media.icon_add'))
          .width(20)
          .height(20)
          .fillColor($r('app.color.icon_svg_selected'))
          .onClick(()=>{
            this.addSong2Local(this.song)
          })
      }
    }
    .padding({
      left:10,
      right:10
    })
    .height(60)
    .width(BasicConstants.FULL_WIDTH)
    .alignItems(VerticalAlign.Center)
  }
}