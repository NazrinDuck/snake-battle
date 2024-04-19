# 贪吃蛇大战(Snake Battle)

所选题目：赛道二

游戏框架：[love2d](https://www.love2d.org/wiki/Main_Page), 编程语言及版本：Lua 5.4.6

##  先决条件

------

拥有Lua环境，love2d环境已打包。

## 本地运行环境

------

操作系统：Windows11， WSL2(Kali GNU/Linux Rolling on Windows 10 x86_64)

## 运行方式

------

Windows11: 运行start.bat文件.

Linux:运行start.sh文件。

如果拥有Lua以及love2d环境可直接运行build目录下的snake.love

## 代码简介

------

文件架构：

```
snake
├── audios
│   ├── bgm.wav
│   └── load_bgm.wav
├── build
│   └── snake.love
├── const.lua
├── game
│   ├── basic.lua
│   ├── bullet.lua
│   ├── enemy.lua
│   └── snake.lua
├── game.lua
├── images
│   ├── background.png
│   ├── body.png
│   ├── head.png
│   └── tail.png
├── main.lua
├── README.md
├── start.bat
├── start.sh
└── ui
    ├── button.lua
    ├── camera.lua
    ├── health.lua
    └── minimap.lua
```

- audios文件夹：存放游戏的背景音乐（个人套MIDI制作）
- build文件夹：存放打包完成的游戏
- image文件夹：存放游戏的背景图片以及贪吃蛇图片（个人PS制作）
- game文件夹：存放游戏核心脚本
  - basic.lua：负责存放游戏基本变量并初始化，渲染背景，集中渲染游戏对象（玩家，资源，敌人）。
  - bullet.lua：负责生成，渲染和移动子弹。提供子弹特性，发射子弹的函数接口。
  - enemy.lua：负责初始化，生成，移动一个或多个敌人。生成采用协程防止卡顿。追踪玩家，发射子弹以及绕开墙壁代码集中在move中。
  - snake.lua：负责初始化，生成，移动玩家；响应键盘输入并移动。
- ui文件夹：存放界面ui相关脚本
  - button.lua：负责初始化，生成界面按钮，实现按钮的功能。
  - camera.lua：负责初始化摄像机，使得玩家固定在屏幕中央。
  - health.lua：负责生成和渲染生命条，提供生命条特性接口，并清除生命值小于0的对象。
  - minimap.lua：负责生成和渲染小地图，提供小地图显示特性接口；映射地图位置与实际位置。
- const.lua：集中存放游戏的常量，防止冲突
- game.lua：集中处理各种游戏逻辑，初始化与加载功能，汇聚game文件夹与ui文件夹的文件并处理各种对象之间的交互（资源生成与吃掉，敌人与玩家的碰撞检测，子弹的碰撞检测等），实现不同脚本之间的交流；通过绑定特性的方法实现各种功能（小地图显示，子弹射击等）
- main.lua：游戏的入口，实现开始，失败，胜利的不同场景切换，各种游戏资源在这里初始化。

## 环境变量

------

无。和游戏相关的常量存放在const.lua中。

## 游戏说明

------

本游戏是一个广义的贪吃蛇游戏，操纵方式为上，下，左，右与z键（初始界面需要鼠标）。其中，上/下键控制加/减速；左右键则为旋转。z键可以发射子弹，命中敌人的部位可以给敌人该部位造成伤害。

![](E:\Linux\lua-codes\snake\md-images\image.png)

如图，左上角为游戏的小地图，蓝色代表资源，红色代表敌人，绿色为玩家，红色半透明边框为视野范围。小地图下方为ui。游戏画面中，玩家和敌人的每一部分都有血条显示。右边长条为经验条。

### 游戏机制

------

蓝点间隔一定时间随机生成，玩家吃蓝点会增加经验条高度，满了之后就会增加一节身体，最多10节。蓝点经验随机，大小可以直观反应。

敌人数量超过两个资源便不再生成，此时必须杀死至少一只敌人。

开局会有一只敌人，120s后会再生成一只，身体数量达到8时还会生成一只。

在接近敌人时敌人会追踪玩家并发射子弹（这个ai写得很烂，可能会导致卡墙里）

碰撞敌人和墙壁会减少生命值，不要这么做。

### 攻击部分

------

小绿点为玩家子弹，小红点为敌人子弹，双方击中对方会对击中区域造成伤害，血条减少。无论玩家还是敌人，头部与身体的血量相同，但子弹对头部有减伤，该减伤效果与存在身体节数成正相关。

身体部分血条归零会直接消失，头部血条归零整条蛇消失，玩家则直接游戏结束失败。

### 胜利条件

------

只要坚持到拥有10节身体即可。由于游戏机制，玩家至少要打死一只敌人才有足够的资源收集。

PS：由于开发时间短，语言运用不熟练，个人能力欠缺等原因，游戏有些功能并不完善，有些想法没能实现，有些代码写得很差劲，恳请各位评委多多包涵。