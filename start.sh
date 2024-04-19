#!/usr/bin/sh
if test -d ./build;then
  dir="./build/"
else
  mkdir ./build
  dir="./build/"
fi

zip -q -r ${dir}snake.zip ./ui ./game ./game.lua ./main.lua ./const.lua ./images ./audios

mv ${dir}snake.zip ${dir}snake.love

love ./build/snake.love
