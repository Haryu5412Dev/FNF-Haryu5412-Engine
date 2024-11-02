# FNF Haryu5412 Engine

[ Based Psych Engine 0.6.3 Git ]

---

## Haryu Engine Lua++

### **For Video Sprite Lua**

- ```lua 
  makeCutSenceVideo('videoName')
  ``` 
-- DEPRECATED!! OLD VideoSprite Make Code (but sometimes can be used...?)
- ```makeVideo('videoName', 'videoTag', 'camHUD');``` -- Play video to fill the screen. (autoplay)
- ```pauseVideo('videoTag');``` -- Pause video
- ```resumeVideo('videoTag');``` -- Resume paused video
- ```stopVideo('videoTag');``` -- Stop video (+ delete)
- ```tweenAlphaVideo("TweenTag", "videoTag", 0, 0.5, "linear");``` -- Video alpha tween
  - In order ( tween tag, start alpha, end alpha, tween type )
- ```setAlphaVideo('videoTag', 1.0);``` -- Sets Video Alpha

---

### **For Windows**

- ```changeWallpaper('funkay', false)``` -- Changes Windows Wallpaper (if absolute is false: [path: mods/images])
  - In Order ( pngPath(String), absolute(Bool) )

---