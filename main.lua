Game = require("game")
Camera = require("camera")
DEBUG = true

function love.load()
  local font = love.graphics.newFont(20)
  love.graphics.setFont(font)
  love.graphics.setBackgroundColor(0, 0, 0)
  math.randomseed(love.timer.getTime())

  ----- init -----
  Basic:init()

  Game:init()
  love.audio.setVolume(0.6)
  Basic.info.bgm:play()
end

function love.update(dt)
  Basic.info.FPS.fps = love.timer.getFPS()
  Game:game_start(dt)

  Camera:set_offset(
    Snake.snake.head.info._x - Basic.info.WINDOWS.WIDTH / 2,
    Snake.snake.head.info._y - Basic.info.WINDOWS.HEIGHT / 2
  )

  if FLAG then
    if love.timer.getTime() >= 10 then
      FLAG = false
      Game:add_enemy_snake()
    end
  end
end

function love.draw()
  Camera:set()
  Game:draw_game()
  Camera:unset()

  Game:draw_ui()
  Basic:draw_fps()
  ---------- debug ----------
  if DEBUG then
    love.graphics.setColor(1, 0.2, 0.2, 1)
    love.graphics.print("time: " .. tostring(love.timer.getTime()), Basic.info.FPS.x, Basic.info.FPS.y + 25)
    love.graphics.print("speed: " .. tostring(Snake.snake.head.speed), Basic.info.FPS.x, Basic.info.FPS.y + 50)
    love.graphics.print("x: " .. tostring(Snake.snake.head.info._x), Basic.info.FPS.x, Basic.info.FPS.y + 75)
    love.graphics.print("y: " .. tostring(Snake.snake.head.info._y), Basic.info.FPS.x, Basic.info.FPS.y + 100)

    love.graphics.print(
      "head health: " .. tostring(Snake.snake.head.health),
      Basic.info.FPS.x,
      Basic.info.FPS.y + 175
    )
    --[[
    ]]
  end
end
