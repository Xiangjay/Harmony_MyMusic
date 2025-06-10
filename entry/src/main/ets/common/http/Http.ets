import { http } from '@kit.NetworkKit'
import { BasicConstants } from '../constants/BasicConstants'

export function ajax<T, K>( //T代表返回的结果数据类型，K为请求参数的数据类型
  url: string,
  method: http.RequestMethod,
  requestData?: K
) {
  return new Promise((resolve: (value: Record<string,T>) => void, reject: (value?: string) => void) => {
    const httpRequest = http.createHttp()
    httpRequest.request(BasicConstants.BASE_URL + url, {
      method: method, //请求方式
      header: {
        //请求头，代表前端传递的时什么格式
        'Content-type': 'application/json'
      },
      extraData: JSON.stringify(requestData) || '', //发送给后端的数据，extraData只能接收字符串，所以这里要用JSON转一下
      connectTimeout: 5000
    }, (err: Error, data: http.HttpResponse) => {
      if (!err) {
        resolve(JSON.parse(data.result as string))
      } else {
        console.log('err',err.message)
        reject(err.message)
      }
    })
  })
}

export function myHttp<T, K>(url: string, method: string = 'get', requestData?: K): Promise<Record<string,T>> {
  switch (method.toLowerCase()) {
    case 'post':
      return ajax<T, K>(url, http.RequestMethod.POST, requestData)
      break;
    case 'put':
      return ajax<T, K>(url, http.RequestMethod.PUT, requestData)
      break;
    case 'delete':
      return ajax<T, K>(url, http.RequestMethod.DELETE, requestData)
      break;
    default:
      return ajax<T, K>(url, http.RequestMethod.GET, requestData)
      break;
  }
}