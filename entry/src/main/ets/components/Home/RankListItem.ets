import { getPlayListSongsById, getSongUrlByIds } from "../../common/apis/MusicApis"
import { BasicConstants } from "../../common/constants/BasicConstants"
import { myDataMerge, SpecificKey } from "../../common/utils/CommonTools"
import { PlayListModel, SongModel } from "../../models/DataModels"

@Component
export struct RankListItem {
  @ObjectLink rank:PlayListModel
  @Link rankLoading:boolean
  handleRank = async () => {
    const resSongs = await getPlayListSongsById<Array<SongModel>, null>(this.rank.id)
    const specificKeys:SpecificKey[] = [
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
    await this.handleSongs(resSongs.songs.slice(0,3),specificKeys)
  }
  handleSongs = async (resSongs:Array<SongModel>,specificKeys:SpecificKey[])=>{
    //所有歌曲ID
    const songIds:number[] = []
    //处理下拿到的歌曲的数据格式
    this.rank.songs = []  //这里需要让歌单里的歌曲变化地址，不然监测不到变化页面不会重新渲染，如果弹窗的list是子组件，那应该可以用@Observed和@ObjectLink
    resSongs.forEach((item: SongModel) => {
      this.rank.songs.push(myDataMerge<SongModel>(new SongModel(),item,specificKeys))
      //保存所有歌曲ID，用于后续获取歌曲URL
      songIds.push(item.id)
    })
    //处理歌曲图片和歌手名字
    this.rank.songs.forEach((song:SongModel)=>{
      song.picUrl = song.album.picUrl || this.rank.picUrl
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
      this.rank.songs.forEach((song:SongModel)=>{
        if(item.id === song.id){
          song.url = item.url
        }
      })
    })
    this.rankLoading = false
  }
  aboutToAppear(): void {
    this.handleRank()
  }
  build() {
    Column(){
      ForEach(this.rank.songs,(song:SongModel,index:number)=>{
        Row({space:5}){
          Text(`${index + 1}.`)
            .fontColor($r('app.color.text_default'))
            .fontSize(BasicConstants.FONT_SIZE_SMALL)
          Text(`${song.name} - ${song.artistName}`)
            .fontColor($r('app.color.text_default'))
            .fontSize(BasicConstants.FONT_SIZE_SMALL)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({overflow:TextOverflow.Ellipsis})
        }
      })
    }
    .padding({
      top:10,
      bottom:10
    })
    .height(BasicConstants.FULL_HEIGHT)
    .justifyContent(FlexAlign.SpaceBetween)
    .layoutWeight(1)
  }
}