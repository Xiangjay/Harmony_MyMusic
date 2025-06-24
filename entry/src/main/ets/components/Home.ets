import { BasicConstants } from '../common/constants/BasicConstants'
import {SideBar} from './Home/SideBar'
import {getDefaultKeywords} from '../common/apis/HomeApis'
import {SearchKeyWordInterface} from '../models/DataModels'
import { Recommend } from './Home/Recommend'
import { Empty } from './common/Empty'
import { Newest } from './Home/Newest'
import { Rank } from './Home/Rank'
import { common, Permissions } from '@kit.AbilityKit'
import { reqPermissionsFromUser } from '../common/utils/PermissionsFromUser'
import { PromptAction } from '@kit.ArkUI'
import { Program } from './Home/Program'

@Component
export struct Home {
  @State showSideBar:boolean = false  //控制是否显示侧边栏
  @State defaultKeywords:string = ''  //搜索框默认搜索关键字
  @State currentIndex: number = 0;
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();  //提示弹窗

  //获取搜索框默认搜索关键字
  getDefaultKeywords = async () => {
    const res = await getDefaultKeywords<SearchKeyWordInterface,null>()
    this.defaultKeywords = res.data.showKeyword
  }
  //获取麦克风权限
  getMicroPhoneAccess = async () => {
    const context:common.UIAbilityContext = getContext(this) as common.UIAbilityContext	//拿到当前上下文
    const permissions:Array<Permissions> = ['ohos.permission.MICROPHONE']
    const res = await reqPermissionsFromUser(permissions,context)
    if(res === 1){
      this.promptAction.showToast({
        message: '该功能还没做，只为展示授权麦克风弹窗用',
        duration: 2000,
      })
    }
  }

  aboutToAppear(): void {
    this.getDefaultKeywords()
  }
  //顶部搜索栏
  @Builder topBar(){
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      //左侧显示更多按钮
      Image($r("app.media.icon_side"))
        .height(25)
        .width(25)
        .fillColor($r('app.color.icon_svg_selected'))
        .onClick(()=>{
          this.showSideBar = !this.showSideBar
        })
      //中间假搜索框
      RelativeContainer() {
        //假搜索框上的图标和文字，用相对定位
        Flex({alignItems:ItemAlign.Center,justifyContent:FlexAlign.SpaceBetween}) {
          Row(){
            Column(){
              Image($r('app.media.icon_search'))
                .width(20)
                .fillColor($r('app.color.text_gray'))
            }
            Column(){
              Text(this.defaultKeywords)
                .fontColor($r('app.color.text_gray'))
                .fontSize(BasicConstants.FONT_SIZE_SMALL)
                .margin({ left: 5 })
                .maxLines(1)
                .textOverflow({overflow:TextOverflow.Ellipsis})
            }
          }
          .flexGrow(1)
          Column(){
            Image($r('app.media.icon_scan'))
              .width(20)
              .fillColor($r('app.color.text_gray'))
          }
          .margin({
            left:30
          })
        }
        .height(40)
        .width(240)
        .alignRules({
          'center': { 'anchor': '__container__', 'align': VerticalAlign.Center },
          'middle': { 'anchor': '__container__', 'align': HorizontalAlign.Center }
        })
      }
      .backgroundColor($r('app.color.text_input_background'))
      .height(40)
      .width(260)
      .borderRadius(20)
      //右面的麦克风图标
      Image($r('app.media.icon_mic'))
        .height(25)
        .fillColor($r('app.color.icon_svg_selected'))
        .onClick(()=>{
          this.getMicroPhoneAccess()
        })
    }
    .padding(10)
    .width(BasicConstants.FULL_WIDTH)
  }

  @Builder tabBarBuilder(title:string,targetIndex: number){
    Column(){
      Text(title)
        .fontSize(BasicConstants.FONT_SIZE_NORMAL)
        .fontWeight(this.currentIndex === targetIndex ? FontWeight.Bold : FontWeight.Normal)
        .fontColor($r('app.color.text_default'))
    }
    .justifyContent(FlexAlign.Center)
    .width('80%')
    .height(BasicConstants.FULL_HEIGHT)
    .border({
      width: {
        left:0,
        right:0,
        top:0,
        bottom:this.currentIndex === targetIndex ? 2 : 0
      },
      color:$r('app.color.icon_svg_selected'),
    })
  }

  build() {
    //因为有左上角的按钮，所以整个组件是一个侧边栏容器
    SideBarContainer(SideBarContainerType.Overlay){
      //侧边栏
      SideBar({showSideBar:this.showSideBar})
      //正常内容区域
      Column(){
        this.topBar()
        Tabs() {
          TabContent() {
            Recommend({currentIndex:this.currentIndex})
          }
          .tabBar(this.tabBarBuilder('推荐',0))
          TabContent() {
            Newest()
          }
          .tabBar(this.tabBarBuilder('最新',1))
          TabContent() {
            Rank()
          }
          .tabBar(this.tabBarBuilder('排行榜',2))
          TabContent() {
            Program()
          }
          .tabBar(this.tabBarBuilder('节目',3))
          TabContent() {
            Empty({isPage:false})
          }
          .tabBar(this.tabBarBuilder('免费听',4))
        }
        .barHeight(50)
        .divider({
          strokeWidth:0.5,
          color:$r('app.color.tab_divider')
        })
        .onChange((index:number)=>{
          this.currentIndex = index
        })
        .padding({
          left:10,
          right:10
        })
        .width(BasicConstants.FULL_WIDTH)
        .height(BasicConstants.FULL_HEIGHT)
      }
      .width(BasicConstants.FULL_WIDTH)
      .height(BasicConstants.FULL_HEIGHT)
    }
    .backgroundColor($r('app.color.content_background'))
    .sideBarWidth(BasicConstants.FULL_WIDTH)
    .showControlButton(false)
    .showSideBar(this.showSideBar)
    .animation({duration:300})
  }
}