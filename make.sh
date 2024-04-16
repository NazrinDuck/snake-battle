#!/usr/bin/sh
if test -d ./snake.love;then
  rm ./snake.love
fi

zip -q -r snake.zip ./game.lua ./basic.lua ./main.lua ./snake.love ./camera.lua ./images

mv ./snake.zip ./snake.love
