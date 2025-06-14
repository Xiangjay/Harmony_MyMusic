import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BreakPointTool } from '../common/utils/BreakPointTool'
import { preferencesUtil } from '../common/utils/PreferencesUtils';
import {avPlayerManager} from '../common/utils/AVPlayerManager'
import { aVSessionManger } from '../common/utils/AVSessionManager';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private breakPointTool = new BreakPointTool()
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {

  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    windowStage.loadContent('pages/EntryPage', (err) => {
      /*
       * 设置窗口全屏
       * 1. 获取应用主窗口并设置窗口全屏
       * 2. 获取布局避让遮挡的区域
       * 3. 注册监听函数，动态获取避让区域数据
      */
      // 获取应用主窗口
      let windowClass: window.Window = windowStage.getMainWindowSync();
      // 1. 设置窗口全屏
      windowClass.setWindowLayoutFullScreen(true)
      // 2. 获取布局避让遮挡的区域
      const top = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height
      AppStorage.setOrCreate<number>('safeTop', px2vp(top));
      const bottom = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height
      AppStorage.setOrCreate<number>('safeBottom', px2vp(bottom));
      // 3. 注册监听函数，动态获取避让区域数据
      windowClass.on('avoidAreaChange', (data) => {
        if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
          let top = data.area.topRect.height;
          AppStorage.setOrCreate<number>('safeTop', px2vp(top));
        } else if (data.type == window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          let bottom = data.area.bottomRect.height;
          AppStorage.setOrCreate<number>('safeBottom', px2vp(bottom));
        }
      });
      // 设置顶部状态栏隐藏
      // windowClass.setSpecificSystemBarEnabled('status', false)
      // 设置底部导航条隐藏
      windowClass.setSpecificSystemBarEnabled('navigationIndicator', false)
      // 保存到全局方便其他页面设置
      AppStorage.setOrCreate('windowClass', windowClass);

      //初始化用户首选项
      preferencesUtil.init(this.context, 'MyMusicStore')
      //获取用户设定的主题
      const theme = preferencesUtil.getData('theme')
      switch (theme) {
        case 'dark':
          this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
          windowClass.setWindowSystemBarProperties({
            statusBarContentColor: '#ffffff'
          });
          break;
        case 'light':
          this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
          windowClass.setWindowSystemBarProperties({
            statusBarContentColor: '#000000'
          });
        default:
        //如果theme拿不到数据说明用户第一次进入该应用，那就设置默认主题
          this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
          break;
      }

      //注册封装好的媒体查询
      this.breakPointTool.breakPointRegister()

      //初始化封装好的媒体播放器和长时任务
      avPlayerManager.initAudioPlayer()
      aVSessionManger.initAvSession(this.context)

      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    this.breakPointTool.breakPointerOffRegister()
    aVSessionManger.destroy()
    avPlayerManager.release()
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
    // this.breakPointTool.breakPointerOffRegister()
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}