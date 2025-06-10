import {BreakPointConstants} from  '../constants/BreakPointConstants'
import { mediaquery } from '@kit.ArkUI'

export class  BreakPointTool{
  //  初始化一个breakpoint，默认值无所谓，项目启动后以currentBreakPoint作为key，把查询到的屏幕大小保存到全局
  private currentBreakPoint:string = BreakPointConstants.BREAKPOINT_SM

  //  定义屏幕大小监听listener
  private smListener = mediaquery.matchMediaSync(BreakPointConstants.RANGE_SM)
  private mdListener = mediaquery.matchMediaSync(BreakPointConstants.RANGE_MD)
  private lgListener = mediaquery.matchMediaSync(BreakPointConstants.RANGE_LG)
  private xlListener = mediaquery.matchMediaSync(BreakPointConstants.RANGE_XL)

  //  定义公共函数，用来把监听到的屏幕大小(sm|md|lg|xl)保存到全局
  private updateCurrentBreakPoint(breakPoint:string){
    if(this.currentBreakPoint !== breakPoint){
      this.currentBreakPoint = breakPoint
    }
    //  存到全局，以currentBreakPoint作为key
    AppStorage.setOrCreate<string>(BreakPointConstants.CURRENT_BREAKPOINT,this.currentBreakPoint)
  }

  //  给监听器绑定change事件
  private isBreakPointSM = (mediaQueryResult:mediaquery.MediaQueryResult) => {  //手机
    if(mediaQueryResult.matches){
      this.updateCurrentBreakPoint(BreakPointConstants.BREAKPOINT_SM)
    }
  }
  private isBreakPointMD = (mediaQueryResult:mediaquery.MediaQueryResult) => {  //折叠屏
    if(mediaQueryResult.matches){
      this.updateCurrentBreakPoint(BreakPointConstants.BREAKPOINT_MD)
    }
  }
  private isBreakPointLG = (mediaQueryResult:mediaquery.MediaQueryResult) => {  //pad
    if(mediaQueryResult.matches){
      this.updateCurrentBreakPoint(BreakPointConstants.BREAKPOINT_LG)
    }
  }
  private isBreakPointXL = (mediaQueryResult:mediaquery.MediaQueryResult) => {  //笔记本
    if(mediaQueryResult.matches){
      this.updateCurrentBreakPoint(BreakPointConstants.BREAKPOINT_XL)
    }
  }

  //  定义一个公共函数，其他地方可以用来监听屏幕大小
  public breakPointRegister(){
    this.smListener = mediaquery.matchMediaSync(BreakPointConstants.RANGE_SM)
    this.smListener.on('change',this.isBreakPointSM)
    this.mdListener = mediaquery.matchMediaSync(BreakPointConstants.RANGE_MD)
    this.mdListener.on('change',this.isBreakPointMD)
    this.lgListener = mediaquery.matchMediaSync(BreakPointConstants.RANGE_LG)
    this.lgListener.on('change',this.isBreakPointLG)
    this.xlListener = mediaquery.matchMediaSync(BreakPointConstants.RANGE_XL)
    this.xlListener.on('change',this.isBreakPointXL)
  }

  // 解绑监听事件，优化内存空间
  public breakPointerOffRegister(){
    this.smListener.off('change',this.isBreakPointMD)
    this.mdListener.off('change',this.isBreakPointSM)
    this.lgListener.off('change',this.isBreakPointLG)
    this.xlListener.off('change',this.isBreakPointXL)
  }
}