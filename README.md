# FNF Haryu5412's Modding Engine

[ Based Psych Engine 0.6.3 Git ]

---

## Haryu Engine Lua++

### **For Video Sprite Lua**

  **-- Play video to the screen. (autoplay and auto resize video)**
  **(camGame Video can be cause super lagging!!!! dont USE PLZZZ)**

- ```lua
  makeVideo('videoName', 'videoTag', 'camHUD')
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

---
