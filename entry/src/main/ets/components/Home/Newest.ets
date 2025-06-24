import { getNewestAlbumsList, getNewestMVList, getNewestSongs } from '../../common/apis/HomeApis'
import { BasicConstants } from '../../common/constants/BasicConstants'
import {Title} from '../common/Title'
import {PlayListModel,MVModel,musicRouterParamsModel, PlayListType, SongModel, areaSongs} from '../../models/DataModels'
import { myDataMerge } from '../../common/utils/CommonTools'
import { Loading } from '../common/Loading'
import { LengthMetrics, router } from '@kit.ArkUI'
import { MvSwiper } from '../common/MvSwiper'
import { getSongUrlByIds } from '../../common/apis/MusicApis'
import { MyLazyDataSource } from '../../common/utils/MyLazyDataSource'

@Component
export struct Newest {
  @State newestAlbumsList:Array<PlayListModel> = []
  @State newestSongs: Array<areaSongs> = []
  @State tempPlayList:PlayListModel = new PlayListModel()
  @State showAllSongs:boolean = false
  @State shownAreaSongs:MyLazyDataSource<SongModel> = new MyLazyDataSource()
  @State shownArea:string = ''
  @State newestMVList:Array<MVModel> = []
  @State isLoading:boolean = true

  //获取最新专辑
  getNewestAlbumsList = async () =>{
    const res = await getNewestAlbumsList<Array<PlayListModel>,null>()
    res.albums.forEach(item=>{
      this.newestAlbumsList.push(myDataMerge<PlayListModel>(new PlayListModel(),item))
    })
    return Promise.resolve(true)
  }
  //获取新歌速递
  /*
   * type : 地区
      全部:0,华语:7,欧美:96,日本:8,韩国:16
  */
  getNewestSongs = async () =>{
    const resChina = await getNewestSongs<Array<SongModel>,null>()
    const chinaSongs:Array<SongModel> = []
    resChina.data.slice(0,50).forEach((item:SongModel)=>{
      chinaSongs.push(myDataMerge(new SongModel(),item))
    })
    this.handleSongs(chinaSongs,'华语')
    const resEurope = await getNewestSongs<Array<SongModel>,null>(96)
    const europeSongs:Array<SongModel> = []
    resEurope.data.slice(0,50).forEach((item:SongModel)=>{
      europeSongs.push(myDataMerge(new SongModel(),item))
    })
    this.handleSongs(europeSongs,'欧美')
    const responseResult = await Promise.all([getNewestSongs<Array<SongModel>,null>(8),getNewestSongs<Array<SongModel>,null>(16)])
    const resJapan = responseResult[0].data.concat(responseResult[1].data)
    resJapan.sort((a,b)=>{
      return b.album.publishTime - a.album.publishTime
    })
    const japanSongs:Array<SongModel> = []
    resJapan.slice(0,50).forEach((item:SongModel)=>{
      japanSongs.push(myDataMerge(new SongModel(),item))
    })
    await this.handleSongs(japanSongs,'日韩')
    return Promise.resolve(true)
  }
  handleSongs = async (song:Array<SongModel>,area:string) => {
    const songIds:number[] = []
    song.forEach((song: SongModel) => {
      //保存所有歌曲ID，用于后续获取歌曲URL
      songIds.push(song.id)
      song.picUrl = song.album.picUrl
      if(song.artists.length > 1){
        song.artists.forEach(item=>{
          song.artistName.push(item.name)
        })
      }else{
        song.artistName.push(song.artists[0].name)
      }
    })
    const responseSongUrls = await getSongUrlByIds<Array<SongModel>, null>(songIds)
    responseSongUrls.data.forEach(item=>{
      song.forEach((song:SongModel)=>{
        if(item.id === song.id){
          song.url = item.url
        }
      })
    })
    const areaSongs:areaSongs = {
      area:area,
      songs:song
    }
    this.newestSongs.push(areaSongs)
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
  //获取最新MV
  getNewestMVList = async () =>{
    const res = await getNewestMVList<Array<MVModel>,null>()
    res.data.forEach(item=>{
      this.newestMVList.push(myDataMerge<MVModel>(new MVModel(),item))
    })
    return Promise.resolve(true)
  }

  aboutToAppear(): void {
    Promise.all([this.getNewestAlbumsList(),this.getNewestSongs(),this.getNewestMVList()])
      .then(res=>{
        if(res.every(item=>item)){
          this.isLoading = false
        }
      })
  }

  @Builder newestAlbumsBuilder(){
    Column({space:10}){
      Title({title:'最新专辑'})
      List({space:10}){
        ForEach(this.newestAlbumsList,(item:PlayListModel)=>{
          ListItem(){
            RelativeContainer(){
              Image(item.picUrl)
                .width(BasicConstants.FULL_WIDTH)
                .height(BasicConstants.FULL_HEIGHT)
                .alt($r('app.media.img_loading'))
                .onClick(()=>{
                  const param:musicRouterParamsModel = {
                    id:item.id,
                    type:PlayListType.album
                  }
                  router.pushUrl({
                    url:'pages/Music',
                    params: {
                      param: param
                    }
                  })
                })
              Text(item.name)
                .width(BasicConstants.FULL_WIDTH)
                .fontSize(BasicConstants.FONT_SIZE_NORMAL)
                .padding(5)
                .backgroundColor($r('app.color.label_background'))
                .fontColor($r('app.color.label_text'))
                .maxLines(2)
                .textOverflow({overflow:TextOverflow.Ellipsis})
                .alignRules({
                  'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
                  'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
                })
              Text(item.artist?.name)
                .backgroundColor($r('app.color.label_background'))
                .fontColor($r('app.color.label_text'))
                .borderRadius(5)
                .padding(5)
                .fontSize(BasicConstants.FONT_SIZE_SMALL)
                .margin({right:5,bottom:5})
                .maxLines(1)
                .textOverflow({overflow:TextOverflow.Ellipsis})
                .alignRules({
                  'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
                  'right': { 'anchor': '__container__', 'align': HorizontalAlign.End }
                })
            }
            .width('40%')
            .clip(true)
            .borderRadius(10)
          }
        },(item:PlayListModel)=>item.id.toString())
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .fadingEdge(true)
      .width(BasicConstants.FULL_WIDTH)
      .height(200)  //  变成横向布局后list会默认非常高，所以高度限制一下
    }
    .margin({top:20})
  }
  @Builder newestSongsBuilder(){
    Column({space:10}){
      Title({title:'新歌速递'})
      List({space:10}){
        ForEach(this.newestSongs,(item:areaSongs)=>{
          ListItem(){
            Column({space:10}){
              //地区
              Text(item.area)
                .fontSize(BasicConstants.FONT_SIZE_NORMAL)
                .fontWeight(FontWeight.Bold)
                .width(BasicConstants.FULL_WIDTH)
                .textAlign(TextAlign.Start)
                .fontColor($r('app.color.text_default'))
              List({space:10}){
                ForEach(item.songs.slice(0,10),(song:SongModel)=>{
                  ListItem(){
                    Row({space:10}){
                      Image(song.picUrl)
                        .width(60)
                        .height(BasicConstants.FULL_HEIGHT)
                        .borderRadius(5)
                        .alt($r('app.media.img_loading'))
                      Column(){
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
                      .layoutWeight(1)
                      .height(BasicConstants.FULL_HEIGHT)
                      .alignItems(HorizontalAlign.Start)
                      .justifyContent(FlexAlign.SpaceBetween)
                    }
                    .onClick(()=>{
                      this.tempPlayList = new PlayListModel()
                      this.tempPlayList.songs.push(...item.songs)
                      this.goToPlay(song)
                    })
                    .height(60)
                    .width(BasicConstants.FULL_WIDTH)
                    .justifyContent(FlexAlign.SpaceBetween)
                  }
                },(song:SongModel)=>song.id.toString())
              }
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.None)
              Row(){
                Text('查看更多')
                  .fontSize(BasicConstants.FONT_SIZE_NORMAL)
                  .fontColor($r('app.color.icon_svg_selected'))
                Image($r("app.media.icon_double_arrow_right"))
                  .width(20)
                  .fillColor($r('app.color.icon_svg_selected'))
              }
              .margin({top:10})
              .alignItems(VerticalAlign.Center)
              .onClick(()=>{
                this.tempPlayList = new PlayListModel()
                this.tempPlayList.songs.push(...item.songs)
                this.shownAreaSongs = new MyLazyDataSource()
                this.shownAreaSongs.pushAllData(item.songs)
                this.shownArea = item.area
                this.showAllSongs = true
              })
            }
            .padding(10)
            .backgroundColor($r('app.color.main_tab_background'))
            .borderRadius(5)
            .width('80%')
          }
        },(item:areaSongs)=>item.area)
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .fadingEdge(true)
    }
    .bindSheet($$this.showAllSongs, this.allSongsBuilder(), {
      title:{title:this.shownArea},
      height:'80%',
      showClose:true,
      radius:{topStart:LengthMetrics.vp(10),topEnd:LengthMetrics.vp(10)}
    })
  }
  @Builder allSongsBuilder(){
    Column() {
      // 播放列表
      List() {
        LazyForEach(this.shownAreaSongs, (item: SongModel) => {
          ListItem() {
            Row({space:20}) {
              Image($r('app.media.icon_play'))
                .width(30)
                .height(30)
                .fillColor($r('app.color.edit'))
              Column({ space: 5 }) {
                Text(item.name)
                  .fontSize(BasicConstants.FONT_SIZE_SMALL)
                  .fontColor($r('app.color.text_default'))
                  .maxLines(1)
                  .textOverflow({overflow:TextOverflow.Ellipsis})
                Text(item.artistName.toString())
                  .fontSize(BasicConstants.FONT_SIZE_SMALL)
                  .fontColor($r('app.color.text_light'))
                  .maxLines(1)
                  .textOverflow({overflow:TextOverflow.Ellipsis})
              }
              .layoutWeight(1)
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
  @Builder newestMVBuilder(){
    Column({space:10}){
      Title({title:'最新MV'})
      MvSwiper({mvList:this.newestMVList})
    }
    .margin({bottom:20})
  }

  build() {
    Scroll(){
      Column({space:30}){
        if(!this.isLoading){
          //最新专辑区域
          this.newestAlbumsBuilder()
          //新歌速递
          this.newestSongsBuilder()
          //最新MV区域
          this.newestMVBuilder()
        }else {
          Column(){
            Loading()
          }
          .height(BasicConstants.FULL_HEIGHT)
          .width(BasicConstants.FULL_WIDTH)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .margin({bottom:20})
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Fade)
    .margin({bottom:BasicConstants.MAIN_TAB_BAR_HEIGHT})
    .height(BasicConstants.FULL_HEIGHT)
    .width(BasicConstants.FULL_WIDTH)
  }
}