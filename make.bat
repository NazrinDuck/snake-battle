@echo off
if not exist .\build (mkdir .\build)

zip -q -r .\build\snake.love .\ui .\game .\game.lua .\main.lua .\const.lua .\images .\audios


@rem copy /b .\love\love.exe+.\build\snake.love .\love\snake.exe
@rem .\love\snake.exe

