import { photoAccessHelper } from "@kit.MediaLibraryKit";

/*
 * 从本地相册选择图片上传
*/
export async function PickFileUpload() {
  const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions() //打开系统图库
  photoSelectOptions.maxSelectNumber = 1 //限制最多选择几张图片
  photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE // 过滤选择媒体文件类型为IMAGE。

  //创建图库选择器实例，调用PhotoViewPicker.select接口拉起图库界面进行文件选择。文件选择成功后，返回PhotoSelectResult结果集
  const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
  let urls = await photoViewPicker.select(photoSelectOptions)
  if (urls.photoUris.length <= 0) {
    return
  }
  let imageUrl = urls.photoUris[0]
  return imageUrl
}
