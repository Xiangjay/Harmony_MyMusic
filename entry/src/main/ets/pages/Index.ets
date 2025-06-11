import { BreakPointConstants } from '../common/constants/BreakPointConstants'
import {BasicConstants} from '../common/constants/BasicConstants'
import { Main } from '../components/Main';
import { My } from '../components/My';
import { Note } from '../components/Note';
import { router } from '@kit.ArkUI';


@Entry
@Component
struct Index {
  @StorageProp(BreakPointConstants.CURRENT_BREAKPOINT) currentBreakPoint:string = BreakPointConstants.BREAKPOINT_SM
  @State currentIndex: number = 0;
  private tabController:TabsController = new TabsController()

  @Builder tabBarBuilder(title: string, targetIndex: number, icon: Resource) {
    Column({space:5}) {
      Image(icon)
        .width(25)
        .fillColor(this.currentIndex === targetIndex ? $r('app.color.icon_svg_selected') : $r('app.color.icon_svg_default'))
      Text(title)
        .fontSize(BasicConstants.FONT_SIZE_SMALL)
        .fontWeight(this.currentIndex === targetIndex ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentIndex === targetIndex ? $r('app.color.icon_svg_selected') : $r('app.color.icon_svg_default'))
    }
    .onClick(()=>{
      if(targetIndex === 1){
        router.pushUrl({
          url:'pages/Music'
        })
      }else {
        this.tabController.changeIndex(targetIndex)
      }
    })
    .justifyContent(FlexAlign.Center)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  build() {
    Tabs({controller: this.tabController, barPosition: this.currentBreakPoint === BreakPointConstants.BREAKPOINT_SM || this.currentBreakPoint === BreakPointConstants.BREAKPOINT_MD ? BarPosition.End : BarPosition.Start }){
      TabContent(){
        Main()
      }
      .backgroundColor($r('app.color.content_background'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
      .tabBar(this.tabBarBuilder('首页',0,$r("app.media.icon_recommend")))
      TabContent(){
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
      .tabBar(this.tabBarBuilder('音乐',1,$r("app.media.icon_find")))
      TabContent(){
        Note()
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
      .tabBar(this.tabBarBuilder('MV',2,$r("app.media.icon_note")))
      TabContent(){
        My()
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
      .tabBar(this.tabBarBuilder('我的',3,$r("app.media.icon_my")))
    }
    .scrollable(false)
    .backgroundColor($r('app.color.window_background'))
    .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
    .onChange((index:number)=>{
      this.currentIndex = index
    })
  }
}