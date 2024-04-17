--[[
Tween = require("tween")
Basic = require("basic")
Snake = require("snake")
Game = require("game")
--]]
Enemy = require("enemy")
Camera = require("camera")

DEBUG = true

function love.load()
  local font = love.graphics.newFont(20)
  love.graphics.setFont(font)
  love.graphics.setBackgroundColor(0, 0, 0)
  math.randomseed(love.timer.getTime())

  ----- init -----
  Basic:init()
  Snake:init(250, 250)

  Game:init()
  Enemy:init()
end

function love.update(dt)
  Basic.info.FPS.fps = love.timer.getFPS()
  Game:game_start(dt)

  Snake:move(dt, Basic:get_map_border())
  Enemy:move(dt)

  Camera:set_offset(
    Snake.head.info._x - Basic.info.WINDOWS.WIDTH / 2,
    Snake.head.info._y - Basic.info.WINDOWS.HEIGHT / 2
  )
end

function love.draw()
  Camera:set()
  Basic:draw()
  Snake:draw()
  Camera:unset()

  Game:draw_minimap()
  Game:draw_score()
  Game:draw_score_bar()
  Basic:draw_fps()
  ---------- debug ----------
  if DEBUG then
    love.graphics.setColor(1, 0.2, 0.2, 1)
    --love.graphics.print("???:" .. tostring(Basic:Move(123124)), Basic.info.FPS.x, Basic.info.FPS.y + 50)
    love.graphics.print("time: " .. tostring(love.timer.getTime()), Basic.info.FPS.x, Basic.info.FPS.y + 25)
    love.graphics.print("speed: " .. tostring(Snake.head.speed), Basic.info.FPS.x, Basic.info.FPS.y + 50)
    love.graphics.print("x: " .. tostring(Snake.head.info._x), Basic.info.FPS.x, Basic.info.FPS.y + 75)
    love.graphics.print("y: " .. tostring(Snake.head.info._y), Basic.info.FPS.x, Basic.info.FPS.y + 100)
    --[[
    ]]
  end
end
