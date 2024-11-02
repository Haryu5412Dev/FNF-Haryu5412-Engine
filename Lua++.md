## Haryu Engine Lua++

1. For Video Sprite Lua

* ```makeVideo('videoName', 'camHUD');``` -- Play video to fill the screen. (autoplay)
* ```pauseVideo('videoName');``` -- Pause video
* ```resumeVideo('videoName');``` -- Resume paused video
* ```stopVideo('videoName');``` -- Stop video (+ delete)
* ```tweenAlphaVideo("Tween", 0, 0.5, "linear");``` -- Video alpha tween
  * In order ( tween tag, start alpha, end alpha, tween type )