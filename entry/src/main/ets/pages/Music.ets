import { router } from "@kit.ArkUI";
import {BasicConstants} from '../common/constants/BasicConstants'
import {songModel, responseSongList,routerParamsType, responseSongUrl,
  playListModel, recommendSongList,artist,songDetail} from "../models/DataModel";
import {getSongListDetailById,getSongUrlByIds,getSongDetailByIds} from '../common/apis/MusicApis'

@Entry
@Component
struct Music {
  private params = router.getParams()
  @State songList:recommendSongList | null = null
  @State playList:playListModel = new playListModel()
  @State isLoading:boolean = true

  //通过传过来的歌单ID获取歌单里所有歌曲
  getSongListDetail = async () =>{
    //获取歌单里所有歌曲
    const responseSongList = await getSongListDetailById<Array<responseSongList>,null>(this.playList.id)
    //拿到歌单里所有歌曲的ID
    let songIds:number[] = []
    responseSongList.songs.forEach((item:responseSongList)=>{
      songIds.push(item.id)
    })
    //通过歌曲ID获取歌曲播放URL
    const responseSongUrls = await getSongUrlByIds<Array<responseSongUrl>,null>(songIds)
    //把从后端拿到的数据处理成页面需要的数据类型playListModelTest
    this.playList.songs = []
    responseSongList.songs.forEach((item:responseSongList)=>{
      //处理歌手信息，用于页面展示
      const artists:string[] = []
      if(item.ar.length>1){
        item.ar.forEach((ar:artist)=>{
          artists.push(ar.name)
        })
      }else{
        artists.push(item.ar[0].name)
      }
      //整理歌曲数据
      const song:songModel = {
        id:item.id,
        name:item.name,
        artists:item.ar,
        album:item.al,
        showArtists:artists,
        isPlaying:true,
        time:0,
        duration:0,
        url:'', //这里面拿不到url，所以先设置为空
      }
      this.playList.songs.push(song)
    })
    responseSongUrls.data.forEach(item=>{  //这有URL了，通过歌曲Id把对应的URL赋值进去
      this.playList.songs.forEach(song=>{
        if(song.id === item.id){
          song.url = item.url
        }
      })
    })

    //获取歌曲详细信息
    const responseSongDetail = await getSongDetailByIds<Array<songDetail>,null>(songIds)
    responseSongDetail.songs.forEach((item:songDetail)=>{
      this.playList.songs.forEach(song=>{
        if(song.id === item.id){
          song.duration = item.dt //获取歌曲总时长
          song.showPic = item.al?.picUrl  //获取歌曲专辑封面图片
        }
      })
    })
    this.isLoading = false
  }

  aboutToAppear(): void {
    this.songList = (this.params as routerParamsType<recommendSongList>).value
    this.playList.id = this.songList.id
    this.playList.name = this.songList.name
    this.getSongListDetail()
  }

  @Builder topCoverBuilder(){
    Stack({alignContent:Alignment.BottomStart}){
      Image(this.songList?.picUrl)
        .width(BasicConstants.FULL_WIDTH)
        .height('40%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      Text(this.songList?.name)
        .backgroundColor($r('app.color.label_background'))
        .fontSize(BasicConstants.FONT_SIZE_NORMAL)
        .fontColor($r('app.color.label_text'))
        .width(BasicConstants.FULL_WIDTH)
        .padding(10)
    }
  }

  @Builder songListBuilder(){
    Column(){
      Row(){
        Text(`当前播放列表`)
          .fontSize(BasicConstants.FONT_SIZE_LARGE)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_default'))
        Text(`(${this.playList.songs.length.toString()})`)
          .fontColor($r('app.color.text_gray'))
          .fontSize(BasicConstants.FONT_SIZE_SMALL)
          .margin({left:5})
      }
      .alignItems(VerticalAlign.Center)
      List(){
        ForEach(this.playList.songs,(item:songModel)=>{
          ListItem(){
            Row(){
              Column(){
                Row({space:5}){
                  // if(item.isPlaying === true){
                  //   Image($r('app.media.icon_wave'))
                  //     .width(20)
                  //     .height(20)
                  // }
                  Text(item.name)
                    .fontSize(BasicConstants.FONT_SIZE_NORMAL)
                    .fontColor($r('app.color.text_default'))
                    .maxLines(1)
                    .textOverflow({overflow:TextOverflow.Ellipsis})
                    .width(BasicConstants.FULL_WIDTH)
                }
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.Start)
              }
              .width('50%')
              Text(item.showArtists?.toString())
                .fontColor($r('app.color.text_default'))
                .fontSize(BasicConstants.FONT_SIZE_SMALL)
                .maxLines(1)
                .textOverflow({overflow:TextOverflow.Ellipsis})
                .width('50%')
                .textAlign(TextAlign.End)
            }
            .padding({
              left:10,
              right:10
            })
            .height(40)
            .width(BasicConstants.FULL_WIDTH)
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(()=>{
              //跳转播放时把当前播放列表存到全局
              AppStorage.setOrCreate('currentPlayList',this.playList)
              router.pushUrl({
                url:'pages/Play',
                params:{
                  value:item
                }
              })
            })
          }
        },(item:songModel)=>item.id.toString())
      }
      .divider({
        strokeWidth:1,
        color:$r('app.color.content_background'),
      })
      .edgeEffect(EdgeEffect.None)
      .fadingEdge(true)
    }
  }
  build() {
    Column({space:20}){
      //歌单封面
      this.topCoverBuilder()
      //歌单歌曲列表
      this.songListBuilder()
    }
    .backgroundColor($r('app.color.window_background'))
    .height(BasicConstants.FULL_HEIGHT)
    .width(BasicConstants.FULL_WIDTH)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}