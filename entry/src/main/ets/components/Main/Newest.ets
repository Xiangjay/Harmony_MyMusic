import { getMusicBanner, getNewestAlbumsList, getNewestMVList } from '../../common/apis/HomeApis'
import { BasicConstants } from '../../common/constants/BasicConstants'
import { banner, newestAlbum, newestMV } from "../../models/DataModel"
import {Title} from '../common/Title'

@Component
export struct Newest {
  @State banners:Array<banner> = []
  @State newestAlbumsList:Array<newestAlbum> = []
  @State newestMVList:Array<newestMV> = []
  getBanner = async () => {
    const res = await getMusicBanner<Array<banner>,null>()
    this.banners = res.banners
  }
  //获取最新专辑
  getNewestAlbumsList = async () =>{
    const res = await getNewestAlbumsList<Array<newestAlbum>,null>()
    this.newestAlbumsList = res.albums
  }
  //获取最新MV
  getNewestMVList = async () =>{
    const res = await getNewestMVList<Array<newestMV>,null>()
    this.newestMVList = res.data
  }
  aboutToAppear(): void {
    this.getBanner()
    this.getNewestAlbumsList()
    this.getNewestMVList()
  }

  @Builder swiperBuilder(){
    Row(){
      Swiper(){
        ForEach(this.banners,(banner:banner)=>{
          Stack({alignContent:Alignment.BottomEnd}){
            Image(banner.pic)
              .width(BasicConstants.FULL_WIDTH)
              .borderRadius(5)
            Text(banner.typeTitle)
              .fontColor($r('app.color.label_text'))
              .fontSize(BasicConstants.FONT_SIZE_XSMALL)
              .padding(5)
              .borderRadius(5)
              .backgroundColor($r('app.color.label_background'))
              .margin({
                bottom:8,
                right:8
              })
          }
        },(banner:banner)=>banner.bannerId)
      }
      .indicator( // 设置圆点导航点样式
        new DotIndicator()
          .left(0)
          .bottom(0)
          .itemWidth(8)
          .itemHeight(8)
          .selectedItemWidth(8)
          .selectedItemHeight(8)
          .color(Color.Gray)
          .selectedColor(Color.White)
          .maxDisplayCount(6)
      )
      .autoPlay(true)
    }
    .margin({
      top:20,
      right:10
    })
  }
  @Builder newestAlbumsBuilder(){
    Column({space:10}){
      Title({title:'最新专辑'})
      List(){
        ForEach(this.newestAlbumsList,(item:newestAlbum)=>{
          ListItem(){
            RelativeContainer(){
              Image(item.picUrl)
                .width(BasicConstants.FULL_WIDTH)
                .height(BasicConstants.FULL_HEIGHT)
                .borderRadius(10)
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
              Text(item.artist.name)
                .backgroundColor($r('app.color.label_background'))
                .fontColor($r('app.color.label_text'))
                .borderRadius(5)
                .padding(5)
                .fontSize(BasicConstants.FONT_SIZE_XSMALL)
                .margin({right:5,bottom:5})
                .alignRules({
                  'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
                  'right': { 'anchor': '__container__', 'align': HorizontalAlign.End }
                })
            }
            .width('40%')
            .margin({right:10})
          }
        },(item:newestAlbum)=>item.id.toString())
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .fadingEdge(true)
      .width(BasicConstants.FULL_WIDTH)
      .height(200)  //  变成横向布局后list会默认非常高，所以高度限制一下
    }
  }
  @Builder newestMVBuilder(){
    Column({space:10}){
      Title({title:'最新MV'})
      Swiper(){
        ForEach(this.newestMVList,(item:newestMV)=>{
          RelativeContainer(){
            Image(item.cover)
              .width(BasicConstants.FULL_WIDTH)
              .height(200)
              .borderRadius(10)
            Text(item.name)
              .fontSize(BasicConstants.FONT_SIZE_NORMAL)
              .fontColor($r('app.color.label_text'))
              .width(BasicConstants.FULL_WIDTH)
              .maxLines(1)
              .textOverflow({overflow:TextOverflow.Ellipsis})
              .backgroundColor($r('app.color.label_background'))
              .padding(5)
              .alignRules({
                'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
                'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
              })
            Text(item.artistName)
              .fontSize(BasicConstants.FONT_SIZE_NORMAL)
              .fontColor($r('app.color.label_text'))
              .backgroundColor($r('app.color.label_background'))
              .padding(5)
              .borderRadius(5)
              .margin({top:5,right:5 })
              .alignRules({
                'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
                'right': { 'anchor': '__container__', 'align': HorizontalAlign.End }
              })
          }
          .height(200)
        },(item:newestMV)=>item.id.toString())
      }
      .autoPlay(true)
      .indicator(false)
    }
    .padding({right:10})
    .margin({bottom:20})
  }
  build() {
    Scroll(){
      Column({space:20}){
        //banner区域
        this.swiperBuilder()
        //最新专辑区域
        this.newestAlbumsBuilder()
        //最新MV区域
        this.newestMVBuilder()
      }
    }
    .margin({bottom:60})
    .width(BasicConstants.FULL_WIDTH)
    .padding({
      left:10
    })
  }
}