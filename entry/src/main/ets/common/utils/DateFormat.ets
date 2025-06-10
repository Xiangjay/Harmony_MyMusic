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

export class Opt {
  yy:string = ''
  mm:string = ''
  dd:string = ''
  HH:string = ''
  MM:string = ''
  SS:string = ''
}

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