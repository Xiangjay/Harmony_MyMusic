import log from '@open/log'
//把播放量等数字转换成xx.xx万的形式
export function countTransform(count:number,float=true):string{
  if(count.toString().length >=5){
    const a = count.toString().substring(0,count.toString().length-4)
    const b = count.toString().substring(count.toString().length-4,count.toString().length-2)
    const result:string = float? `${a}.${b}万` : `${a}万`
    return result
  }else {
    return count.toString()
  }
}

//转换歌曲时间
export function numberToTime(number: number) {
  // 毫秒 → 秒 → 分+秒; 先判断是否大于1分钟
  if (number > 60 * 1000) {
    const s = Math.floor(number/1000%60)
    const m = Math.floor(number/1000/60)
    const second = s.toString().padStart(2, '0')
    const minute = m.toString().padStart(2, '0')
    return minute + ':' + second
  } else {
    const s = Math.floor(number/1000%60)
    const second = s.toString().padStart(2, '0')
    return '00:' + second
  }
}

class Opt {
  yy:string = ''
  mm:string = ''
  dd:string = ''
  HH:string = ''
  MM:string = ''
  SS:string = ''
}

//转换日期格式
export function formatData(timestamp:number, format:string = 'yyyy-mm-dd'){
  let res:string = ''
  try {
    //  转化日期对象
    const date = new Date(timestamp)
    //  定义日期字段
    const opt:Opt = {
      yy:date.getFullYear().toString(),
      mm:date.getMonth().toString(),
      dd:date.getDate().toString(),
      HH:date.getHours().toString(),
      MM:date.getMinutes().toString(),
      SS:date.getSeconds().toString()
    }

    //  存放正则要匹配的字段
    const regKeys:string[] = ['y+', 'm+', 'd+', 'H+', 'M+', 'S+']
    for (let i = 0; i < regKeys.length; i++) {
      const regKey = regKeys[i];
      //  构造正则表达对象
      const reg = new RegExp(regKey)
      let ret = reg.exec(format)
      if(ret){
        switch (regKey){
          case 'y+':
            format = format.replace(reg, ret.length !== 1 ? opt.yy : opt.yy.padStart(ret.length, '0'))
          case 'm+':
            format = format.replace(reg, ret.length !== 1 ? opt.mm : opt.mm.padStart(2, '0'))
          case 'd+':
            format = format.replace(reg, ret.length !== 1 ? opt.dd : opt.dd.padStart(2, '0'))
          case 'H+':
            format = format.replace(reg, ret.length !== 1 ? opt.HH : opt.HH.padStart(2, '0'))
          case 'M+':
            format = format.replace(reg, ret.length !== 1 ? opt.MM : opt.MM.padStart(2, '0'))
          case 'S+':
            format = format.replace(reg, ret.length !== 1 ? opt.SS : opt.SS.padStart(2, '0'))
        }
      }
    }
    res = format
  } catch (error){
    console.log('ERROR formatDate')
  }
  return res
}

class A{
  id:number = 0
  name:string = 'aaa'
}
class B{
  id:number = 1
  name:string = 'bbb'
  gender:string = 'male'
}

//把请求返回的数据类型转换成程序需要的数据类型
export function myDataMerge<T>(target: Object, source: Object,specificKeys?:SpecificKey[]):T{
  for (const key of Object.keys(target)) {
    if(Reflect.has(source,key)){
      Reflect.set(target,key,Reflect.get(source, key))
    }
  }
  //用于数据转换的时候把source里的指定key的值赋值到target里特定的key
  if(specificKeys && specificKeys.length > 0){
    specificKeys.forEach((specific:SpecificKey)=>{
      if(Reflect.has(target,specific.specificKey) && Reflect.has(source,specific.sourceKey)){
        Reflect.set(target,specific.specificKey,Reflect.get(source, specific.sourceKey))
      }
    })
  }
  return target as T;
}
//用于数据转换的时候把source里的指定key的值赋值到target里特定的key
export interface SpecificKey{
  specificKey:string
  sourceKey:string
}
// export function myDataMergeV2<T>(target: Object, source: Object,specificKeys?:Specific[]):T{
//   for (const key of Object.keys(target)) {
//     const realKey = key.split('__ob_')[1]
//     if(Reflect.has(source,realKey)){
//       Reflect.set(target,key,Reflect.get(source, realKey))
//     }
//   }
//   //用于数据转换的时候把source里的指定key的值赋值到target里特定的key
//   if(specificKeys && specificKeys.length > 0){
//     specificKeys.forEach((specific:Specific)=>{
//       const realKey = specific.specificKey.split('__ob_')[1]
//       if(Reflect.has(target,specific.specificKey) && Reflect.has(source,realKey)){
//         Reflect.set(target,specific.specificKey,Reflect.get(source, realKey))
//       }
//     })
//   }
//   return target as T;
// }