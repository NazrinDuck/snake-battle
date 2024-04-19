@echo off
if not exist .\build (mkdir .\build)

zip -q -r .\build\snake.love .\ui .\game .\game.lua .\main.lua .\const.lua .\images .\audios

copy /b .\love\love.exe+.\build\snake.love .\love\snake.exe

.\love\snake.exe
