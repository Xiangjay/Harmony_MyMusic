import { router } from "@kit.ArkUI";
import { BasicConstants } from '../common/constants/BasicConstants'
import {
  getSongListSongsById,
  getSongUrlByIds,
  getSongListDetailById
} from '../common/apis/MusicApis'
import { Empty } from "../components/common/Empty";
import log from '@open/log'
import { countTransform,myDataMerge, SpecificKey} from "../common/utils/CommonTools";
import {routerParamsType,PlayListModel,SongModel} from '../models/DataModels'
import { Loading } from "../components/common/Loading";

@Extend(Text) function coverText(fontSize:number) {
  .fontSize(fontSize)
  .fontColor(Color.White)
  .width(BasicConstants.FULL_WIDTH)
  .maxLines(2)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}
@Entry
@Component
struct Music {
  private params = router.getParams()
  @State playListId:number = 0
  @State noList: boolean = false
  @State playList: PlayListModel = new PlayListModel() //程序需要的数据类型
  @State isLoading: boolean = true
  //播放列表弹窗用
  @State songListHeight: string = '0%'
  @State songListOpacity: number = 0
  private animationDuration:number = 300
  @StorageLink('currentSong') currentSong: SongModel = new SongModel()
  //通过传过来的歌单ID获取歌单里所有歌曲
  getSongListDetail = async () => {
    //获取歌单详细信息
    const responsePlayList = await getSongListDetailById<PlayListModel, null>(this.playListId)
    const playListSpecificKeys:SpecificKey[] = [
      {
        specificKey:'picUrl',
        sourceKey:'coverImgUrl'
      }
    ]
    this.playList = myDataMerge<PlayListModel>(this.playList,responsePlayList.playlist,playListSpecificKeys)
    //获取歌单里所有歌曲，这里只能拿到歌曲的ID、名字、作者、专辑
    const responseSongListSongs = await getSongListSongsById<Array<SongModel>, null>(this.playListId)
    //拿到歌单里所有歌曲的ID
    let songIds: number[] = []
    //用于数据转换的时候把source里的指定key的值赋值到target里特定的key
    const songSpecificKeys:SpecificKey[] = [
      {
        specificKey:'artists',
        sourceKey:'ar'
      },
      {
        specificKey:'album',
        sourceKey:'al'
      },
      {
        specificKey:'duration',
        sourceKey:'dt'
      }
    ]
    //处理下拿到的歌曲的数据格式
    this.playList.songs = []  //这里需要让歌单里的歌曲变化地址，不然监测不到变化页面不会重新渲染，如果弹窗的list是子组件，那应该可以用@Observed和@ObjectLink
    responseSongListSongs.songs.forEach((item: SongModel) => {
      this.playList.songs.push(myDataMerge<SongModel>(new SongModel(),item,songSpecificKeys))
      //保存所有歌曲ID，用于后续获取歌曲URL
      songIds.push(item.id)
    })
    //处理歌曲图片和歌手名字
    this.playList.songs.forEach((song:SongModel)=>{
      song.showPic = song.album.picUrl
      if(song.artists.length > 1){
        song.artists.forEach(item=>{
          song.showArtists.push(item.name)
        })
      }else{
        song.showArtists.push(song.artists[0].name)
      }
    })
    //通过歌曲ID获取歌曲播放URL
    const responseSongUrls = await getSongUrlByIds<Array<SongModel>, null>(songIds)
    //把拿到的歌曲url赋值到对应的歌曲里，这里其实可以一个循环this.playList.songs[index].url = item.url就行，但是为了以防万一顺序错乱，还是严谨点用两个循环判断下ID
    responseSongUrls.data.forEach(item=>{
      this.playList.songs.forEach((song:SongModel)=>{
        if(item.id === song.id){
          song.url = item.url
        }
      })
    })
    this.isLoading = false
    if(!this.isLoading){
      this.songListHeight = '60%'
      this.songListOpacity = 1
    }
    log.info(this.playList)
  }
  addList2ToLocal = ()=>{

  }
  addSong2Local = ()=>{

  }
  aboutToAppear(): void {
    try {
      this.playListId = (this.params as routerParamsType<number>).value
      this.getSongListDetail()
    } catch {
      this.noList = true
    }
  }

  @Builder coverBuilder() {
    Row() {
      Column() {
        Image(this.playList.picUrl)
          .borderRadius(5)
          .width(BasicConstants.FULL_WIDTH)
      }
      .width(120)
      Column() {
        Text(this.playList.name)
          .coverText(BasicConstants.FONT_SIZE_LARGE)
        Text(this.playList.tags.toString())
          .coverText(BasicConstants.FONT_SIZE_SMALL)
          .opacity(0.6)
        Text(this.playList!.description)
          .coverText(BasicConstants.FONT_SIZE_NORMAL)
          .opacity(0.8)
      }
      .padding({
        left: 10,
        right: 10,
        top: 5,
        bottom: 5
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .layoutWeight(1)
      .height(120)
    }
    .alignItems(VerticalAlign.Top)
    .width(BasicConstants.FULL_WIDTH)
  }
  @Styles coverButtons(){
    .width('30%')
    .backgroundColor('#32ffffff')
    .padding({
      top:10,
      bottom:10,
      left:20,
      right:20
    })
  }
  @Builder coverButtonsBuilder() {
    Row(){
      Button(){
        Row(){
          Image($r('app.media.icon_share'))
            .width(20)
          Text(countTransform(this.playList.shareCount,false))
            .fontColor('#ffffff')
            .margin({left:5})
        }
        .justifyContent(FlexAlign.Center)
      }
      .coverButtons()
      Button(){
        Row(){
          Image($r('app.media.icon_comment'))
            .width(20)
          Text(countTransform(this.playList!.subscribedCount,false))
            .fontColor('#ffffff')
            .margin({left:5})
        }
        .justifyContent(FlexAlign.Center)
      }
      .coverButtons()
      Button(){
        Row(){
          Image($r('app.media.icon_add_track'))
            .width(20)
          Text(countTransform(this.playList.trackCount,false))
            .fontColor('#ffffff')
            .margin({left:5})
        }
        .justifyContent(FlexAlign.Center)
      }
      .coverButtons()
    }
    .margin({top:10})
    .width(BasicConstants.FULL_WIDTH)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }
  @Builder songListBuilder(){
    Column(){
      //列表头
      Row(){
        Image($r("app.media.icon_play"))
          .width(25)
          .fillColor($r('app.color.icon_svg_selected'))
        Row() {
          Text(){
            Span('播放列表 ')
              .fontColor($r('app.color.text_default'))
              .fontSize(BasicConstants.FONT_SIZE_NORMAL)
            Span(`(${this.playList?.songs?.length})`)
              .fontColor('#ffa49a9a')
              .fontSize(BasicConstants.FONT_SIZE_SMALL)
          }
        }
        .margin({left:5})
        .layoutWeight(1)
        Image($r("app.media.icon_add_track"))
          // .fillColor('#ffa49a9a')
          .fillColor($r('app.color.icon_svg_selected'))
          .width(25)
          .height(25)
          .onClick(()=>{
            this.addList2ToLocal()
          })
      }
      .padding({
        left:15,
        right:15
      })
      .width(BasicConstants.FULL_WIDTH)
      .height(60)
      .alignItems(VerticalAlign.Center)
      .border({
        width: { bottom: 1 },
        color: '#12ec5c87'
      })
      .borderRadius({
        topLeft: 5,
        topRight: 5
      })
      // 播放列表
      List() {
        ForEach(this.playList?.songs, (item: SongModel, index: number) => {
          ListItem() {
            Row({space:10}) {
              Row(){
                if(item.id === this.currentSong?.id){
                  Image($r('app.media.icon_playing'))
                    .width(20)
                    .fillColor($r('app.color.icon_svg_selected'))
                }else{
                  Text((index + 1).toString())
                    .fontColor('#ffa49a9a')
                }
              }
              .width(20)
              Row() {
                Column({ space: 5 }) {
                  Text(item.name)
                    .fontSize(BasicConstants.FONT_SIZE_SMALL)
                    .fontColor(item.id === this.currentSong?.id ? $r('app.color.icon_svg_selected') : $r('app.color.text_default'))
                    .maxLines(1)
                    .textOverflow({overflow:TextOverflow.Ellipsis})
                  Text(item.showArtists.toString())
                    .fontSize(BasicConstants.FONT_SIZE_SMALL)
                    .fontColor(item.id === this.currentSong?.id ? $r('app.color.icon_svg_selected') : '#ffa49a9a')
                    .maxLines(1)
                    .textOverflow({overflow:TextOverflow.Ellipsis})
                }
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Center)
              }
              .layoutWeight(1)
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
              Row(){
                Image($r('app.media.icon_add'))
                  .width(20)
                  .height(20)
                  .fillColor($r('app.color.icon_svg_selected'))
                  .onClick(()=>{
                    this.addSong2Local()
                  })
              }
            }
            .height(50)
            .width(BasicConstants.FULL_WIDTH)
            .padding({
              left:15,
              right:15
            })
            .alignItems(VerticalAlign.Center)
          }
          .border({
            width: { bottom: 1 },
            color: '#12ec5c87'
          })
        })
      }
      .edgeEffect(EdgeEffect.None)
      .fadingEdge(true)
      .layoutWeight(1)
    }
    .height(this.songListHeight)
    .opacity(this.songListOpacity)
    .animation({
      duration:this.animationDuration,
    })
    .width(BasicConstants.FULL_WIDTH)
    .backgroundColor($r('app.color.content_background'))
    // .backgroundColor('#32ffffff')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  build() {
    if (!this.noList) {
      Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: this.isLoading ? Alignment.Center : Alignment.Top }) {
          Image(this.playList?.picUrl)
            .width(BasicConstants.FULL_WIDTH)
            .height(BasicConstants.FULL_HEIGHT)
            .blur(1000)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          if (this.isLoading) {
            Loading()
          } else {
            //头部部分
            Column({ space: 10 }) {
              //后退按钮
              Row() {
                Image($r('app.media.icon_back'))
                  .width(30)
                  .height(30)
                  .fillColor(Color.White)
                  .onClick(() => {
                    router.back()
                  })
              }
              .justifyContent(FlexAlign.Start)
              .width(BasicConstants.FULL_WIDTH)
              //封面
              this.coverBuilder()
              //按钮
              this.coverButtonsBuilder()
            }
            .padding({
              left: 10,
              right: 10
            })
            .width(BasicConstants.FULL_WIDTH)
            .height('40%')
          }
        }

        //歌单里歌曲列表
        this.songListBuilder()
      }
      .backgroundColor($r('app.color.window_background'))
      .height(BasicConstants.FULL_HEIGHT)
      .width(BasicConstants.FULL_WIDTH)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    } else {
      Empty({ message: '暂无可播放歌单' })
    }
  }
}