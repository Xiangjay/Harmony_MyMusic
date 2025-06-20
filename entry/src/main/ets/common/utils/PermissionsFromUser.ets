import { abilityAccessCtrl, common, PermissionRequestResult, Permissions } from "@kit.AbilityKit";
import { BusinessError } from "@kit.BasicServicesKit";

//获取用户权限
export async function reqPermissionsFromUser(permissions: Array<Permissions>,
  context: common.UIAbilityContext): Promise<number> {
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
  //自己封装promise，这样页面可以拿到结果
  return new Promise((resolve: (value: number) => void, reject: () => void) => {
    atManager.requestPermissionsFromUser(context, permissions).then((data:PermissionRequestResult) => {
      let grantStatus: Array<number> = data.authResults;
      let length: number = grantStatus.length;
      for (let i = 0; i < length; i++) {
        if (grantStatus[i] === 0) {
          // 用户授权，可以继续访问目标操作
          console.log('用户授权，可以继续访问目标操作')
          resolve(1)
        } else {
          // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
          console.log('用户拒绝授权')
          resolve(0)
          return
        }
      }
      // 授权成功
    }).catch((err: BusinessError) => {
      console.log(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`)
      resolve(-1)
    })
  })

}