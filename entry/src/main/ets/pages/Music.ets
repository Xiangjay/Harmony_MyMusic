import { PromptAction, router } from "@kit.ArkUI";
import { BasicConstants } from '../common/constants/BasicConstants'
import {
  getSongListSongsById,
  getSongUrlByIds,
  getSongListDetailById,
  getAlbumDetailById,
  getAlbumDynamicById
} from '../common/apis/MusicApis'
import { Empty } from "../components/common/Empty";
import { countTransform, formatData, myDataMerge, SpecificKey} from "../common/utils/CommonTools";
import {routerParams,PlayListModel,SongModel,musicRouterParamsModel,playListType, commentsRouterParamsModel} from '../models/DataModels'
import { Loading } from "../components/common/Loading";
import { TopNavBar } from "../components/common/TopNavBar";
import { MyLazyDataSource } from "../common/utils/MyLazyDataSource";


@Extend(Text) function coverText(fontSize:number = BasicConstants.FONT_SIZE_NORMAL) {
  .fontSize(fontSize)
  .fontColor(Color.White)
  .width(BasicConstants.FULL_WIDTH)
  .maxLines(2)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

@Entry
@Component
struct Music {
  @StorageProp('safeTop') safeTop: number = 0;
  @State routerParams:musicRouterParamsModel = new musicRouterParamsModel()
  @State noList: boolean = false
  @State playList: PlayListModel = new PlayListModel() //程序需要的数据类型
  @State playListType:playListType = playListType.playList  //歌单或者专辑
  @State isLoading: boolean = true
  //播放列表弹窗用
  @State songListHeight: string = '0%'
  @State songListOpacity: number = 0
  private animationDuration:number = 300
  @StorageLink('currentSong') currentSong: SongModel = new SongModel()  //当前正在播放的歌曲
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();  //提示弹窗
  //懒加载数据
  private musicLazyData:MyLazyDataSource<SongModel> = new MyLazyDataSource()

  //通过传过来的歌单ID获取歌单里所有歌曲
  getPlayListDetail = async (id:number) => {
    //获取歌单详细信息
    const responsePlayList = await getSongListDetailById<PlayListModel, null>(id)
    const playListSpecificKeys:SpecificKey[] = [
      {
        specificKey:'picUrl',
        sourceKey:'coverImgUrl'
      }
    ]
    this.playList = myDataMerge<PlayListModel>(this.playList,responsePlayList.playlist,playListSpecificKeys)
    //获取歌单里所有歌曲，这里只能拿到歌曲的ID、名字、作者、专辑
    const responseSongListSongs = await getSongListSongsById<Array<SongModel>, null>(id)
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
    //把数据放入懒加载数据类型中
    this.musicLazyData.pushAllData(this.playList.songs)
    this.isLoading = false
    this.songListHeight = '65%'
    this.songListOpacity = 1
  }
  //通过传过来的专辑ID获取专辑详细
  getAlbumDetail = async (id:number) =>{
    //先拿专辑基本信息
    const resAlbum = await getAlbumDetailById<PlayListModel,null>(id)
    this.playList = myDataMerge<PlayListModel>(new PlayListModel(),resAlbum.album)
    //处理下格式，不然页面渲染不出来
    if(this.playList.description.indexOf('\n') > -1){
      this.playList.description = this.playList.description.replaceAll('\n','')
    }
    //获取专辑动态信息（评论数，分享数）
    const resDynamic = await getAlbumDynamicById<PlayListModel,null>(id)
    this.playList = myDataMerge<PlayListModel>(this.playList,resDynamic)
    //再拿专辑里的歌曲
    const resSongs = await getAlbumDetailById<Array<SongModel>,null>(id)
    const songIds:number[] = []
    this.playList.songs = []
    const specificKeys:SpecificKey[] = [
      {
        specificKey:'duration',
        sourceKey:'dt'
      }
    ]
    resSongs.songs.forEach((item: SongModel) => {
      this.playList.songs.push(myDataMerge<SongModel>(new SongModel(),item,specificKeys))
      //保存所有歌曲ID，用于后续获取歌曲URL
      songIds.push(item.id)
    })
    //通过歌曲ID获取歌曲播放URL
    const responseSongUrls = await getSongUrlByIds<Array<SongModel>, null>(songIds)
    //把拿到的歌曲url赋值到对应的歌曲里
    responseSongUrls.data.forEach(item=>{
      this.playList.songs.forEach((song:SongModel)=>{
        if(item.id === song.id){
          song.url = item.url
          song.showPic = this.playList.picUrl //把专辑封面当做歌曲图片放进去
        }
      })
    })
    //把数据放入懒加载数据类型中
    this.musicLazyData.pushAllData(this.playList.songs)
    this.isLoading = false
    this.songListHeight = '65%'
    this.songListOpacity = 1
  }

  addList2ToLocal = ()=>{

  }
  addSong2Local = ()=>{

  }
  goToComments = () =>{
    if (this.playList.commentCount != 0) {
      const param:commentsRouterParamsModel = {
        id:this.playList.id,
        type: this.playListType,
        detail:this.playList
      }
      router.pushUrl({
        url:'pages/Comments',
        params: {
          param: param
        }
      })
    }else {
      this.promptAction.showToast({
        message: '暂无评论',
        duration: 2000
      })
    }
  }

  aboutToAppear(): void {
    try {
      this.routerParams = (router.getParams() as routerParams<musicRouterParamsModel>).param
      this.playListType = this.routerParams.type
      if(this.playListType === playListType.playList){
        this.getPlayListDetail(this.routerParams.id)
      }else if(this.playListType === playListType.album){
        this.getAlbumDetail(this.routerParams.id)
      }
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
          .height(120)
      }
      .width(120)
      Column() {
        Text(this.playList.name)
          .coverText(BasicConstants.FONT_SIZE_LARGE)
        Text(this.playList.tags!.toString() || formatData(this.playList.publishTime!) + ' 发行')
          .coverText(BasicConstants.FONT_SIZE_SMALL)
          .opacity(0.6)
        Text(this.playList.description)
          .coverText()
          .opacity(0.8)
      }
      .padding({
        left: 10,
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
    Row({space:30}){
      Button(){
        Row(){
          Image($r('app.media.icon_share'))
            .width(20)
          Text(this.playList.shareCount != 0 ? countTransform(this.playList.shareCount,false) : '分享')
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
          Text(this.playList.commentCount != 0 ? countTransform(this.playList!.commentCount,false) : '评论')
            .fontColor('#ffffff')
            .margin({left:5})
        }
        .justifyContent(FlexAlign.Center)
      }
      .coverButtons()
      .onClick(()=>{
        this.goToComments()
      })
      // Button(){
      //   Row(){
      //     Image($r('app.media.icon_add_track'))
      //       .width(20)
      //     Text(this.playList.trackCount != 0 ? countTransform(this.playList.trackCount,false) : '收藏')
      //       .fontColor('#ffffff')
      //       .margin({left:5})
      //   }
      //   .justifyContent(FlexAlign.Center)
      // }
      // .coverButtons()
    }
    .margin({top:10})
    .width(BasicConstants.FULL_WIDTH)
    .justifyContent(FlexAlign.Center)
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
              .fontColor($r('app.color.text_light'))
              .fontSize(BasicConstants.FONT_SIZE_SMALL)
          }
        }
        .margin({left:5})
        .layoutWeight(1)
        Image($r("app.media.icon_add_track"))
          .fillColor($r('app.color.icon_svg_selected'))
          .width(25)
          .height(25)
          .onClick(()=>{
            this.addList2ToLocal()
          })
      }
      .padding({
        left:10,
        right:10
      })
      .width(BasicConstants.FULL_WIDTH)
      .height(60)
      .alignItems(VerticalAlign.Center)
      .border({
        width: { bottom: 1 },
        color:$r('app.color.list_divider')
      })
      // 播放列表
      List() {
        LazyForEach(this.musicLazyData, (item: SongModel, index: number) => {
          ListItem() {
            Row({space:10}) {
              Row(){
                if(item.id === this.currentSong?.id){
                  Image($r('app.media.icon_playing'))
                    .width(20)
                    .fillColor($r('app.color.icon_svg_selected'))
                }else{
                  Text((index + 1).toString())
                    .fontColor($r('app.color.text_light'))
                }
              }
              .width(30)
              Row() {
                Column({ space: 5 }) {
                  Text(item.name)
                    .fontSize(BasicConstants.FONT_SIZE_NORMAL)
                    .fontColor(item.id === this.currentSong?.id ? $r('app.color.icon_svg_selected') : $r('app.color.text_default'))
                    .maxLines(1)
                    .textOverflow({overflow:TextOverflow.Ellipsis})
                  Text(item.showArtists.toString() || this.playList.artist?.name)
                    .fontSize(BasicConstants.FONT_SIZE_SMALL)
                    .fontColor(item.id === this.currentSong?.id ? $r('app.color.icon_svg_selected') : $r('app.color.text_light'))
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
                    param:item
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
            .padding({
              left:10,
              right:10
            })
            .height(60)
            .width(BasicConstants.FULL_WIDTH)
            .alignItems(VerticalAlign.Center)
          }
          .border({
            width: { bottom: 1 },
            color:$r('app.color.list_divider')
          })
        },(item:SongModel)=>item.id.toString())
      }
      .edgeEffect(EdgeEffect.Spring)
      .fadingEdge(true)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .height(this.songListHeight)
    .opacity(this.songListOpacity)
    .padding({
      left:10,
      right:10
    })
    .animation({
      duration:this.animationDuration,
    })
    .width(BasicConstants.FULL_WIDTH)
    .backgroundColor($r('app.color.main_tab_background'))
  }

  build() {
    if (!this.noList) {
      Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: this.isLoading ? Alignment.Center : Alignment.Top }) {
          Image(this.playList?.picUrl)
            .width(BasicConstants.FULL_WIDTH)
            .height(BasicConstants.FULL_HEIGHT)
            .blur(1000)
          if (this.isLoading) {
            Loading()
          } else {
            Column({ space: 10 }) {
              //后退按钮
              TopNavBar({title:'音乐',color:'#ffffff'})
              //封面
              this.coverBuilder()
              //按钮
              this.coverButtonsBuilder()
            }
            .padding({
              top:this.safeTop,
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
      .height(BasicConstants.FULL_HEIGHT)
      .width(BasicConstants.FULL_WIDTH)
    } else {
      Column(){
        Empty({ message: '暂无可播放歌单' })
      }
      .height(BasicConstants.FULL_HEIGHT)
      .width(BasicConstants.FULL_WIDTH)
      .backgroundColor($r('app.color.content_background'))
      .padding({
        top: this.safeTop
      })
    }
  }
}