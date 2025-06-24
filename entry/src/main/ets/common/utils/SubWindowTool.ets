import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import log from '@open/log';

export class SubWindow{
  private windowStage: window.WindowStage | undefined = undefined;
  sub_windowClass: window.Window | undefined = undefined;
  private windowHeight:number = AppStorage.get('windowHeight')!
  private windowWidth:number = AppStorage.get('windowWidth')!
  hasSubWindow:boolean = false

  createSubWindow(name:string,page:string){
    // 获取windowStage
    this.windowStage = AppStorage.get('windowStage');
    // 1.创建应用子窗口。
    if (this.windowStage == null) {
      console.error('Failed to create the subwindow. Cause: windowStage_ is null');
    }
    else {
      if (!this.hasSubWindow) {
        this.windowStage?.createSubWindow("mySubWindow", (err: BusinessError, data) => {
          let errCode: number = err.code;
          if (errCode) {
            console.error('Failed to create the subwindow. Cause: ' + JSON.stringify(err));
            return;
          }
          this.sub_windowClass = data;
          console.info('Succeeded in creating the subwindow. Data: ' + JSON.stringify(data));
          // 2.子窗口创建成功后，设置子窗口的位置、大小及相关属性等。
          this.sub_windowClass.moveWindowTo(vp2px(20), vp2px(this.windowHeight - 120), (err: BusinessError) => {
            let errCode: number = err.code;
            if (errCode) {
              console.error('Failed to move the window. Cause:' + JSON.stringify(err));
              return;
            }
            console.info('Succeeded in moving the window.');
          });
          this.sub_windowClass.resize(vp2px(this.windowWidth - 40), vp2px(60), (err: BusinessError) => {
            let errCode: number = err.code;
            if (errCode) {
              console.error('Failed to change the window size. Cause:' + JSON.stringify(err));
              return;
            }
            console.info('Succeeded in changing the window size.');
          });
          // 3.为子窗口加载对应的目标页面。
          this.sub_windowClass.setUIContent("pages/PlaySubWindow", (err: BusinessError) => {
            //设置窗口透明背景色，不然圆角有底色
            this.sub_windowClass?.setWindowBackgroundColor('#00FFFFFF')
            let errCode: number = err.code;
            if (errCode) {
              console.error('Failed to load the content. Cause:' + JSON.stringify(err));
              return;
            }
            console.info('Succeeded in loading the content.');
            // 4.显示子窗口。
            (this.sub_windowClass as window.Window).showWindow((err: BusinessError) => {
              let errCode: number = err.code;
              if (errCode) {
                console.error('Failed to show the window. Cause: ' + JSON.stringify(err));
                return;
              }
              console.info('Succeeded in showing the window.');
            });
          });
          this.hasSubWindow = true
        })
      }
    }
  }
  destroySubWindow(){
    // 5.销毁子窗口。当不再需要子窗口时，可根据具体实现逻辑，使用destroy对其进行销毁。
    (this.sub_windowClass as window.Window).destroyWindow((err: BusinessError) => {
      let errCode: number = err.code;
      if (errCode) {
        console.error('Failed to destroy the window. Cause: ' + JSON.stringify(err));
        return;
      }
      this.hasSubWindow = false
      console.info('Succeeded in destroying the window.');
    });
  }
}
export const subWindow = new SubWindow()