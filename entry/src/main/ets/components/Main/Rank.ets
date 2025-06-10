import { getTopArtistList } from "../../common/apis/HomeApis"
import { BasicConstants } from "../../common/constants/BasicConstants"
import countTransform from "../../common/utils/CountTransformUtil"
import { areaTopArtists, topArtist, topArtistsList } from "../../models/DataModel"
import {Title} from '../common/Title'

@Component
export struct Rank {
  @State chinaTopArtists:Array<topArtist> = []
  @State europeTopArtists:Array<topArtist> = []
  @State japanTopArtists:Array<topArtist> = []
  @State topArtistsArea: Array<areaTopArtists> = []

  //获取歌手排行榜
  getTopArtistsList = async () =>{
    const chinaTopArtists = await getTopArtistList<topArtistsList,null>(1)
    //默认展示前五名数据
    this.chinaTopArtists = chinaTopArtists.list.artists.slice(0,5)
    console.log(JSON.stringify(this.chinaTopArtists[0].id))
    const europeTopArtists = await getTopArtistList<topArtistsList,null>(2)
    this.europeTopArtists = europeTopArtists.list.artists.slice(0,5)
    this.topArtistsArea.push({area:'华语榜',artists:this.chinaTopArtists})
    this.topArtistsArea.push({area:'欧美榜',artists:this.europeTopArtists})
    //由于日本和韩国的接口是分开的，而我这里想合到一起，所以用promise.all一起获取数据
    const responseResult = await Promise.all([getTopArtistList<topArtistsList,null>(3),getTopArtistList<topArtistsList,null>(4)])
    //合并数据并
    this.japanTopArtists = responseResult[0].list.artists.concat(responseResult[1].list.artists)
    this.japanTopArtists.sort((a,b)=>{
      return b.score - a.score
    })
    this.topArtistsArea.push({area:'日韩榜',artists:this.japanTopArtists.slice(0,5)})
  }

  @Builder topArtistsListBuilder(){
    Column({space:10}){
      Title({title:'歌手排行榜'})
      List(){
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
                ForEach(item.artists,(artist:topArtist)=>{
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
                },(artist:topArtist)=>artist.id.toString())
              }
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.None)
              Row(){
                Text('查看更多')
                  .fontSize(BasicConstants.FONT_SIZE_NORMAL)
                  .fontColor($r('app.color.icon_svg_selected'))
                Image($r('app.media.icon_doubleArrow_left'))
                  .width(20)
                  .fillColor($r('app.color.icon_svg_selected'))
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              .width(BasicConstants.FULL_WIDTH)
            }
            .padding(10)
            .backgroundColor($r('app.color.window_background'))
            .borderRadius(5)
            .width('80%')
            .margin({
              right:10,
            })
          }
        },(item:areaTopArtists)=>item.area)
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .fadingEdge(true)
      .margin({
        bottom:20
      })
    }
    .margin({top:20})
  }

  aboutToAppear(): void {
    this.getTopArtistsList()
  }

  build() {
    Scroll(){
      Column({space:20}){
        //歌手排行榜
        this.topArtistsListBuilder()
      }
    }
    .margin({bottom:60})
    .width(BasicConstants.FULL_WIDTH)
    .padding({
      left:10
    })
  }
}