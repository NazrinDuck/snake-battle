Tween = require("tween")
Basic = require("basic")
Snake = require("snake")
Camera = require("camera")
Game = require("game")

DEBUG = true

function love.load()
  local font = love.graphics.newFont(20)
  love.graphics.setFont(font)
  love.graphics.setBackgroundColor(0, 0, 0)

  ----- init -----
  Snake:init(250, 250)
  Basic:init({ {
    item = Snake.head,
    color = Snake.head.color,
  } })
  Game:init()
end

function love.update(dt)
  Basic.info.FPS.fps = love.timer.getFPS()

  Snake:move(dt, Basic:get_map_border())
  Basic:map_minimap()

  Game:game_start(dt, Snake.head)

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

  Basic:draw_fps()
  Basic:draw_minimap()
  ---------- debug ----------
  if DEBUG then
    love.graphics.setColor(1, 0, 0.5, 1)
    --love.graphics.print("???:" .. tostring(Basic:Move(123124)), Basic.info.FPS.x, Basic.info.FPS.y + 50)
    love.graphics.print("time: " .. tostring(love.timer.getTime()), Basic.info.FPS.x, Basic.info.FPS.y + 25)
    love.graphics.print("speed: " .. tostring(Snake.head.speed), Basic.info.FPS.x, Basic.info.FPS.y + 50)
    love.graphics.print("x: " .. tostring(Snake.head.info._x), Basic.info.FPS.x, Basic.info.FPS.y + 75)
    love.graphics.print("y: " .. tostring(Snake.head.info._y), Basic.info.FPS.x, Basic.info.FPS.y + 100)
    --[[
    ]]
  end
end
