import { BasicConstants } from "../../common/constants/BasicConstants"
import { AlertDialog, window } from '@kit.ArkUI'
import { common, ConfigurationConstant } from '@kit.AbilityKit'
import {preferencesUtil} from '../../common/utils/PreferencesUtils'
import { preferences } from '@kit.ArkData'

@Component
export struct SideBar {
  @Link showSideBar:boolean
  //从用户首选项中拿用户设定的主题，如果拿不到theme代表用户第一次进入该应用，要让用户选择主题
  @State theme:preferences.ValueType = preferencesUtil.getData('theme')
  private context = getContext(this) as common.UIAbilityContext	//拿到当前上下文
  windowClass: window.Window = AppStorage.get("windowClass") as window.Window;	//拿到全局window对象

  //更换主题弹窗
  dialogController: CustomDialogController = new CustomDialogController({
  builder: AlertDialog({
    primaryTitle:'请选择应用主题',
    primaryButton: {
      value: '深色',
      fontColor:'#6eafbb',
      action: () => {
        this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
        preferencesUtil.insertData('theme','dark')
        this.windowClass.setWindowSystemBarProperties({
          statusBarContentColor: '#ffffff'
        });
      },
    },
    secondaryButton: {
      value: '浅色',
      fontColor:'#86868f',
      action: () => {
        this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
        preferencesUtil.insertData('theme','light')
        this.windowClass.setWindowSystemBarProperties({
          statusBarContentColor: '#000000'
        });
      }
    },
  })
})

  @Builder SideBarBannerBuilder(){
    Column(){
      Image($r('app.media.more_banner'))
        .width(BasicConstants.FULL_WIDTH)
        .borderRadius(10)
      Row(){
        Row(){
          Image($r('app.media.icon_free'))
            .width(20)
            .fillColor($r('app.color.icon_svg_selected'))
          Text('免费听VIP歌曲')
            .fontSize(BasicConstants.FONT_SIZE_SMALL)
            .fontColor($r('app.color.text_default'))
            .margin({left:10})
        }
        Text('领时长')
          .fontColor($r('app.color.icon_svg_selected'))
          .fontSize(BasicConstants.FONT_SIZE_SMALL)
          .padding({
            left:10,
            right:10,
            top:5,
            bottom:5
          })
          .border({
            width:1,
            color:$r('app.color.icon_svg_selected'),
            radius : 20
          })
      }
      .padding(10)
      .borderRadius(5)
      .width(BasicConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('app.color.content_background'))
    }
  }
  //侧边栏List列表
  @Builder SideBarListBuilder(){
    List(){
      ListItemGroup(){
        ListItem(){
          this.SideBarListItemBuilder($r('app.media.icon_message'),'我的消息')
        }
        ListItem(){
          this.SideBarListItemBuilder($r('app.media.icon_cloud'),'我的云贝','iPhone16开奖中')
        }
        ListItem(){
          this.SideBarListItemBuilder($r('app.media.icon_cloth'),'装扮中心','哪吒套装来袭!')
        }
        ListItem(){
          this.SideBarListItemBuilder($r('app.media.icon_bulb'),'创作者中心')
        }
      }
      ListItemGroup(){
        ListItem(){
          this.SideBarListItemBuilder($r('app.media.icon_clock'),'最近播放')
        }
        ListItem(){
          this.SideBarListItemBuilder($r('app.media.icon_setTime'),'定时关闭')
        }
      }
      ListItemGroup(){
        ListItem(){
          this.SideBarListItemBuilder($r('app.media.icon_mall'),'商城')
        }
        ListItem(){
          this.SideBarListItemBuilder($r('app.media.icon_ticket'),'云村有票')
        }
        ListItem(){
          this.SideBarListItemBuilder($r('app.media.icon_hot'),'云推歌')
        }
        ListItem(){
          this.SideBarListItemBuilder($r('app.media.icon_service'),'我的客服')
        }
        ListItem(){
          this.SideBarListItemBuilder($r('app.media.icon_theme'),'主题设置')
        }
        .onClick(()=>{
          this.dialogController.open()
        })
      }
    }
    .divider({
      strokeWidth:1,
      color:$r('app.color.window_background'),
      startMargin:10,
      endMargin:10
    })
  }
  //侧边栏listItem
  @Builder SideBarListItemBuilder(icon:Resource, title:string, text?:string){
    Row(){
      Row({space:10}){
        Image(icon)
          .width(20)
          .fillColor($r('app.color.icon_svg_default'))
        Text(title)
          .fontColor($r('app.color.text_default'))
          .fontSize(BasicConstants.FONT_SIZE_SMALL)
      }
      .width('50%')
      Row(){
        Text(text)
          .fontSize(BasicConstants.FONT_SIZE_XSMALL)
          .fontColor($r('app.color.text_default'))
          .maxLines(1)
          .textOverflow({overflow:TextOverflow.Ellipsis})
      }
      .justifyContent(FlexAlign.Center)
      .width('50%')
    }
    .width(BasicConstants.FULL_WIDTH)
    .padding({
      top:10,
      bottom:10,
      left:15,
      right:15
    })
  }
  //侧边栏
  @Builder sideBar(){
    Flex(){
      Column({space:10}){
        //立刻登录部分
        Row(){
          Row(){
            Image($r('app.media.icon_avatar'))
              .width(35)
              .fillColor($r('app.color.icon_svg_selected'))
            Text('立刻登录')
              .fontColor($r('app.color.text_default'))
              .fontSize(BasicConstants.FONT_SIZE_LARGE)
              .margin({left:10})
            Image($r('app.media.icon_arrow_right'))
              .width(20)
              .fillColor($r('app.color.text_default'))
          }
          Image($r('app.media.icon_scan'))
            .width(30)
            .fillColor($r('app.color.icon_svg_default'))
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(BasicConstants.FULL_WIDTH)
        Scroll(){
          Column(){
            //banner部分
            this.SideBarBannerBuilder()
            //list部分
            Column(){
              this.SideBarListBuilder()
            }
            .backgroundColor($r('app.color.content_background'))
            .width(BasicConstants.FULL_WIDTH)
            // .height(BasicConstants.FULL_HEIGHT)
            .borderRadius(5)
            .margin({
              top:10
            })
          }
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
        .fadingEdge(true)
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      .backgroundColor($r('app.color.window_background'))
      .width('80%')
      .padding({left:10,right:10})
      .height(BasicConstants.FULL_HEIGHT)
      //右侧阴影背景部分，用来点击收起侧边栏
      Column(){
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      .backgroundColor($r('app.color.window_background'))
      .opacity(0.5)
      .width('20%')
      .height(BasicConstants.FULL_HEIGHT)
      .onClick(()=>{
        this.showSideBar = !this.showSideBar
      })
    }
    .width(BasicConstants.FULL_WIDTH)
    .height(BasicConstants.FULL_HEIGHT)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
  build() {
    this.sideBar()
  }
}