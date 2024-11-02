# FNF Haryu5412 Engine

[ Based Psych Engine 0.6.3 Git ]

---

## Haryu Engine Lua++

### **For Video Sprite Lua**

  **-- DEPRECATED!! OLD VideoSprite Make Code (but sometimes can be used...?)**
- ```lua
  makeCutSenceVideo('videoName')
  ```

  **-- Play video to fill the screen. (autoplay)**
- ```lua
  makeVideo('videoName', 'videoTag', 'camHUD')
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
  **- In Order ( pngPath(String), absolute(Bool) )**
- ```lua
  changeWallpaper('funkay', false)
  ``` 

---