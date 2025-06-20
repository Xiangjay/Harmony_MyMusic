import { getMusicBanner, getNewestAlbumsList, getNewestMVList } from '../../common/apis/HomeApis'
import { BasicConstants } from '../../common/constants/BasicConstants'
import {Title} from '../common/Title'
import {banner,PlayListModel,MVModel,musicRouterParamsModel,
  playListType,
  mvRouterParamsModel} from '../../models/DataModels'
import { myDataMerge } from '../../common/utils/CommonTools'
import { Loading } from '../common/Loading'
import { router } from '@kit.ArkUI'
import { MvSwiper } from '../common/MvSwiper'

@Component
export struct Newest {
  @State banners:Array<banner> = []
  @State newestAlbumsList:Array<PlayListModel> = []
  @State newestMVList:Array<MVModel> = []
  @State isLoading:boolean = true

  getBanner = async () => {
    const res = await getMusicBanner<Array<banner>,null>()
    this.banners = res.banners
    this.isLoading = false
  }
  //获取最新专辑
  getNewestAlbumsList = async () =>{
    const res = await getNewestAlbumsList<Array<PlayListModel>,null>()
    res.albums.forEach(item=>{
      this.newestAlbumsList.push(myDataMerge<PlayListModel>(new PlayListModel(),item))
    })
    this.isLoading = false
  }
  //获取最新MV
  getNewestMVList = async () =>{
    const res = await getNewestMVList<Array<MVModel>,null>()
    res.data.forEach(item=>{
      this.newestMVList.push(myDataMerge<MVModel>(new MVModel(),item))
    })
    this.isLoading = false
  }

  aboutToAppear(): void {
    // this.getBanner()
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
      List({space:10}){
        ForEach(this.newestAlbumsList,(item:PlayListModel)=>{
          ListItem(){
            RelativeContainer(){
              Image(item.picUrl)
                .width(BasicConstants.FULL_WIDTH)
                .height(BasicConstants.FULL_HEIGHT)
                .onClick(()=>{
                  const param:musicRouterParamsModel = {
                    id:item.id,
                    type:playListType.album
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
      .edgeEffect(EdgeEffect.None)
      .fadingEdge(true)
      .width(BasicConstants.FULL_WIDTH)
      .height(200)  //  变成横向布局后list会默认非常高，所以高度限制一下
    }
    .margin({top:20})
  }
  @Builder newestMVBuilder(){
    Column({space:10}){
      Title({title:'最新MV'})
      MvSwiper({mvList:this.newestMVList})
    }
    .padding({right:10})
    .margin({bottom:20})
  }

  build() {
    // Scroll(){
      Column({space:30}){
        if(!this.isLoading){
          //最新专辑区域
          this.newestAlbumsBuilder()
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
      //内容没铺满高度，所以要有下面的属性
      .height(BasicConstants.FULL_HEIGHT)
      .width(BasicConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.Start)
      .padding({bottom:BasicConstants.MAIN_TAB_BAR_HEIGHT})
    }
    // .scrollBar(BarState.Off)
    // .edgeEffect(EdgeEffect.Fade)
    // .margin({bottom:BasicConstants.MAIN_TAB_BAR_HEIGHT})
    // .height(BasicConstants.FULL_HEIGHT)
    // .width(BasicConstants.FULL_WIDTH)
  // }
}