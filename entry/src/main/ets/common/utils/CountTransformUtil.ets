export default function countTransform(count:number):string{
  if(count.toString().length >=5){
    const a = count.toString().substring(0,count.toString().length-4)
    const b = count.toString().substring(count.toString().length-4,count.toString().length-2)
    return `${a}.${b}万`
  }else {
    return count.toString()
  }
}