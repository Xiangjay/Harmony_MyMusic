import { BasicConstants } from '../common/constants/BasicConstants'
import { BreakPointConstants } from '../common/constants/BreakPointConstants'
import { router, AlertDialog, window } from '@kit.ArkUI'
import { common, ConfigurationConstant } from '@kit.AbilityKit'
import {preferencesUtil} from '../common/utils/PreferencesUtils'
import { preferences } from '@kit.ArkData'

@Entry
@Component
struct EntryPage {
  @StorageProp('safeTop') safeTop: number = 0;
  @StorageProp(BreakPointConstants.CURRENT_BREAKPOINT) currentBreakPoint: string = BreakPointConstants.BREAKPOINT_SM
  @State timeLeft: number = 1
  @State entryImages:ResourceStr[] = [$r('app.media.entry_Img1'),$r('app.media.entry_Img2')]
  @State entryImage:ResourceStr = ''
  private intervalId: number = 0
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
          this.startInterval()
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
          this.startInterval()
        }
      },
    }),
    onWillDismiss:(dismissDialogAction: DismissDialogAction)=> {
      //该方法可以阻止用户点击返回键、点击遮障层已经侧滑时关闭弹窗
    },
  })

  startInterval = ()=>{
    // 倒计时
    this.intervalId = setInterval(() => {
      this.timeLeft--
      if (this.timeLeft === 0) {
        router.replaceUrl({
          url: 'pages/Index'
        })
      }
    }, 1000)
  }
  aboutToAppear(): void {
    const randomImage:number = Math.floor(Math.random())
    this.entryImage = randomImage < 5 ? this.entryImages[0] : this.entryImages[1]
    //用户第一次进入该APP时，让用户选择主题
    if(!this.theme){
      this.dialogController.open()
    }else {
      this.startInterval()
    }
  }

  aboutToDisappear(): void {
    clearInterval(this.intervalId)
  }

  build() {
    Stack({alignContent:Alignment.TopEnd}){
      Image(this.entryImage)
        .width(BasicConstants.FULL_WIDTH)
        .height(BasicConstants.FULL_HEIGHT)
      Button('跳过 ' + this.timeLeft)
        .fontSize(this.currentBreakPoint === BreakPointConstants.BREAKPOINT_XL ? BasicConstants.FONT_SIZE_XLARGE : this.currentBreakPoint === BreakPointConstants.BREAKPOINT_LG ? BasicConstants.FONT_SIZE_LARGE : BasicConstants.FONT_SIZE_SMALL)
        .backgroundColor('#3b3f42')
        .fontColor(Color.White)
        .margin({
          right: 15,
          top: this.safeTop
        })
        .onClick(() => {
          router.replaceUrl({
            url: 'pages/Index'
          })
        })
    }
    .width(BasicConstants.FULL_WIDTH)
    .height(BasicConstants.FULL_WIDTH)
  }
}