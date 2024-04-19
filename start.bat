@echo off
if not exist .\build (mkdir .\build)

zip -q -r .\build\snake.zip .\ui .\game .\game.lua .\main.lua .\const.lua .\images .\audios
cd .\build
ren snake.zip snake.love
