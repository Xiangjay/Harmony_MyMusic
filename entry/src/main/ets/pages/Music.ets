import { router } from "@kit.ArkUI";
import { BasicConstants } from '../common/constants/BasicConstants'
import {
  songModel,
  responseSongList,
  routerParamsType,
  responseSongUrl,
  playListModel,
  recommendSongList,
  artist,
  songDetail
} from "../models/DataModel";
import {
  getSongListSongsById,
  getSongUrlByIds,
  getSongDetailByIds,
  getSongListDetailById
} from '../common/apis/MusicApis'
import { Empty } from "../components/Empty";
import log from '@open/log'
import { countTransform } from "../common/utils/CommonTools";

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
  @State noList: boolean = false
  @State songList: recommendSongList | null = null
  @State playList: playListModel = new playListModel() //程序需要的数据类型
  @State isLoading: boolean = true
  //播放列表弹窗用
  @State songListHeight: string = '0%'
  @State songListOpacity: number = 0
  private animationDuration:number = 300
  @StorageLink('currentSong') currentSong: songModel = new songModel()
  //通过传过来的歌单ID获取歌单里所有歌曲
  getSongListDetail = async () => {
    //获取歌单详细信息
    const responseSongList = await getSongListDetailById<recommendSongList, null>(this.playList.id)
    //本页面需要渲染的数据
    this.songList!.description = responseSongList.playlist.description
    this.songList!.tags = responseSongList.playlist.tags
    this.songList!.subscribedCount = responseSongList.playlist.subscribedCount
    this.songList!.shareCount = responseSongList.playlist.shareCount
    this.songList!.trackCount = responseSongList.playlist.trackCount

    //获取歌单里所有歌曲
    const responseSongListSongs = await getSongListSongsById<Array<responseSongList>, null>(this.playList.id)
    //拿到歌单里所有歌曲的ID
    let songIds: number[] = []
    responseSongListSongs.songs.forEach((item: responseSongList) => {
      songIds.push(item.id)
    })
    //通过歌曲ID获取歌曲播放URL
    const responseSongUrls = await getSongUrlByIds<Array<responseSongUrl>, null>(songIds)
    //把从后端拿到的数据处理成页面需要的数据类型playListModelTest
    this.playList.songs = []
    responseSongListSongs.songs.forEach((item: responseSongList) => {
      //处理歌手信息，用于页面展示
      const artists: string[] = []
      if (item.ar.length > 1) {
        item.ar.forEach((ar: artist) => {
          artists.push(ar.name)
        })
      } else {
        artists.push(item.ar[0].name)
      }
      //整理歌曲数据
      const song: songModel = {
        id: item.id,
        name: item.name,
        artists: item.ar,
        album: item.al,
        showArtists: artists,
        isPlaying: true,
        time: 0,
        duration: 0,
        url: '', //这里面拿不到url，所以先设置为空
      }
      this.playList.songs.push(song)
    })
    responseSongUrls.data.forEach(item => { //这有URL了，通过歌曲Id把对应的URL赋值进去
      this.playList.songs.forEach(song => {
        if (song.id === item.id) {
          song.url = item.url
        }
      })
    })
    //获取歌曲详细信息
    const responseSongDetail = await getSongDetailByIds<Array<songDetail>, null>(songIds)
    responseSongDetail.songs.forEach((item: songDetail) => {
      this.playList.songs.forEach(song => {
        if (song.id === item.id) {
          song.duration = item.dt //获取歌曲总时长
          song.showPic = item.al?.picUrl //获取歌曲专辑封面图片
        }
      })
    })
    this.isLoading = false
    if(!this.isLoading){
      this.songListHeight = '60%'
      this.songListOpacity = 1
    }
  }
  addList2ToLocalPlayList = ()=>{

  }
  addSong2LocalPlayList = ()=>{

  }
  aboutToAppear(): void {
    try {
      this.songList = (this.params as routerParamsType<recommendSongList>).value
      this.playList.id = this.songList.id
      this.playList.name = this.songList.name
      this.getSongListDetail()
    } catch {
      this.noList = true
    }
  }

  @Builder loadingBuilder() {
    Row() {
      Image($r('app.media.loading'))
        .width(50)
      Text('努力加载中......')
        .fontSize(BasicConstants.FONT_SIZE_NORMAL)
        .fontColor('#91ee91')
        .margin({ right: 10 })
    }
    .clip(true)
    .borderRadius(5)
    .backgroundColor('#ffffff')
  }
  @Builder coverBuilder() {
    Row() {
      Column() {
        Image(this.songList?.picUrl)
          .borderRadius(5)
          .width(BasicConstants.FULL_WIDTH)
      }
      .width(120)
      Column() {
        Text(this.songList?.name)
          .coverText(BasicConstants.FONT_SIZE_LARGE)
        Text(this.songList?.tags.toString())
          .coverText(BasicConstants.FONT_SIZE_SMALL)
          .opacity(0.6)
        Text(this.songList?.description)
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
          Text(countTransform(this.songList!.shareCount,false))
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
          Text(countTransform(this.songList!.subscribedCount,false))
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
          Text(countTransform(this.songList!.trackCount,false))
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
            Span(`(${this.playList.songs.length})`)
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
            this.addList2ToLocalPlayList()
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
        ForEach(this.playList.songs, (item: songModel, index: number) => {
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
                    this.addSong2LocalPlayList()
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
          Image(this.songList?.picUrl)
            .width(BasicConstants.FULL_WIDTH)
            .height(BasicConstants.FULL_HEIGHT)
            .blur(1000)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          if (this.isLoading) {
            this.loadingBuilder()
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