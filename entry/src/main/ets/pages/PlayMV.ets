import { router } from '@kit.ArkUI'
import log from '@open/log'
import { routerParams } from '../models/DataModels'
import { BasicConstants } from '../common/constants/BasicConstants'

@Entry
@Component
struct PlayMV {
  private controller: VideoController = new VideoController()
  @State mvId:number = 0
  @State data:string[] = []
  @StorageProp('safeTop') safeTop: number = 0;
  @StorageProp('safeBottom') safeBottom: number = 0;

  aboutToAppear(): void {
    for (let index = 0; index < 100; index++) {
      this.data.push(index.toString())
    }
    // this.mvId = (router.getParams() as routerParams<number>).param
    // log.info(this.mvId)
  }

  // build() {
  //   Column() {
  //     Stack({alignContent:Alignment.Top}){
  //       Row(){
  //         Row({space:5}) {
  //           Image($r('app.media.icon_back'))
  //             .width(30)
  //             .height(30)
  //             .fillColor(Color.White)
  //             .onClick(() => {
  //               router.back()
  //             })
  //         }
  //         .justifyContent(FlexAlign.Start)
  //         .width(BasicConstants.FULL_WIDTH)
  //       }
  //       .padding({
  //         left:10
  //       })
  //       Swiper() {
  //         ForEach(this.data, (item: string, index: number) => {
  //           Stack({ alignContent: Alignment.BottomEnd }) {
  //             Column(){
  //               Text(item)
  //                 .fontColor(Color.Blue)
  //             }
  //             .justifyContent(FlexAlign.Center)
  //             .backgroundColor(Color.White)
  //             .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
  //             .width('100%')
  //             .height('100%')
  //           }
  //         })
  //       }
  //       // .index(videoIndex)
  //       .autoPlay(false)
  //       .indicator(false)
  //       .loop(true)
  //       .duration(200)
  //       .vertical(true)
  //       .width('100%')
  //       .height('100%')
  //       .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
  //     }
  //     // Video({
  //     //   src: 'http://vodkgeyttp8.vod.126.net/cloudmusic/MjQ3NDQ3MjUw/89a6a279dc2acfcd068b45ce72b1f560/533e4183a709699d566180ed0cd9abe9.mp4?wsSecret=f8826239faf247408b689934cb4577f0&wsTime=1749808473',
  //     //   previewUri: 'http://p1.music.126.net/ijUg7s_2S8GMbTNsYiepJA==/18676304511774727.jpg',
  //     //   controller: this.controller
  //     // })
  //   }
  //   .width(BasicConstants.FULL_WIDTH)
  //   .height(BasicConstants.FULL_HEIGHT)
  //   .backgroundColor(Color.Black)
  //   .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
  // }
  build() {
    Column(){
      Text('123123')
        .fontColor(Color.Black)
    }
    .justifyContent(FlexAlign.End)
    .backgroundColor(Color.White)
    .width('100%')
    .height('100%')
    .padding({
      top:this.safeTop,
      // bottom:this.safeBottom
    })
    // Scroll() {
    //   Column() {
    //     Swiper() {
    //       ForEach(this.data, (item: string, index: number) => {
    //         Column() {
    //             // Video({
    //             //   src: 'http://vodkgeyttp8.vod.126.net/cloudmusic/MjQ3NDQ3MjUw/89a6a279dc2acfcd068b45ce72b1f560/533e4183a709699d566180ed0cd9abe9.mp4?wsSecret=f8826239faf247408b689934cb4577f0&wsTime=1749808473',
    //             //   previewUri: 'http://p1.music.126.net/ijUg7s_2S8GMbTNsYiepJA==/18676304511774727.jpg',
    //             //   controller: this.controller
    //             // })
    //         }
    //         .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    //         .width('100%')
    //         .height('100%')
    //         .backgroundColor(Color.Pink)
    //       })
    //     }
    //     .itemSpace(0)
    //     .vertical(true)
    //     .autoPlay(true)
    //     .loop(true)
    //     .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    //     .clip(false)
    //   }
    //   .clip(false)
    //   .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    //   .width('100%')
    //   .height('100%')
    // }
    // .edgeEffect(EdgeEffect.None)
    // .clip(false)
    // .width("100%")
    // .height("100%")
    // .backgroundColor(Color.Black)
  }
}