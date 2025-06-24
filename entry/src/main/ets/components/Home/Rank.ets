import { getAllRanks, getTopArtistList } from "../../common/apis/HomeApis"
import { BasicConstants } from "../../common/constants/BasicConstants"
import { countTransform, myDataMerge, SpecificKey } from "../../common/utils/CommonTools"
import {Title} from '../common/Title'
import {topArtistsModel,responseTopArtistsList,areaTopArtists, PlayListModel, musicRouterParamsModel,
  PlayListType } from '../../models/DataModels'
import { Loading } from "../common/Loading"
import { RankListItem } from "./RankListItem"
import { LengthMetrics, router } from "@kit.ArkUI"
import { MyLazyDataSource } from "../../common/utils/MyLazyDataSource"

@Component
export struct Rank {
  @State chinaTopArtists:Array<topArtistsModel> = []
  @State europeTopArtists:Array<topArtistsModel> = []
  @State japanTopArtists:Array<topArtistsModel> = []
  @State topArtistsArea: Array<areaTopArtists> = []
  @State rankNames:string[] = ['飙升榜','新歌榜','热歌榜','原创榜']
  @State rankList:Array<PlayListModel> = []
  @State @Watch('watchLoading')rankLoading:boolean = true
  @State @Watch('watchLoading')topArtistsLoading:boolean = true
  @State isLoading:boolean = true
  @State areaRankItemHeight: number = -1
  @State showAllArtists:boolean = false
  @State shownAreaArtist:MyLazyDataSource<topArtistsModel> = new MyLazyDataSource()
  @State shownArea:string = ''

  //获取所有榜单
  getAllRanks = async () => {
    const res = await getAllRanks<Array<PlayListModel>,null>()
    const specificKeys:SpecificKey[] = [
      {
        specificKey:'picUrl',
        sourceKey:'coverImgUrl'
      }
    ]
    //处理想要的榜单
    res.list.forEach(item=>{
      this.rankNames.forEach(name=>{
        if(item.name === name){
          this.rankList.push(myDataMerge<PlayListModel>(new PlayListModel(),item,specificKeys))
        }
      })
    })
  }
  //获取歌手排行榜
  /*
   * type : 地区
      1: 华语,2: 欧美,3: 韩国,4: 日本
  */
  getTopArtistsList = async () =>{
    const chinaTopArtists = await getTopArtistList<responseTopArtistsList,null>()
    //默认展示前五名数据
    chinaTopArtists.list.artists.slice(0,50).forEach(item=>{
      this.chinaTopArtists.push(myDataMerge<topArtistsModel>(new topArtistsModel(),item))
    })
    const europeTopArtists = await getTopArtistList<responseTopArtistsList,null>(2)
    europeTopArtists.list.artists.slice(0,50).forEach(item=>{
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
    japanTopArtists.slice(0,50).forEach(item=>{
      this.japanTopArtists.push(myDataMerge<topArtistsModel>(new topArtistsModel(),item))
    })
    this.topArtistsArea.push({area:'日韩榜',artists:this.japanTopArtists})
    this.topArtistsLoading = false
  }
  watchLoading(){
    if (!this.rankLoading || !this.topArtistsLoading) {
      this.isLoading = false
    }
  }
  aboutToAppear(): void {
    this.getAllRanks()
    this.getTopArtistsList()
  }

  @Builder ranksBuilder(){
    Column({space:20}){
      Title({title:'官方榜'})
      ForEach(this.rankList,(rank:PlayListModel)=>{
        Column({space:5}){
          Row(){
            Text(rank.name)
              .fontSize(BasicConstants.FONT_SIZE_NORMAL)
              .fontColor($r('app.color.text_default'))
              .fontWeight(FontWeight.Bold)
            Text(rank.updateFrequency)
              .fontSize(BasicConstants.FONT_SIZE_SMALL)
              .fontColor($r('app.color.text_default'))
          }
          .width(BasicConstants.FULL_WIDTH)
          .justifyContent(FlexAlign.SpaceBetween)
          Row({space:10}){
            Image(rank.picUrl)
              .alt($r('app.media.img_loading'))
              .width(100)
              .borderRadius(10)
            RankListItem({rank:rank,rankLoading:this.rankLoading})
          }
          .height(100)
          .width(BasicConstants.FULL_WIDTH)
          .onClick(()=>{
            const param:musicRouterParamsModel = {
              id:rank.id,
              type:PlayListType.playList
            }
            router.pushUrl({
              url:'pages/Music',
              params: {
                param: param
              }
            })
          })
        }
        .borderRadius(10)
        .padding(10)
        .backgroundColor($r('app.color.main_tab_background'))
      },(rank:PlayListModel)=>rank.id.toString())
    }
    .width(BasicConstants.FULL_WIDTH)
    .margin({top:20})
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
                ForEach(item.artists.slice(0,5),(artist:topArtistsModel,index:number)=>{
                  ListItem(){
                    Row({space:10}){
                      Image(artist.picUrl)
                        .width(80)
                        .height(BasicConstants.FULL_HEIGHT)
                        .borderRadius(5)
                        .alt($r('app.media.img_loading'))
                      //歌手介绍
                      Column(){
                        Text(artist.name)
                          .fontSize(BasicConstants.FONT_SIZE_NORMAL)
                          .textAlign(TextAlign.Start)
                          .fontColor($r('app.color.text_default'))
                          .width(BasicConstants.FULL_WIDTH)
                        Text(`共${artist.albumSize}张专辑，${artist.musicSize}首歌曲`)
                          .fontSize(BasicConstants.FONT_SIZE_SMALL)
                          .textAlign(TextAlign.Start)
                          .fontColor($r('app.color.text_default'))
                          .width(BasicConstants.FULL_WIDTH)
                        Text(){
                          Span(`${countTransform(artist.score)}`)
                            .fontColor($r('app.color.icon_svg_selected'))
                          Span('票')
                            .fontColor($r('app.color.text_default'))
                        }
                        .width(BasicConstants.FULL_WIDTH)
                        .fontSize(BasicConstants.FONT_SIZE_SMALL)
                        .textAlign(TextAlign.End)
                      }
                      .layoutWeight(1)
                      .height(BasicConstants.FULL_HEIGHT)
                      .justifyContent(FlexAlign.SpaceBetween)
                    }
                    .height(80)
                    .width(BasicConstants.FULL_WIDTH)
                    .justifyContent(FlexAlign.SpaceBetween)
                    .onClick(()=>{
                      const param:musicRouterParamsModel = {
                        id:artist.id,
                        type:PlayListType.singer
                      }
                      router.pushUrl({
                        url:'pages/Music',
                        params: {
                          param: param
                        }
                      })
                    })
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
              .alignItems(VerticalAlign.Center)
              .onClick(()=>{
                this.shownAreaArtist = new MyLazyDataSource()
                this.shownAreaArtist.pushAllData(item.artists)
                this.shownArea = item.area
                this.showAllArtists = true
              })
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
    .width(BasicConstants.FULL_WIDTH)
    .bindSheet($$this.showAllArtists, this.allArtistsBuilder(), {
      title:{title:this.shownArea},
      height:'80%',
      showClose:true,
      radius:{topStart:LengthMetrics.vp(10),topEnd:LengthMetrics.vp(10)}
    })
  }
  @Builder allArtistsBuilder(){
    Column(){
      List({space:10}){
        LazyForEach(this.shownAreaArtist,(artist:topArtistsModel,index:number)=>{
          ListItem(){
            Row({space:10}){
              Text(`${index + 1}`)
                .fontColor($r('app.color.text_default'))
                .fontSize(BasicConstants.FONT_SIZE_NORMAL)
                .width(30)
              Image(artist.picUrl)
                .width(80)
                .height(BasicConstants.FULL_HEIGHT)
                .borderRadius(5)
                .alt($r('app.media.img_loading'))
              //歌手介绍
              Column(){
                Text(artist.name)
                  .fontSize(BasicConstants.FONT_SIZE_NORMAL)
                  .textAlign(TextAlign.Start)
                  .fontColor($r('app.color.text_default'))
                  .width(BasicConstants.FULL_WIDTH)
                Text(`共${artist.albumSize}张专辑，${artist.musicSize}首歌曲`)
                  .fontSize(BasicConstants.FONT_SIZE_SMALL)
                  .textAlign(TextAlign.Start)
                  .fontColor($r('app.color.text_default'))
                  .width(BasicConstants.FULL_WIDTH)
                Text(){
                  Span(`${countTransform(artist.score)}`)
                    .fontColor($r('app.color.icon_svg_selected'))
                  Span('票')
                    .fontColor($r('app.color.text_default'))
                }
                .width(BasicConstants.FULL_WIDTH)
                .fontSize(BasicConstants.FONT_SIZE_SMALL)
                .textAlign(TextAlign.End)
              }
              .layoutWeight(1)
              .height(BasicConstants.FULL_HEIGHT)
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .height(80)
            .width(BasicConstants.FULL_WIDTH)
            .justifyContent(FlexAlign.SpaceBetween)
          }
        },(artist:topArtistsModel)=>artist.id.toString())
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .fadingEdge(true)
    }
    .padding({
      left:20,
      right:20,
      bottom:20
    })
  }

  build() {
    Scroll(){
      Column({space:30}){
        if(!this.isLoading){
          this.ranksBuilder()
          this.topArtistsListBuilder()
        }else{
          Column(){
            Loading()
          }
          .height(BasicConstants.FULL_HEIGHT)
          .width(BasicConstants.FULL_WIDTH)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
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