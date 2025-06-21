import { relationalStore } from '@kit.ArkData';
import {DataBaseResponseModel, MVModel} from '../models/DataModels'

//关系型数据库
class RecentMVsDBUtils {
  private rdbStore: relationalStore.RdbStore | null = null
  initDB(context: Context, tableName: string) {
    //(1)初始化数据库配置
    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: 'myMusic.recentMVs.db',
      securityLevel: relationalStore.SecurityLevel.S3,
    };
    //(2)定义sql语句
    const SQL_CREATE_TABLE = `CREATE TABLE IF NOT EXISTS ${tableName} (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    NAME TEXT NOT NULL,
    PICURL TEXT,
    URL TEXT,
    ARTISTNAME TEXT,
    ARTISTID INTEGER,
    SAVETIME INTEGER NOT NULL
    )`; // 建表Sql语句, 这里参数里每一行相当于一列
    //(3)初始化数据库，异步
    relationalStore.getRdbStore(context, STORE_CONFIG, (err, store) => {
      if (err) {
        console.error(`关系型数据库初始化失败. Code:${err.code}, message:${err.message}`);
        return;
      }
      console.info('关系型数据库初始化成功')
      this.rdbStore = store

      //有了数据库就可以操作了
      store.executeSql(SQL_CREATE_TABLE, (error) => {
        if (error) {
          console.log(`关系型数据库${tableName}表格创建失败`)
        }
        console.log(`关系型数据库${tableName}表格创建成功`)
      })
    })
  }
  async insertData(tableName: string, value: relationalStore.ValuesBucket): Promise<DataBaseResponseModel> {
    if (this.rdbStore !== null) {
      try {
        let res = await this.rdbStore.insert(tableName, value)
        console.log(`往关系型数据库${tableName}表中插入数据成功，rowId:${res}`)
        return {
          code:0,
          message:`插入数据成功`
        }
      }catch (err) {
        console.log(`往关系型数据库${tableName}表中插入数据失败，Code:${err.code},message:${err.message}`)
        return {
          code:1,
          message:`插入数据失败`
        }
      }
    }
    return {
      code:-1,
      message:'没有rdbStore'
    }
  }
  async queryData(tableName: string, column?: Array<string>, id?: number): Promise<Array<MVModel>> {
    //获取要操作的表
    let predicates = new relationalStore.RdbPredicates(tableName);
    if (id) {
      //筛选条件，选中指定数据
      predicates.equalTo('ID', id);
    }
    //查询到的所有数据
    let mvs: Array<MVModel> = []
    if (this.rdbStore !== null) {
      //查询数据库是异步的，并且得到一个结果集，我们要把返回的结果集处理成我们想要的数据
      let result = await this.rdbStore.query(predicates,column)
      //下面这段代码有个专业名词叫ORM，将对象和数据库进行相互的转换
      while (result.goToNextRow()) { //goToNextRow判断结果集是否有下一条数据
        let id = result.getLong(result.getColumnIndex('ID'))
        let name = result.getString(result.getColumnIndex('NAME'))
        let picUrl = result.getString(result.getColumnIndex('PICURL'))
        let url = result.getString(result.getColumnIndex('URL'))
        let artistId = result.getLong(result.getColumnIndex('ARTISTID'))
        let artistName = result.getString(result.getColumnIndex('ARTISTNAME'))
        let saveTime = result.getLong(result.getColumnIndex('SAVETIME'))
        const temp:MVModel = new MVModel()
        temp.id = id
        temp.name = name
        temp.picUrl = picUrl
        temp.url = url
        temp.artistName = JSON.parse(artistName)
        temp.artistId = artistId
        temp.saveTime = saveTime
        mvs.push(temp)
      }
      //释放内存的结果集
      result.close()
      mvs.sort((a,b)=>{
        return b.saveTime! - a.saveTime!
      })
      return mvs
    }
    return []
  }
  async updateDataById(tableName: string, id: number, value: relationalStore.ValuesBucket):Promise<DataBaseResponseModel> {
    //获取要操作的表
    let predicates = new relationalStore.RdbPredicates(tableName);
    //筛选条件，选中要更新的数据
    predicates.equalTo('ID', id);
    if (this.rdbStore !== null) {
      let res = await this.rdbStore.update(value, predicates)
      if(res === 1){
        console.log(`从关系型数据库${tableName}表里修改数据成功: 更新了${res}行数据`)
        return {
          code:0,
          message:`修改成功`
        }
      }else{
        console.log(`从关系型数据库${tableName}表中修改数据失败，${res}`)
        return {
          code:1,
          message:`修改失败`
        }
      }
    }
    return {
      code:-1,
      message:'没有rdbStore'
    }
  }
  async deleteDataById(tableName: string, id: number):Promise<DataBaseResponseModel> {
    //获取要操作的表
    let predicates = new relationalStore.RdbPredicates(tableName);
    //筛选条件，选中要删除的数据
    predicates.equalTo('ID', id);

    if (this.rdbStore !== null) {
      const res = await this.rdbStore.delete(predicates)
      if(res === 1){
        console.log(`从关系型数据库${tableName}表中删除数据成功，影响行数:${res}`)
        return {
          code:0,
          message:`删除成功`
        }
      }else{
        console.log(`从关系型数据库${tableName}表中删除数据失败，${res}`)
        return {
          code:1,
          message:`删除失败`
        }
      }
    }
    return {
      code:-1,
      message:'没有rdbStore'
    }
  }
}
export const recentMVsDB = new RecentMVsDBUtils()