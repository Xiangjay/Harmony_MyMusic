import { BasicConstants } from '../../common/constants/BasicConstants'
import {getRecommendPlayList,getRecommendMVList, getRecommendNewSongs,
  getRecommendDjPrograms} from '../../common/apis/HomeApis'
import { countTransform,myDataMerge } from '../../common/utils/CommonTools'
import {Title} from '../common/Title'
import { router } from '@kit.ArkUI'
import {PlayListModel,SongModel,recommendDjProgram,musicRouterParamsModel,
  PlayListType,
  MVModel,
  RecommendSongModel,
  Artist} from '../../models/DataModels'
import { Loading } from '../common/Loading'
import log from '@open/log'
import { getSongUrlByIds } from '../../common/apis/MusicApis'
import { MvSwiper } from '../common/MvSwiper'

@Component
export struct Recommend {
  @State recommendSongList:Array<PlayListModel> = []
  @State recommendMVList:Array<MVModel> = []
  @State recommendNewSongs:Array<SongModel> = []
  @State recommendDjPrograms:Array<recommendDjProgram> = []
  @State tempPlayList:PlayListModel = new PlayListModel()
  @State songListItemHeight: number = -1
  @State djListItemHeight: number = -1
  @Link currentIndex:number
  @State isLoading:boolean = true

  //获取推荐歌单
  getRecommendSongList = async () =>{
    const res = await getRecommendPlayList<Array<PlayListModel>,null>()
    res.result.forEach(item=>{
      this.recommendSongList.push(myDataMerge<PlayListModel>(new PlayListModel(),item))
    })
    this.isLoading = false
  }
  //获取推荐MV
  getRecommendMVList = async () =>{
    const res = await getRecommendMVList<Array<MVModel>,null>()
    res.result.forEach(item=>{
      this.recommendMVList.push(myDataMerge<MVModel>(new MVModel(),item))
    })
    this.isLoading = false
  }
  //获取推荐新歌
  getRecommendNewSongs = async () =>{
    const res = await getRecommendNewSongs<Array<RecommendSongModel>,null>()
    const recommendNewSongs:Array<RecommendSongModel> = []
    const songIds:number[] = []
    res.result.forEach(item=>{
      //这里merge出来太多没用的数据，所以下面处理一下
      recommendNewSongs.push(myDataMerge<RecommendSongModel>(new RecommendSongModel(),item))
      songIds.push(item.id)
    })
    //把后台返回的数据处理成程序想要的数据类型
    recommendNewSongs.forEach(item=>{
      const newSong:SongModel = new SongModel()
      newSong.id = item.id
      newSong.name = item.name
      newSong.duration = item.duration
      newSong.picUrl = item.picUrl
      item.song.artists.forEach(artist=>{
        const ar:Artist = new Artist()
        ar.id = artist.id
        ar.name = artist.name
        newSong.artists.push(ar)
      })
      if(newSong.artists.length > 1){
        newSong.artists.forEach(item=>{
          newSong.artistName.push(item.name)
        })
      }else{
        newSong.artistName.push(newSong.artists[0].name)
      }
      newSong.album.id = item.song.album.id
      newSong.album.name = item.song.album.name
      newSong.album.picUrl = item.song.album.picUrl
      this.recommendNewSongs.push(newSong)
    })
    //通过歌曲ID获取歌曲播放URL
    const responseSongUrls = await getSongUrlByIds<Array<SongModel>, null>(songIds)
    //把拿到的歌曲url赋值到对应的歌曲里，这里其实可以一个循环this.playList.songs[index].url = item.url就行，但是为了以防万一顺序错乱，还是严谨点用两个循环判断下ID
    responseSongUrls.data.forEach(item=>{
      this.recommendNewSongs.forEach((song:SongModel)=>{
        if(item.id === song.id){
          song.url = item.url
        }
      })
    })
    this.isLoading = false
  }
  //获取推荐电台
  getRecommendDjProgramsList = async () => {
    const res = await getRecommendDjPrograms<Array<recommendDjProgram>,null>()
    res.result.forEach(item=>{
      this.recommendDjPrograms.push(myDataMerge<recommendDjProgram>(new recommendDjProgram(),item))
    })
    this.isLoading = false
  }

  aboutToAppear(): void {
    this.getRecommendSongList()
    this.getRecommendMVList()
    this.getRecommendNewSongs()
    this.getRecommendDjProgramsList()
  }

  @Builder recommendSongListBuilder(){
    Column({space:10}){
      Title({title:'精选歌单'})
      List({space:10}){
        ForEach(this.recommendSongList,(item:PlayListModel)=>{
          ListItem(){
            Column({space:5}){
              Stack({alignContent:Alignment.TopEnd}){
                Image(item.picUrl)
                  .width(BasicConstants.FULL_WIDTH)
                  .height(150)
                  .borderRadius(10)
                  .alt($r('app.media.img_loading'))
                  .onClick(()=>{
                    const param:musicRouterParamsModel = {
                      id:item.id,
                      type:PlayListType.playList
                    }
                    router.pushUrl({
                      url:'pages/Music',
                      params: {
                        param: param
                      }
                    })
                  })
                Text(countTransform(item.playCount))
                  .margin({right:5,top:5})
                  .fontSize(BasicConstants.FONT_SIZE_XSMALL)
                  .borderRadius(5)
                  .padding(5)
                  .backgroundColor($r('app.color.label_background'))
                  .fontColor($r('app.color.label_text'))
              }
              Text(item.name)
                .width(BasicConstants.FULL_WIDTH)
                .fontSize(BasicConstants.FONT_SIZE_SMALL)
                .fontColor($r('app.color.text_default'))
                .padding({
                  left:5,
                  right:5
                })
                .maxLines(2)
                .textOverflow({overflow:TextOverflow.Ellipsis})
            }
            .width('40%')
          }.onAreaChange((oldArea: Area, newArea: Area) => {
            if (this.songListItemHeight < newArea.height) {
              this.songListItemHeight = newArea.height as number
            }
          })
        },(item:PlayListModel)=>item.id.toString())
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .fadingEdge(true)
      .width(BasicConstants.FULL_WIDTH)
      .height(this.songListItemHeight)
    }
    .margin({top:20})
  }
  @Builder recommendMVBuilder(){
    Column({space:10}){
      Title({title:'精选MV'})
      MvSwiper({mvList:this.recommendMVList})
    }
    .padding({right:10})
  }
  @Builder recommendNewSongsBuilder(){
    Column({space:10}){
      Title({title:'新歌推荐'})
      Grid(){
        ForEach(this.recommendNewSongs,(item:SongModel)=>{
          GridItem(){
            Row({space:5}){
              Image(item.picUrl)
                .width('30%')
                .alt($r('app.media.img_loading'))
                .onClick(()=>{
                  this.tempPlayList.songs.push(item)
                  AppStorage.setOrCreate('currentPlayList',this.tempPlayList)
                  router.pushUrl({
                    url:'pages/Play',
                    params:{
                      param:item
                    }
                  })
                })
              Column(){
                Text(item.name)
                  .fontWeight(FontWeight.Bold)
                  .fontSize(BasicConstants.FONT_SIZE_NORMAL)
                  .fontColor($r('app.color.text_default'))
                  .maxLines(1)
                  .textOverflow({overflow:TextOverflow.Ellipsis})
                Text(item.artistName.toString())
                  .fontSize(BasicConstants.FONT_SIZE_SMALL)
                  .maxLines(1)
                  .textOverflow({overflow:TextOverflow.Ellipsis})
                  .fontColor($r('app.color.text_light'))
              }
              .width('70%')
              .height(BasicConstants.FULL_HEIGHT)
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .justifyContent(FlexAlign.Start)
            .height(60)
            .width(BasicConstants.FULL_WIDTH)
          }
          .width('60%')
        },(item:SongModel)=>item.id.toString())
      }
      .fadingEdge(true)
      .scrollBar(BarState.Off)
      .rowsTemplate('1fr 1fr 1fr')
      .columnsGap(10)
      .rowsGap(10)
      .height(200)
      .width(BasicConstants.FULL_WIDTH)
    }
  }
  @Builder recommendDjProgramsBuilder(){
    Column({space:10}){
      Title({title:'推荐电台'})
      List({space:10}){
        ForEach(this.recommendDjPrograms,(item:recommendDjProgram)=>{
          ListItem(){
            Column(){
              Text(item.name)
                .width(BasicConstants.FULL_WIDTH)
                .maxLines(2)
                .textOverflow({overflow:TextOverflow.Ellipsis})
                .fontSize(BasicConstants.FONT_SIZE_SMALL)
                .fontColor($r('app.color.text_light'))
              Image(item.picUrl)
                .width(BasicConstants.FULL_WIDTH)
                .height(150)
                .borderRadius(10)
                .margin({top:10})
                .alt($r('app.media.img_loading'))
                .onClick(()=>{
                  this.currentIndex = 3
                })
            }
            .width('40%')
            .justifyContent(FlexAlign.SpaceBetween)
            .height(this.djListItemHeight)
          }.onAreaChange((oldArea: Area, newArea: Area) => {
            if (this.djListItemHeight < newArea.height) {
              this.djListItemHeight = newArea.height as number
            }
          })
        },(item:recommendDjProgram)=>item.id.toString())
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .fadingEdge(true)
      .width(BasicConstants.FULL_WIDTH)
      .height(this.djListItemHeight)
    }
    .margin({
      bottom:20
    })
  }

  build() {
    Scroll(){
      Column({space:30}){
        if (!this.isLoading){
          //精选歌单
          this.recommendSongListBuilder()
          //精选MV
          this.recommendMVBuilder()
          //新歌推荐
          this.recommendNewSongsBuilder()
          //推荐电台
          this.recommendDjProgramsBuilder()
        }else {
          Loading()
        }
      }
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Fade)
    .margin({bottom:BasicConstants.MAIN_TAB_BAR_HEIGHT})
    .height(BasicConstants.FULL_HEIGHT)
    .width(BasicConstants.FULL_WIDTH)
  }
}