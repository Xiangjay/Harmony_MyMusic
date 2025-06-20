import log from "@open/log"
import { BasicConstants } from "../common/constants/BasicConstants"
import { playListDB } from "../db/playListDB"
import { Artist, PlayListModel, routerParams, SongModel } from "../models/DataModels"
import { PickFileUpload } from "../common/utils/FileUpload"
import { TagSelection } from "../components/My/TagSelection"
import { PromptAction, router } from "@kit.ArkUI"
import { relationalStore } from "@kit.ArkData"
import { BusinessError } from "@kit.BasicServicesKit"

interface Tag{
  name:string
  checked:boolean
}

@Entry
@Component
struct CreateNewPlayList {
  @StorageProp('safeTop') safeTop: number = 0;
  @State title:string = '新建歌单'
  @State dataChanged:boolean = false  //检查用户更改页面数据没有，用于保存按钮的enable
  @State type:string = ''
  @State picUrl:string = ''
  @State name:string = ''
  @State description:string = ''
  @State selectedTags:string[] = []
  @State songs:Array<SongModel> = []
  @State playList:PlayListModel = new PlayListModel()
  @State sourceTags:string[] = ['华语','欧美','日韩','粤语','流行','经典','怀旧','影视原声','说唱','摇滚']  //自定义可选择标签
  @State tags:Tag[] = []
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();  //提示弹窗

  selectCoverImg = async ()=>{
    const res = await PickFileUpload()  //获取刚才选择的图片
    if(res){
      this.picUrl = res
      this.dataChanged = true
    }
  }
  selectTags = (tag:Tag)=>{
    this.dataChanged = true
    if(tag.checked){
      this.selectedTags.push(tag.name)
    }else {
      const index = this.selectedTags.findIndex(item=>item === tag.name)
      this.selectedTags.splice(index,1)
    }
  }
  onSave = async ()=>{
    if(this.type === 'new'){
      const valueBucket: relationalStore.ValuesBucket = {
        NAME: this.name,
        PICURL: this.picUrl,
        SONGS:JSON.stringify(this.songs),
        PLAYMODE:0,
        PLAYCOUNT:0,
        DESCRIPTION:this.description,
        TAGS:JSON.stringify(this.selectedTags),
        COMMENTCOUNT:0,
        SHARECOUNT:0,
        ARTIST:JSON.stringify(new Artist()),
        PUBLISHTIME:0,
        SAVETIME:new Date().getTime()
      };
      const res = await playListDB.insertData('PLAYLIST',valueBucket)
      switch (res.code) {
        case 1:
          this.promptAction.showToast({
            message: '创建歌单失败，请稍后重试',
            duration: BasicConstants.TOASTDURATION,
          })
          break;
        case -1:
          this.promptAction.showToast({
            message: '程序异常，请稍后重试',
            duration: BasicConstants.TOASTDURATION,
            textColor: Color.Red
          })
          break;
        default:
          this.promptAction.showToast({
            message: '创建歌单成功',
            duration: BasicConstants.TOASTDURATION
          })
          setTimeout(()=>{
            router.back()
          },BasicConstants.TOASTDURATION)
          break;
      }
    }else {
      const valueBucket: relationalStore.ValuesBucket = {
        NAME: this.name,
        PICURL: this.picUrl,
        SONGS:JSON.stringify(this.songs),
        DESCRIPTION:this.description,
        TAGS:JSON.stringify(this.selectedTags),
        SAVETIME:new Date().getTime()
      };
      const res = await playListDB.updateDataById('PLAYLIST',this.playList.id,valueBucket)
      if(res.code === 0){ //成功
        this.promptAction.showToast({
          message: '更新歌单成功',
          duration: BasicConstants.TOASTDURATION
        })
        setTimeout(()=>{
          router.back()
        },BasicConstants.TOASTDURATION)
      }else { //失败
        this.promptAction.showToast({
          message: '更新歌单失败',
          duration: BasicConstants.TOASTDURATION
        })
      }
    }
  }
  onBack = () =>{
    if (!this.dataChanged){
      router.back()
    }else{
      this.getUIContext().showAlertDialog({
        title: '数据尚未保存，确定要返回上一页吗？',
        message:'',
        autoCancel:false,
        buttons: [{
          fontColor:$r('app.color.disabled'),
          value: '取消',
          action: () => {
          }
        },
          {
            fontColor:$r('app.color.warning'),
            value: '确定',
            action: () => {
              router.back()
            }
          }],
      })
    }
  }

  aboutToAppear(): void {
    this.type = router.getParams() ? 'edit' : 'new'
    this.sourceTags.forEach(item=>{
      this.tags.push({name:item,checked:false})
    })
    if(this.type === 'edit'){
      this.title = '编辑歌单'
      this.playList = (router.getParams() as routerParams<PlayListModel>).param
      //初始化数据
      this.picUrl = this.playList.picUrl
      this.name = this.playList.name
      this.description = this.playList.description
      this.selectedTags = this.playList.tags || []
      this.songs = this.playList.songs || []
      //处理下歌单标签
      if(this.playList.tags.length > 0){
        const newTags:Tag[] = []
        this.playList.tags.forEach(tag=>{
          this.tags.forEach(item=>{
            if(item.name === tag){
              item.checked = true
            }
          })
          if(!this.tags.some(item=>item.name === tag)){
            newTags.push({
              name:tag,
              checked:true
            })
          }
        })
        this.tags = [...this.tags,...newTags]
      }
    }
  }
  @Builder topBuilder(){
    Row(){
      Row({space:5}) {
        Image($r('app.media.icon_back'))
          .width(30)
          .height(30)
          .fillColor($r('app.color.back_icon'))
          .onClick(()=>{
            this.onBack()
          })
        Text(this.title)
          .fontColor($r('app.color.back_icon'))
          .fontSize(BasicConstants.FONT_SIZE_LARGE)
          .fontWeight(FontWeight.Bold)
      }
      Button('保存')
        .width(100)
        .fontColor($r('app.color.edit'))
        .fontWeight(FontWeight.Bold)
        .fontSize(BasicConstants.FONT_SIZE_NORMAL)
        .backgroundColor(Color.Transparent)
        .borderWidth(2)
        .borderColor($r('app.color.edit'))
        .enabled(this.name !== '' && this.picUrl !== '' && this.dataChanged)
        .onClick(this.onSave)
    }
    .width(BasicConstants.FULL_WIDTH)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }
  @Builder songListBuilder(){
    List(){
      ForEach(this.songs,(song:SongModel,index:number)=>{
        ListItem() {
          Row({space:10}) {
            Text((index + 1).toString())
              .fontColor($r('app.color.text_light'))
              .width(30)
            Column({ space: 5 }) {
              Text(song.name)
                .fontSize(BasicConstants.FONT_SIZE_NORMAL)
                .fontColor($r('app.color.text_default'))
                .maxLines(1)
                .textOverflow({overflow:TextOverflow.Ellipsis})
              Text(song.artistName.toString())
                .fontSize(BasicConstants.FONT_SIZE_SMALL)
                .fontColor($r('app.color.text_light'))
                .maxLines(1)
                .textOverflow({overflow:TextOverflow.Ellipsis})
            }
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Center)
            .layoutWeight(1)
            Image($r('app.media.icon_delete'))
              .width(20)
              .height(20)
              .fillColor($r('app.color.delete'))
              .onClick(()=>{
                this.songs.splice(index,1)
                this.dataChanged = true
              })
          }
          .height(60)
          .width(BasicConstants.FULL_WIDTH)
          .alignItems(VerticalAlign.Center)
        }
        .border({
          width: { bottom: 1 },
          color:$r('app.color.list_divider')
        })
      },(song:SongModel)=>song.id.toString())
    }
    .margin({
      left:10,
      right:10
    })
    .edgeEffect(EdgeEffect.Spring)
    .fadingEdge(true)
    .scrollBar(BarState.Off)
    .layoutWeight(1)
  }

  build() {
    Column({space:20}){
      this.topBuilder()
      Column({space:10}){
        //歌单封面
        Image(this.picUrl || $r('app.media.default_coverImg'))
          .width(100)
          .height(120)
          .onClick(this.selectCoverImg)
        //歌单名称
        TextInput({text:$$this.name,placeholder:this.playList.name || '歌单名称 *'})
          .maxLength(20)
          .onWillInsert((info: InsertValue) => {
            // 在将要输入时调用的回调。在返回true时，表示正常插入，返回false时，表示不插入。
            if (info.insertValue.startsWith(' ')) {
              return false
            } else {
              this.dataChanged = true
              return true
            }
          })
        //歌单描述
        TextArea({text:$$this.playList,placeholder:this.playList.description || '歌单描述' })
          .width(BasicConstants.FULL_WIDTH)
          .height(100)
          .onChange(()=>{
            this.dataChanged = true
          })
        //歌单标签
        Grid() {
          ForEach(this.tags, (item: Tag) => {
            //这里要用子组件，不然页面UI检查不到变化
            TagSelection({tag:item,selectTags:this.selectTags})
          }, (item: Tag) => item.name)
        }
        .columnsGap(10)
        .rowsGap(10)
        .maxCount(6)
        .minCount(2)
        .cellLength(0)
        .layoutDirection(GridDirection.Row)
        //歌曲列表
        this.songListBuilder()
      }
      .width(BasicConstants.FULL_WIDTH)
      .height(BasicConstants.FULL_HEIGHT)
      .layoutWeight(1)
    }
    .height(BasicConstants.FULL_HEIGHT)
    .width(BasicConstants.FULL_WIDTH)
    .backgroundColor($r('app.color.content_background'))
    .padding({
      top: this.safeTop,
      left:10,
      right:10,
    })
  }
}