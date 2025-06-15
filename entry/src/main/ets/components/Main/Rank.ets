import { getTopArtistList } from "../../common/apis/HomeApis"
import { BasicConstants } from "../../common/constants/BasicConstants"
import { countTransform, myDataMerge } from "../../common/utils/CommonTools"
import {Title} from '../common/Title'
import {topArtistsModel,responseTopArtistsList,areaTopArtists} from '../../models/DataModels'
import { Loading } from "../common/Loading"

@Component
export struct Rank {
  @State chinaTopArtists:Array<topArtistsModel> = []
  @State europeTopArtists:Array<topArtistsModel> = []
  @State japanTopArtists:Array<topArtistsModel> = []
  @State topArtistsArea: Array<areaTopArtists> = []
  @State isLoading:boolean = true
  @State areaRankItemHeight: number = -1

  //获取歌手排行榜
  getTopArtistsList = async () =>{
    const chinaTopArtists = await getTopArtistList<responseTopArtistsList,null>()
    //默认展示前五名数据
    chinaTopArtists.list.artists.slice(0,5).forEach(item=>{
      this.chinaTopArtists.push(myDataMerge<topArtistsModel>(new topArtistsModel(),item))
    })
    const europeTopArtists = await getTopArtistList<responseTopArtistsList,null>(2)
    europeTopArtists.list.artists.slice(0,5).forEach(item=>{
      this.europeTopArtists.push(myDataMerge<topArtistsModel>(new topArtistsModel(),item))
    })
    this.topArtistsArea.push({area:'华语榜',artists:this.chinaTopArtists})
    this.topArtistsArea.push({area:'欧美榜',artists:this.europeTopArtists})
    //由于日本和韩国的接口是分开的，而我这里想合到一起，所以用promise.all一起获取数据
    const responseResult = await Promise.all([getTopArtistList<responseTopArtistsList,null>(3),getTopArtistList<responseTopArtistsList,null>(4)])
    //合并数据并
    const japanTopArtists = responseResult[0].list.artists.concat(responseResult[1].list.artists)
    japanTopArtists.sort((a,b)=>{
      return b.score - a.score
    })
    japanTopArtists.slice(0,5).forEach(item=>{
      this.japanTopArtists.push(myDataMerge<topArtistsModel>(new topArtistsModel(),item))
    })
    this.topArtistsArea.push({area:'日韩榜',artists:this.japanTopArtists})
    this.isLoading = false
  }

  @Builder topArtistsListBuilder(){
    Column({space:10}){
      Title({title:'歌手排行榜'})
      List({space:10}){
        ForEach(this.topArtistsArea,(item:areaTopArtists)=>{
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
                ForEach(item.artists,(artist:topArtistsModel)=>{
                  ListItem(){
                    Flex(){
                      //歌手图片
                      Image(artist.picUrl)
                        // .width(80)
                        .height(80)
                        .margin({
                          right:20
                        })
                      //歌手介绍
                      Column({space:5}){
                        Text(artist.name)
                          .fontSize(BasicConstants.FONT_SIZE_NORMAL)
                          .textAlign(TextAlign.Start)
                          .width(BasicConstants.FULL_WIDTH)
                          .fontColor($r('app.color.text_default'))
                        Text(`共${artist.albumSize}张专辑，${artist.musicSize}首歌曲`)
                          .fontSize(BasicConstants.FONT_SIZE_SMALL)
                          .textAlign(TextAlign.Start)
                          .width(BasicConstants.FULL_WIDTH)
                          .fontColor($r('app.color.text_default'))
                        Text(){
                          Span(`${countTransform(artist.score)}`)
                            .fontColor($r('app.color.icon_svg_selected'))
                          Span('票')
                            .fontColor($r('app.color.text_default'))
                        }
                        .fontSize(BasicConstants.FONT_SIZE_SMALL)
                        .textAlign(TextAlign.End)
                        .width(BasicConstants.FULL_WIDTH)
                        .margin({
                          right:60
                        })
                      }
                      .height(BasicConstants.FULL_HEIGHT)
                      .width(BasicConstants.FULL_WIDTH)
                      .justifyContent(FlexAlign.SpaceBetween)
                      .flexGrow(1)
                    }
                    .height(80)
                    .width(BasicConstants.FULL_WIDTH)
                  }
                },(artist:topArtistsModel)=>artist.id.toString())
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
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              .width(BasicConstants.FULL_WIDTH)
            }
            .padding(10)
            .backgroundColor($r('app.color.main_tab_background'))
            .borderRadius(5)
            .width('80%')
          }
          .onAreaChange((oldArea: Area, newArea: Area) => {
            if (this.areaRankItemHeight < newArea.height) {
              this.areaRankItemHeight = newArea.height as number
            }
          })
        },(item:areaTopArtists)=>item.area)
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .fadingEdge(true)
      .height(this.areaRankItemHeight)
    }
    .margin({top:20})
  }

  aboutToAppear(): void {
    this.getTopArtistsList()
  }

  build() {
    // Scroll(){
      Column({space:30}){
        if(!this.isLoading){
          this.topArtistsListBuilder()
        }else{
          Loading()
        }
      }
      //内容没铺满高度，所以要有下面的属性
      .height(BasicConstants.FULL_HEIGHT)
      .width(BasicConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.Start)
      .margin({bottom:BasicConstants.MAIN_TAB_BAR_HEIGHT})
    }
  //   .scrollBar(BarState.Off)
  //   .edgeEffect(EdgeEffect.Fade)
  //   .margin({bottom:BasicConstants.MAIN_TAB_BAR_HEIGHT})
  //   .height(BasicConstants.FULL_HEIGHT)
  //   .width(BasicConstants.FULL_WIDTH)
  // }
}