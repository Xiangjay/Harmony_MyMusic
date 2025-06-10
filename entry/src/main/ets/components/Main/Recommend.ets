import { BasicConstants } from '../../common/constants/BasicConstants'
import {getRecommendSongList,getRecommendMVList, getRecommendNewSongs,
  getRecommendDjPrograms} from '../../common/apis/HomeApis'
import {recommendSongList,recommendMVList, recommendNewSongs, albumArtist,recommendDjProgram} from '../../models/DataModel'
import countTransform from '../../common/utils/CountTransformUtil'
import {Title} from '../common/Title'
import { router } from '@kit.ArkUI'

@Component
export struct Recommend {
  @State recommendSongList:Array<recommendSongList> = []
  @State recommendMVList:Array<recommendMVList> = []
  @State recommendNewSongs:Array<recommendNewSongs> = []
  @State recommendDjPrograms:Array<recommendDjProgram> = []
  @Link currentIndex:number

  //获取推荐歌单
  getRecommendSongList = async () =>{
    const res = await getRecommendSongList<Array<recommendSongList>,null>()
    this.recommendSongList = res.result
  }
  //获取推荐MV
  getRecommendMVList = async () =>{
    const res = await getRecommendMVList<Array<recommendMVList>,null>()
    this.recommendMVList = res.result
  }
  //获取推荐新歌
  getRecommendNewSons = async () =>{
    const res = await getRecommendNewSongs<Array<recommendNewSongs>,null>()
    this.recommendNewSongs = res.result
    //处理歌手数据
    this.recommendNewSongs.forEach((item:recommendNewSongs)=>{
      item.artists = []
      item.song.artists.forEach((artist:albumArtist)=>{
        item.artists.push(artist.name)
      })
    })
  }
  //获取推荐电台
  getRecommendDjProgramsList = async () => {
    const res = await getRecommendDjPrograms<Array<recommendDjProgram>,null>()
    this.recommendDjPrograms = res.result
  }

  aboutToAppear(): void {
    this.getRecommendSongList()
    // this.getRecommendMVList()
    // this.getRecommendNewSons()
    // this.getRecommendDjProgramsList()
  }

  @Builder recommendSongListBuilder(){
    Column({space:10}){
      Title({title:'精选歌单'})
      List(){
        ForEach(this.recommendSongList,(item:recommendSongList)=>{
          ListItem(){
            Column({space:5}){
              Stack({alignContent:Alignment.TopEnd}){
                Image(item.picUrl)
                  .width(BasicConstants.FULL_WIDTH)
                  .height(150)
                  .borderRadius(10)
                  .onClick(()=>{
                    router.pushUrl({
                      url:'pages/Music',
                      params: {
                        value:item
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
        },(item:recommendSongList)=>item.id.toString())
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
        ForEach(this.recommendNewSongs,(item:recommendNewSongs)=>{
          GridItem(){
            Row({space:5}){
              Image(item.picUrl)
                .width('30%')
              Column(){
                Text(item.name)
                  .fontSize(FontWeight.Bold)
                  .fontSize(BasicConstants.FONT_SIZE_NORMAL)
                  .maxLines(1)
                  .textOverflow({overflow:TextOverflow.Ellipsis})
                Text(item.artists.toString())
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
        },(item:recommendNewSongs)=>item.id.toString())
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
            Column({space:5}){
              Text(item.name)
                .width('100%')
                .maxLines(2)
                .textOverflow({overflow:TextOverflow.Ellipsis})
                .fontSize(BasicConstants.FONT_SIZE_NORMAL)
              Image(item.picUrl)
                .width('100%')
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
        //精选歌单
        this.recommendSongListBuilder()
        //精选MV
        this.recommendMVBuilder()
        //新歌推荐
        this.recommendNewSongsBuilder()
        //推荐电台
        this.recommendDjProgramsBuilder()
      }
    }
    .margin({bottom:60})
    .width(BasicConstants.FULL_WIDTH)
    .padding({
      left:10
    })
  }
}