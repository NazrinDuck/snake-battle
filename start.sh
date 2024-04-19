#!/usr/bin/sh
if test -d ./build;then
  dir="./build/"
else
  mkdir ./build
  dir="./build/"
fi

zip -q -r ${dir}snake.zip ./game.lua ./basic.lua ./main.lua ./snake.love ./camera.lua ./images

mv ${dir}snake.zip ${dir}snake.love

love ${dir}snake.love
