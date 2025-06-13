@Entry
@Component
struct PlayMV {
  private controller: VideoController = new VideoController()

  build() {
    Column() {
      Video({
        src: 'http://vodkgeyttp8.vod.126.net/cloudmusic/MjQ3NDQ3MjUw/89a6a279dc2acfcd068b45ce72b1f560/533e4183a709699d566180ed0cd9abe9.mp4?wsSecret=f8826239faf247408b689934cb4577f0&wsTime=1749808473',
        previewUri: 'http://p1.music.126.net/ijUg7s_2S8GMbTNsYiepJA==/18676304511774727.jpg',
        controller: this.controller
      })
    }
  }
}