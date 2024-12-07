# FNF Haryu5412's Modding Engine

[ Based Psych Engine 0.6.3 Git ]

---

## Haryu Engine Lua++

### **For Video Sprite Lua**

-- **You can precache video using this :**
   ```lua
   precacheVideo("videoName")
   ```

  **-- DEPRECATED!! OLD VideoSprite Make Code (but sometimes can be used...?)**

- ```lua
  makeCutSenceVideo('videoName')
  ```

  **-- Play video to fill the screen. (autoplay)**

- ```lua
  makeVideo('videoName', 'videoTag', 'camHUD', 5) -- Added Type!! Read resolution types
  ```

  **-- Sets Position Video**  

- ```lua
  setPositionVideo('videoTag', 0, 0)
  ```

  **-- Sets Scale Video**

  ```lua
  scaleVideo('videoTag', 1.0, 1.0)
  ```

  **-- Pause video**  

- ```lua
  pauseVideo('videoTag')
  ```

  **-- Resume paused video**

- ```lua
  resumeVideo('videoTag')
  ```

  **-- Stop video (+ delete)**

- ```lua
  stopVideo('videoTag')
  ```

  **-- Video alpha tween**
  - **In order (tween tag, start alpha, end alpha, tween type)**

- ```lua
  tweenAlphaVideo("TweenTag", "videoTag", 0, 0.5, "linear")
  ```

  **-- Sets Video Alpha**

- ```lua
  setAlphaVideo('videoTag', 1.0)
  ```

---

### **For Windows**

  **-- Changes Windows Wallpaper (if absolute is false: [path: mods/images])**

- **In Order ( pngPath(String), absolute(Bool) )**

- ```lua
  changeWallpaper('funkay', false)
  ```

---

### **Video Resolution Types**

  **-- for this [Resolution type] -> ```makeVideo(videoName, videoTag, Cam, [Resolution Type])```**

```
  1 : (144p) - [256 x 144]
  2 : (240p) - [426 x 240]
  3 : (360p) - [640 x 360]
  4 : (480p) - [854 x 480]
  5 : (720p) - [1280 x 720]
  6 : (1080p) - [1920 x 1080]
  7 : (1440p) - [2560 x 1440]
```

---
