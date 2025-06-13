import { BasicConstants } from '../../common/constants/BasicConstants'
import {getRecommendSongList,getRecommendMVList, getRecommendNewSongs,
  getRecommendDjPrograms} from '../../common/apis/HomeApis'
import { countTransform,myDataMerge, SpecificKey } from '../../common/utils/CommonTools'
import {Title} from '../common/Title'
import { router } from '@kit.ArkUI'
import {PlayListModel,recommendMVList,SongModel,recommendDjProgram,musicRouterParamsModel,
  playListType} from '../../models/DataModels'
import log from '@open/log'
import { Loading } from '../common/Loading'

@Component
export struct Recommend {
  @State recommendSongList:Array<PlayListModel> = []
  @State recommendMVList:Array<recommendMVList> = []
  @State recommendNewSongs:Array<SongModel> = []
  @State recommendDjPrograms:Array<recommendDjProgram> = []
  @Link currentIndex:number
  @State isLoading:boolean = true

  //获取推荐歌单
  getRecommendSongList = async () =>{
    const res = await getRecommendSongList<Array<PlayListModel>,null>()
    res.result.forEach(item=>{
      this.recommendSongList.push(myDataMerge<PlayListModel>(new PlayListModel(),item))
    })
    this.isLoading = false
  }
  //获取推荐MV
  getRecommendMVList = async () =>{
    const res = await getRecommendMVList<Array<recommendMVList>,null>()
    res.result.forEach(item=>{
      this.recommendMVList.push(myDataMerge<recommendMVList>(new recommendMVList(),item))
    })
    this.isLoading = false
  }
  //获取推荐新歌
  getRecommendNewSons = async () =>{
    const res = await getRecommendNewSongs<Array<SongModel>,null>()
    const songSpecificKeys:SpecificKey[] = [
      {
        specificKey:'showPic',
        sourceKey:'picUrl'
      }
    ]
    res.result.forEach(item=>{
      this.recommendNewSongs.push(myDataMerge<SongModel>(new SongModel(),item,songSpecificKeys))
    })
    this.recommendNewSongs.forEach((song:SongModel)=>{
      song.song?.artists.forEach(artist=>{
        song.showArtists.push(artist.name)
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
    this.getRecommendNewSons()
    this.getRecommendDjProgramsList()
  }

  @Builder recommendSongListBuilder(){
    Column({space:10}){
      Title({title:'精选歌单'})
      List(){
        ForEach(this.recommendSongList,(item:PlayListModel)=>{
          ListItem(){
            Column({space:5}){
              Stack({alignContent:Alignment.TopEnd}){
                Image(item.picUrl)
                  .width(BasicConstants.FULL_WIDTH)
                  .height(150)
                  .borderRadius(10)
                  .onClick(()=>{
                    const param:musicRouterParamsModel = {
                      id:item.id,
                      type:playListType.playList
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
            .height(BasicConstants.FULL_HEIGHT)
            .width('40%')
            .margin({right:10})
          }
        },(item:PlayListModel)=>item.id.toString())
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .fadingEdge(true)
      .width(BasicConstants.FULL_WIDTH)
      .height(190)  //  变成横向布局后list会默认非常高，所以高度限制一下
    }
    .margin({top:20})
  }
  @Builder recommendMVBuilder(){
    Column({space:10}){
      Title({title:'精选MV'})
      Swiper(){
        ForEach(this.recommendMVList,(item:recommendMVList)=>{
          Stack({alignContent:Alignment.Bottom}){
            Image(item.picUrl)
              .width(BasicConstants.FULL_WIDTH)
              .height(150)
              .borderRadius(10)
            Text(item.copywriter)
              .width(BasicConstants.FULL_WIDTH)
              .fontSize(BasicConstants.FONT_SIZE_NORMAL)
              .fontColor($r('app.color.label_text'))
              .backgroundColor($r('app.color.label_background'))
              .padding(5)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis})
          }
        },(item:recommendMVList)=>item.id.toString())
      }
      .autoPlay(true)
      .indicator(false)
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
              Image(item.showPic)
                .width('30%')
              Column(){
                Text(item.name)
                  .fontSize(FontWeight.Bold)
                  .fontSize(BasicConstants.FONT_SIZE_NORMAL)
                  .maxLines(1)
                  .textOverflow({overflow:TextOverflow.Ellipsis})
                Text(item.showArtists.toString())
                  .fontSize(BasicConstants.FONT_SIZE_SMALL)
                  .maxLines(1)
                  .textOverflow({overflow:TextOverflow.Ellipsis})
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
      List(){
        ForEach(this.recommendDjPrograms,(item:recommendDjProgram)=>{
          ListItem(){
            Column({space:10}){
              Text(item.name)
                .width('100%')
                .maxLines(2)
                .textOverflow({overflow:TextOverflow.Ellipsis})
                .fontSize(BasicConstants.FONT_SIZE_SMALL)
              Image(item.picUrl)
                .width(BasicConstants.FULL_WIDTH)
                .borderRadius(5)
                .onClick(()=>{
                  this.currentIndex = 3
                })
            }
            .height(BasicConstants.FULL_HEIGHT)
            .width('40%')
            .margin({right:10})
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.SpaceBetween)
          }
        },(item:recommendDjProgram)=>item.id.toString())
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .fadingEdge(true)
      .width(BasicConstants.FULL_WIDTH)
      .height(180)
    }
    .margin({
      bottom:20
    })
  }

  build() {
    Scroll(){
      Column({space:20}){
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
    .margin({bottom:60})
    .width(BasicConstants.FULL_WIDTH)
    .padding({
      left:10
    })
  }
}