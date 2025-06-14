import { BreakPointConstants } from '../common/constants/BreakPointConstants'
import {BasicConstants} from '../common/constants/BasicConstants'
import { Main } from '../components/Main';
import { My } from '../components/My';
import { router } from '@kit.ArkUI';
import log from '@open/log';

@Entry
@Component
struct Index {
  @StorageProp('safeTop') safeTop: number = 0;
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
      }else if(targetIndex === 2) {
        router.pushUrl({
          url:'pages/MV'
        })
      }else {
        this.tabController.changeIndex(targetIndex)
      }
    })
    .width(BasicConstants.FULL_WIDTH)
    .height(BasicConstants.FULL_HEIGHT)
    .backgroundColor($r('app.color.main_tab_background'))
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Tabs({controller: this.tabController, barPosition: this.currentBreakPoint === BreakPointConstants.BREAKPOINT_SM || this.currentBreakPoint === BreakPointConstants.BREAKPOINT_MD ? BarPosition.End : BarPosition.Start }){
      TabContent(){
        Main()
      }
      .tabBar(this.tabBarBuilder('首页',0,$r("app.media.icon_home")))
      TabContent(){
      }
      .tabBar(this.tabBarBuilder('音乐',1,$r("app.media.icon_music")))
      TabContent(){
      }
      .tabBar(this.tabBarBuilder('MV',2,$r("app.media.icon_mv")))
      TabContent(){
        My()
      }
      .tabBar(this.tabBarBuilder('我的',3,$r("app.media.icon_my")))
    }
    .barHeight(BasicConstants.MAIN_TAB_BAR_HEIGHT)
    .scrollable(false)
    .backgroundColor($r('app.color.content_background'))
    .onChange((index:number)=>{
      this.currentIndex = index
    })
    .padding({
      top: this.safeTop
    })
  }
}