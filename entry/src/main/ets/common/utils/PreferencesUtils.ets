import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

export class PreferencesUtils {
  private dataPreferences: preferences.Preferences | null = null;
  /*
   * 初始化preferences对象
   * @param context 上下文对象
   * @param storeName 首选项对象名字
  */
  init(context:Context, storeName:string){
    let options: preferences.Options = { name: storeName };
    this.dataPreferences = preferences.getPreferencesSync(context, options);
    let observer = (key: string) => {
      //从内存持久化到硬盘
      (this.dataPreferences as preferences.Preferences).flush((err: BusinessError) => {
        if (err) {
          console.error(`Failed to flush. Code:${err.code}, message:${err.message}`);
          return;
        }
        console.info('Succeeded in flushing.');
      })
    }
    this.dataPreferences.on('change', observer);
  }
  /*
   * 添加数据
   * @param context 上下文对象
   * @param key key名
   * @param value 数据
  */
  insertData(key:string, value:string){
    if(this.dataPreferences){
      this.dataPreferences.putSync(key, value);
      this.dataPreferences.flushSync()
      console.log(`首选项数据添加成功`)
      // if (this.dataPreferences.hasSync(key)) {
      //   console.info(`用户首选项中${key}已存在`);
      // } else {
      //   // 此处以此键值对不存在时写入数据为例
      //   this.dataPreferences.putSync(key, value);
      //   console.log(`首选项数据添加成功`)
      //   // 当字符串有特殊字符时，需要将字符串转为Uint8Array类型再存储
      //   // let uInt8Array1 = new util.TextEncoder().encodeInto("~！@#￥%……&*（）——+？");
      //   // this.dataPreferences.putSync('uInt8', uInt8Array1);
      // }
    }
  }
  getData(key:string,value?:string){
    if(this.dataPreferences && this.dataPreferences.hasSync(key)){
      let val = this.dataPreferences.getSync(key, value?value:'');
      console.info(`读取用户首选项数据${key}成功`);
      return val
    }else{
      return ''
    }
  }

  deleteData(key:string){
    if(this.dataPreferences){
      this.dataPreferences.deleteSync(key);
    }
  }
}

//直接暴露实例出去，这样外面用的时候就不用new了
export const preferencesUtil = new PreferencesUtils()