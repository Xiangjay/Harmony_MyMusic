import { relationalStore } from '@kit.ArkData';
import log from '@open/log';
import {DataBaseResponseModel, PlayListModel} from '../models/DataModels'

//关系型数据库
class PlayListDBUtils {
  private rdbStore: relationalStore.RdbStore | null = null

  /*
   * 初始化数据库
   * @param context 上下文对象
   * @param tableName 表格的名字
  */

  initPlayListDB(context: Context, tableName: string) {
    //(1)初始化数据库配置
    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: 'myMusic.db', // 数据库文件名
      securityLevel: relationalStore.SecurityLevel.S3, // 数据库安全级别
      // encrypt: false, // 可选参数，指定数据库是否加密，默认不加密
      // customDir: 'customDir/subCustomDir', // 可选参数，数据库自定义路径。数据库将在如下的目录结构中被创建：context.databaseDir + '/rdb/' + customDir，其中context.databaseDir是应用沙箱对应的路径，'/rdb/'表示创建的是关系型数据库，customDir表示自定义的路径。当此参数不填时，默认在本应用沙箱目录下创建RdbStore实例。
      // isReadOnly: false // 可选参数，指定数据库是否以只读方式打开。该参数默认为false，表示数据库可读可写。该参数为true时，只允许从数据库读取数据，不允许对数据库进行写操作，否则会返回错误码801。
    };
    //(2)定义sql语句
    const SQL_CREATE_TABLE = `CREATE TABLE IF NOT EXISTS ${tableName} (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    NAME TEXT NOT NULL,
    SONGS TEXT,
    PICURL TEXT,
    PLAYMODE INTEGER,
    PLAYCOUNT INTEGER,
    DESCRIPTION TEXT,
    TAGS TEXT,
    COMMENTCOUNT INTEGER,
    SHARECOUNT INTEGER,
    ARTIST TEXT,
    PUBLISHTIME INTEGER,
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

  /*
  * 添加数据
  * @param tableName  表名
  * @param value  要添加的数据，鸿蒙规定必须是relationalStore.ValuesBucket类型
  */
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
  /*
  * 查询数据
  * @param column 投影列
  * @param tableName  表名
  */
  async queryData(tableName: string, column?: Array<string>, id?: number): Promise<Array<PlayListModel>> {
    //获取要操作的表
    let predicates = new relationalStore.RdbPredicates(tableName);
    if (id) {
      //筛选条件，选中指定数据
      predicates.equalTo('ID', id);
    }
    //查询到的所有数据
    let playList: Array<PlayListModel> = []
    if (this.rdbStore !== null) {
      //查询数据库是异步的，并且得到一个结果集，我们要把返回的结果集处理成我们想要的数据
      let result = await this.rdbStore.query(predicates,column)
      //下面这段代码有个专业名词叫ORM，将对象和数据库进行相互的转换
      while (result.goToNextRow()) { //goToNextRow判断结果集是否有下一条数据
        let id = result.getLong(result.getColumnIndex('ID'))
        let name = result.getString(result.getColumnIndex('NAME'))
        let picUrl = result.getString(result.getColumnIndex('PICURL'))
        let songs = result.getString(result.getColumnIndex('SONGS'))
        let playMode = result.getLong(result.getColumnIndex('PLAYMODE'))
        let playCount = result.getLong(result.getColumnIndex('PLAYCOUNT'))
        let description = result.getString(result.getColumnIndex('DESCRIPTION'))
        let tags = result.getString(result.getColumnIndex('TAGS'))
        let commentCount = result.getLong(result.getColumnIndex('COMMENTCOUNT'))
        let shareCount = result.getLong(result.getColumnIndex('SHARECOUNT'))
        let artist = result.getString(result.getColumnIndex('ARTIST'))
        let publishTime = result.getLong(result.getColumnIndex('PUBLISHTIME'))
        let saveTime = result.getLong(result.getColumnIndex('SAVETIME'))
        const temp:PlayListModel = new PlayListModel()
        temp.id = id
        temp.name = name
        temp.picUrl = picUrl
        temp.playMode = playMode
        temp.playCount = playCount
        temp.description = description
        temp.tags = JSON.parse(tags)
        temp.commentCount = commentCount
        temp.shareCount = shareCount
        temp.artist = JSON.parse(artist)
        temp.publishTime = publishTime
        temp.songs = JSON.parse(songs)
        temp.saveTime = saveTime
        playList.push(temp)
      }
      //释放内存的结果集
      result.close()
      playList.sort((a,b)=>{
        return b.saveTime! - a.saveTime!
      })
      return playList
    }
    return []
  }

  /*
   * 更新数据
   * @param tableName  表名
   * @param id  要更新的数据id（（注意这里是数据库里数据的id--primary key，而不是goodsId）
   * @param 要更新的字段
  */
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

  /*
   * 删除数据
   * @param tableName  表名
   * @param id  要删除的id（注意这里是数据库里数据的id--primary key，而不是goodsId）
  */
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

//直接暴露实例出去，这样外面用的时候就不用new了
export const playListDB = new PlayListDBUtils()