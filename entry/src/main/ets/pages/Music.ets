import { LengthMetrics, PromptAction, router } from "@kit.ArkUI";
import { BasicConstants } from '../common/constants/BasicConstants'
import {
  getSongListSongsById,
  getSongUrlByIds,
  getSongListDetailById,
  getAlbumDetailById,
  getAlbumDynamicById
} from '../common/apis/MusicApis'
import { Empty } from "../components/common/Empty";
import { countTransform, formatData, myDataMerge, SpecificKey} from "../common/utils/CommonTools";
import {routerParams,PlayListModel,SongModel,musicRouterParamsModel,playListType, commentsRouterParamsModel, Artist,} from '../models/DataModels'
import { Loading } from "../components/common/Loading";
import { TopNavBar } from "../components/common/TopNavBar";
import { MyLazyDataSource } from "../common/utils/MyLazyDataSource";
import log from "@open/log";
import {playListDB} from '../db/playListDB'
import { relationalStore } from "@kit.ArkData";
import { PlayListItem } from "../components/common/PlayListItem";
import { SongListItem } from "../components/common/SongListItem";

@Extend(Text) function coverText(fontSize:number = BasicConstants.FONT_SIZE_NORMAL) {
  .fontSize(fontSize)
  .fontColor(Color.White)
  .width(BasicConstants.FULL_WIDTH)
  .maxLines(2)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

//歌单、专辑详情页面
@Entry
@Component
struct Music {
  @StorageProp('safeTop') safeTop: number = 0;
  @State routerParams:musicRouterParamsModel = new musicRouterParamsModel()
  @State playList: PlayListModel= new PlayListModel() //程序需要的数据类型
  @State playListType:playListType = playListType.playList  //歌单或者专辑
  @State isLoading: boolean = true
  @State noList: boolean = false
  @State localPlayLists:Array<PlayListModel> = [] //用于没有点击歌单而是直接点击音乐进入此页面时
  @State showLocalPlayLists:boolean = false
  //播放列表弹窗用
  @State songListHeight: string = '0%'
  @State songListOpacity: number = 0
  private animationDuration:number = 300
  @StorageLink('currentSong') currentSong: SongModel = new SongModel()  //当前正在播放的歌曲
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();  //提示弹窗
  //懒加载数据
  private musicLazyData:MyLazyDataSource<SongModel> = new MyLazyDataSource()

  //通过传过来的歌单ID获取歌单详细
  getPlayListDetail = async (id:number) => {
    //获取歌单详细信息
    const resPlayList = await getSongListDetailById<PlayListModel, null>(id)
    let specificKeys:SpecificKey[] = [
      {
        specificKey:'picUrl',
        sourceKey:'coverImgUrl'
      }
    ]
    this.playList = myDataMerge<PlayListModel>(new PlayListModel(),resPlayList.playlist,specificKeys)
    //获取歌单里所有歌曲，这里只能拿到歌曲的ID、名字、作者、专辑
    const resSongs = await getSongListSongsById<Array<SongModel>, null>(id)
    //用于数据转换的时候把source里的指定key的值赋值到target里特定的key
    specificKeys = [
      {
        specificKey:'artists',
        sourceKey:'ar'
      },
      {
        specificKey:'album',
        sourceKey:'al'
      },
      {
        specificKey:'duration',
        sourceKey:'dt'
      }
    ]
    await this.handleSongs(resSongs.songs,specificKeys)
  }
  //通过传过来的专辑ID获取专辑详细
  getAlbumDetail = async (id:number) => {
    //先拿专辑基本信息
    const resAlbum = await getAlbumDetailById<PlayListModel,null>(id)
    this.playList = myDataMerge<PlayListModel>(new PlayListModel(),resAlbum.album)
    this.playList.artist = myDataMerge<Artist>(new Artist(),resAlbum.album.artist!)
    //处理下格式，不然页面渲染不出来
    if(this.playList.description.indexOf('\n') > -1){
      this.playList.description = this.playList.description.replaceAll('\n','')
    }
    //获取专辑动态信息（评论数，分享数）
    const resDynamic = await getAlbumDynamicById<PlayListModel,null>(id)
    this.playList = myDataMerge<PlayListModel>(this.playList,resDynamic)
    //再拿专辑里的歌曲
    const resSongs = await getAlbumDetailById<Array<SongModel>,null>(id)
    const specificKeys:SpecificKey[] = [
      {
        specificKey:'artists',
        sourceKey:'ar'
      },
      {
        specificKey:'duration',
        sourceKey:'dt'
      }
    ]
    await this.handleSongs(resSongs.songs,specificKeys)
  }
  //通过传过来的歌单ID从本地数据库里获取详情
  getLocalPlayListDetail = async (id:number) => {
    const res = await playListDB.queryData('PLAYLIST',undefined,id)
    this.playList = res[0]
    const songIds:number[] = []
    this.playList.songs.forEach((song:SongModel)=>{
      songIds.push(song.id)
    })
    //数据库里的播放地址有时效性，所以这里要重新获取
    const responseSongUrls = await getSongUrlByIds<Array<SongModel>, null>(songIds)
    //把拿到的歌曲url赋值到对应的歌曲里，这里其实可以一个循环this.playList.songs[index].url = item.url就行，但是为了以防万一顺序错乱，还是严谨点用两个循环判断下ID
    responseSongUrls.data.forEach(item=>{
      this.playList.songs.forEach((song:SongModel)=>{
        if(item.id === song.id){
          song.url = item.url
        }
      })
    })
    //把数据放入懒加载数据类型中
    this.musicLazyData.pushAllData(this.playList.songs)
    this.isLoading = false
    this.songListHeight = '70%'
    this.songListOpacity = 1
  }
  //处理歌曲列表
  handleSongs = async (resSongs:Array<SongModel>,specificKeys:SpecificKey[])=>{
    //所有歌曲ID
    const songIds:number[] = []
    //处理下拿到的歌曲的数据格式
    this.playList.songs = []  //这里需要让歌单里的歌曲变化地址，不然监测不到变化页面不会重新渲染，如果弹窗的list是子组件，那应该可以用@Observed和@ObjectLink
    resSongs.forEach((item: SongModel) => {
      this.playList.songs.push(myDataMerge<SongModel>(new SongModel(),item,specificKeys))
      //保存所有歌曲ID，用于后续获取歌曲URL
      songIds.push(item.id)
    })
    //处理歌曲图片和歌手名字
    this.playList.songs.forEach((song:SongModel)=>{
      song.showPic = song.album.picUrl || this.playList.picUrl
      if(this.playListType === playListType.album){
        song.album.id = this.playList.id
        song.album.name = this.playList.name
        song.album.picUrl = this.playList.picUrl
      }
      if(song.artists.length > 1){
        song.artists.forEach(item=>{
          song.artistName.push(item.name)
        })
      }else{
        song.artistName.push(song.artists[0].name)
      }
    })
    //通过歌曲ID获取歌曲播放URL
    const responseSongUrls = await getSongUrlByIds<Array<SongModel>, null>(songIds)
    //把拿到的歌曲url赋值到对应的歌曲里，这里其实可以一个循环this.playList.songs[index].url = item.url就行，但是为了以防万一顺序错乱，还是严谨点用两个循环判断下ID
    responseSongUrls.data.forEach(item=>{
      this.playList.songs.forEach((song:SongModel)=>{
        if(item.id === song.id){
          song.url = item.url
        }
      })
    })
    //把数据放入懒加载数据类型中
    this.musicLazyData.pushAllData(this.playList.songs)
    this.isLoading = false
    this.songListHeight = '65%'
    this.songListOpacity = 1
  }
  addPlayList2ToLocal = async ()=>{
    //看看是否有重复歌单
    const res = await playListDB.queryData('PLAYLIST', undefined, this.playList.id)
    if(res.length === 0){
      const valueBucket: relationalStore.ValuesBucket = {
        ID:this.playList.id,
        NAME: this.playList.name,
        PICURL: this.playList.picUrl,
        SONGS:JSON.stringify(this.playList.songs),
        PLAYMODE:this.playList.playMode,
        PLAYCOUNT:this.playList.playCount,
        DESCRIPTION:this.playList.description,
        TAGS:JSON.stringify(this.playList.tags),
        COMMENTCOUNT:this.playList.commentCount,
        SHARECOUNT:this.playList.shareCount,
        ARTIST:JSON.stringify(this.playList.artist),
        PUBLISHTIME: 0,
        SAVETIME:new Date().getTime()
      };
      const res = await playListDB.insertData('PLAYLIST',valueBucket)
      switch (res.code) {
        case 1:
          this.promptAction.showToast({
            message: '歌单保存失败，请稍后重试',
            duration: BasicConstants.TOAST_DURATION,
          })
          break;
        case -1:
          this.promptAction.showToast({
            message: '程序异常，请稍后重试',
            duration: BasicConstants.TOAST_DURATION,
            textColor: Color.Red
          })
          break;
        default:
          this.promptAction.showToast({
            message: '歌单保存成功，可前往个人中心查看',
            duration: BasicConstants.TOAST_DURATION
          })
          break;
      }
    }else {
      this.promptAction.showToast({
        message: '该歌单已存在',
        duration: BasicConstants.TOAST_DURATION
      })
    }
  }
  addSong2Local = async (song:SongModel)=>{
    //获取所有本地列表
    const myPlayLists = await playListDB.queryData('PLAYLIST')
    if(myPlayLists.length === 0){ //没有本地歌单，那么就弹窗提示
      this.getUIContext().showAlertDialog({
        title: '暂无本地歌单',
        message: '请先添加歌单/专辑到本地歌单，或者在个人中心新建歌单',
        autoCancel: true,
        primaryButton: {
          value: '取消',
          fontColor:$r('app.color.text_light'),
          action: () => {}
        },
        secondaryButton: {
          value: '去个人中心',
          fontColor:$r('app.color.edit'),
          action: () => {
            router.pushUrl({
              url:'pages/My'
            })
          }
        }
      })
      return
    }
    const playListNames:string[] = []
    myPlayLists.forEach(item=>{
      playListNames.push(item.name)
    })
    //选择本地歌单弹窗
    this.getUIContext().showTextPickerDialog({
      range: playListNames,
      selected: 0,
      canLoop: false,
      cancelButtonStyle:{fontColor:$r('app.color.disabled')},
      onAccept: async (value: TextPickerResult) => {
        const index = value.index as number //选择的索引
        //取出当前选择的歌单
        const resPlayList = await playListDB.queryData('PLAYLIST', undefined, myPlayLists[index].id)
        let selectedPlayList = resPlayList[0]
        //看看选择的歌单中是否已经有该歌曲
        const duplicated = selectedPlayList.songs.some(item=>item.id === song.id)
        if(duplicated){
          this.promptAction.showToast({
            message: '该歌单已有此歌曲',
            duration: BasicConstants.TOAST_DURATION
          })
          return
        }
        selectedPlayList.songs.unshift(song)  //把这首歌加进去
        const valueBucket: relationalStore.ValuesBucket = {
          SONGS:JSON.stringify(selectedPlayList.songs),
          SAVETIME: new Date().getTime()
        };
        const res = await playListDB.updateDataById('PLAYLIST',myPlayLists[index].id,valueBucket) //更新到数据库
        if(res.code === 0){ //成功
          this.promptAction.showToast({
            message: res.message,
            duration: BasicConstants.TOAST_DURATION
          })
        }else { //失败
          this.promptAction.showToast({
            message: res.message,
            duration: BasicConstants.TOAST_DURATION
          })
        }
      }
    });
  }
  goToComments = () =>{
    if (this.playList.commentCount != 0) {
      const param:commentsRouterParamsModel = {
        id:this.playList.id,
        type: this.playListType,
        detail:this.playList
      }
      router.pushUrl({
        url:'pages/Comments',
        params: {
          param: param
        }
      })
    }else {
      this.promptAction.showToast({
        message: '暂无评论',
        duration: 1000
      })
    }
  }

  //当点击音乐进入此页面时，从本地数据库里取本地歌单列表
  getLocalPlayLists = async ()=>{
    const res = await playListDB.queryData('PLAYLIST')
    if(res.length != 0){
      this.localPlayLists = res
      this.showLocalPlayLists = true
    }else {
      this.noList = true
    }
  }
  aboutToAppear(): void {
    try {
      this.routerParams = (router.getParams() as routerParams<musicRouterParamsModel>).param
      this.playListType = this.routerParams.type
      if(this.playListType === playListType.playList){
        this.getPlayListDetail(this.routerParams.id)
      }else if(this.playListType === playListType.album){
        this.getAlbumDetail(this.routerParams.id)
      }else {
        this.getLocalPlayListDetail(this.routerParams.id)
      }
    } catch {
      this.getLocalPlayLists()
    }
  }

  @Builder coverBuilder() {
    Row({space:10}) {
      Column() {
        Image(this.playList.picUrl)
          .borderRadius(5)
          .width(BasicConstants.FULL_WIDTH)
          .height(120)
      }
      .width(120)
      Column() {
        Text(this.playList.name)
          .coverText(BasicConstants.FONT_SIZE_LARGE)
        Text(this.playListType === playListType.album ? formatData(this.playList.publishTime) + ' 发行' : this.playList.tags!.toString())
          .coverText(BasicConstants.FONT_SIZE_SMALL)
          .opacity(0.6)
        Text(this.playList.description)
          .coverText()
          .opacity(0.8)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .layoutWeight(1)
      .height(120)
    }
    .alignItems(VerticalAlign.Top)
    .width(BasicConstants.FULL_WIDTH)
  }
  @Styles coverButtons(){
    .width('30%')
    .backgroundColor('#32ffffff')
    .padding({
      top:10,
      bottom:10,
      left:20,
      right:20
    })
  }
  @Builder coverButtonsBuilder() {
    Row({space:30}){
      Button(){
        Row(){
          Image($r('app.media.icon_share'))
            .width(20)
          Text(this.playList.shareCount != 0 ? countTransform(this.playList.shareCount,false) : '分享')
            .fontColor('#ffffff')
            .margin({left:5})
        }
        .justifyContent(FlexAlign.Center)
      }
      .coverButtons()
      Button(){
        Row(){
          Image($r('app.media.icon_comment'))
            .width(20)
          Text(this.playList.commentCount != 0 ? countTransform(this.playList.commentCount,false) : '评论')
            .fontColor('#ffffff')
            .margin({left:5})
        }
        .justifyContent(FlexAlign.Center)
      }
      .coverButtons()
      .onClick(()=>{
        this.goToComments()
      })
    }
    .margin({top:10})
    .width(BasicConstants.FULL_WIDTH)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }
  @Builder songListBuilder(){
    Column(){
      //列表头
      Row({space:5}){
        Image($r("app.media.icon_play"))
          .width(25)
          .fillColor($r('app.color.icon_svg_selected'))
        Row() {
          Text(){
            Span('播放列表 ')
              .fontColor($r('app.color.text_default'))
              .fontSize(BasicConstants.FONT_SIZE_NORMAL)
            Span(`(${this.playList?.songs?.length})`)
              .fontColor($r('app.color.text_light'))
              .fontSize(BasicConstants.FONT_SIZE_SMALL)
          }
        }
        .layoutWeight(1)
        if(this.playListType !== playListType.local){
          Image($r("app.media.icon_add_track"))
            .fillColor($r('app.color.icon_svg_selected'))
            .width(25)
            .height(25)
            .onClick(()=>{
              this.addPlayList2ToLocal()
            })
        }
      }
      .width(BasicConstants.FULL_WIDTH)
      .height(60)
      .alignItems(VerticalAlign.Center)
      .border({
        width: { bottom: 1 },
        color:$r('app.color.list_divider')
      })
      .padding({
        left:10,
        right:10
      })
      // 播放列表
      List() {
        LazyForEach(this.musicLazyData, (item: SongModel, index: number) => {
          ListItem() {
            SongListItem({song:item,currentSongId:this.currentSong.id,index:index,playList:this.playList,addSong2Local:this.addSong2Local})
            // Row({space:10}) {
            //   Row(){
            //     if(item.id === this.currentSong?.id){
            //       Image($r('app.media.icon_playing'))
            //         .width(20)
            //         .fillColor($r('app.color.icon_svg_selected'))
            //     }else{
            //       Text((index + 1).toString())
            //         .fontColor($r('app.color.text_light'))
            //     }
            //   }
            //   .width(30)
            //   Row() {
            //     Column({ space: 5 }) {
            //       Text(item.name)
            //         .fontSize(BasicConstants.FONT_SIZE_NORMAL)
            //         .fontColor(item.id === this.currentSong?.id ? $r('app.color.icon_svg_selected') : $r('app.color.text_default'))
            //         .maxLines(1)
            //         .textOverflow({overflow:TextOverflow.Ellipsis})
            //       Text(item.artistName.toString())
            //         .fontSize(BasicConstants.FONT_SIZE_SMALL)
            //         .fontColor(item.id === this.currentSong?.id ? $r('app.color.icon_svg_selected') : $r('app.color.text_light'))
            //         .maxLines(1)
            //         .textOverflow({overflow:TextOverflow.Ellipsis})
            //     }
            //     .alignItems(HorizontalAlign.Start)
            //     .justifyContent(FlexAlign.Center)
            //   }
            //   .layoutWeight(1)
            //   .onClick(()=>{
            //     //跳转播放时把当前播放列表存到全局
            //     AppStorage.setOrCreate('currentPlayList',this.playList)
            //     router.pushUrl({
            //       url:'pages/Play',
            //       params:{
            //         param:item
            //       }
            //     })
            //   })
            //   if(this.playListType !== playListType.local){
            //     Row(){
            //       Image($r('app.media.icon_add'))
            //         .width(20)
            //         .height(20)
            //         .fillColor($r('app.color.icon_svg_selected'))
            //         .onClick(()=>{
            //           this.addSong2Local(item)
            //         })
            //     }
            //   }
            // }
            // .padding({
            //   left:10,
            //   right:10
            // })
            // .height(60)
            // .width(BasicConstants.FULL_WIDTH)
            // .alignItems(VerticalAlign.Center)
          }
          .border({
            width: { bottom: 1 },
            color:$r('app.color.list_divider')
          })
        },(item:SongModel)=>item.id.toString())
      }
      .edgeEffect(EdgeEffect.Spring)
      .fadingEdge(true)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .height(this.songListHeight)
    .opacity(this.songListOpacity)
    .animation({
      duration:this.animationDuration,
    })
    .width(BasicConstants.FULL_WIDTH)
    .backgroundColor($r('app.color.main_tab_background'))
    .padding({
      left:10,
      right:10
    })
  }
  @Builder localPlayListsBuilder(){
    Column({space:10}){
      List({space:10}){
        ForEach(this.localPlayLists,(item:PlayListModel)=>{
          PlayListItem({playList:item,onSelectPlayList:this.onSelectPlayList})
        },(item:PlayListModel)=>item.id.toString())
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .fadingEdge(true)
      .width(BasicConstants.FULL_WIDTH)
    }
    .padding({
      left:10,
      right:10,
      bottom:20
    })
  }
  onSelectPlayList = (id:number)=>{
    this.playListType = playListType.local
    this.getLocalPlayListDetail(id)
    this.showLocalPlayLists = false
  }
  build() {
    if (!this.noList) {
      Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: this.isLoading ? Alignment.Center : Alignment.Top }) {
          Image(this.playList?.picUrl)
            .width(BasicConstants.FULL_WIDTH)
            .height(BasicConstants.FULL_HEIGHT)
            .blur(1000)
          if (this.isLoading) {
            Loading()
          } else {
            Column({ space: 10 }) {
              //后退按钮
              TopNavBar({title:'音乐',color:'#ffffff'})
              //封面
              this.coverBuilder()
              //按钮
              if(this.playListType !== playListType.local){
                this.coverButtonsBuilder()
              }
            }
            .padding({
              top:this.safeTop,
              left: 10,
              right: 10
            })
            .width(BasicConstants.FULL_WIDTH)
            .height('40%')
          }
        }
        //歌单里歌曲列表
        this.songListBuilder()
      }
      .height(BasicConstants.FULL_HEIGHT)
      .width(BasicConstants.FULL_WIDTH)
      .bindSheet($$this.showLocalPlayLists, this.localPlayListsBuilder(), {
        title:{title:'我的歌单'},
        height:'100%',
        showClose:false,
        radius:{topStart:LengthMetrics.vp(10),topEnd:LengthMetrics.vp(10)}
      })
    } else {
      Column(){
        Empty({ message: '暂无可播放歌单' })
      }
      .height(BasicConstants.FULL_HEIGHT)
      .width(BasicConstants.FULL_WIDTH)
      .backgroundColor($r('app.color.content_background'))
      .padding({
        top: this.safeTop
      })
    }
  }
}