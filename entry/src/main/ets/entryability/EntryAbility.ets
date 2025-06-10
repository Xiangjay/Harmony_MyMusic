import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BreakPointTool } from '../common/utils/BreakPointTool'
import { preferencesUtil } from '../common/utils/PreferencesUtils';
import {avPlayerManager} from '../common/utils/AVPlayerManager'

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private breakPointTool = new BreakPointTool()
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    //初始化用户首选项
    preferencesUtil.init(this.context, 'MyMusicStore')
    //获取用户设定的主题
    const theme = preferencesUtil.getData('theme')
    switch (theme) {
      case 'dark':
        this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
        break;
      case 'light':
        this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
      default:
        //如果theme拿不到数据说明用户第一次进入该应用，那就设置默认主题
        this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
        break;
    }
    console.log('onCreate', theme)
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    windowStage.loadContent('pages/EntryPage', (err) => {
      //注册封装好的媒体查询
      this.breakPointTool.breakPointRegister()
      //初始化封装好的媒体播放器
      avPlayerManager.initAudioPlayer()
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    this.breakPointTool.breakPointerOffRegister()
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