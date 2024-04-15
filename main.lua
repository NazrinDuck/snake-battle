Tween = require("tween")
Basic = require("basic")
Snake = require("snake")
Camera = require("camera")

DEBUG = true

function love.load()
  local font = love.graphics.newFont(20)
  love.graphics.setFont(font)
  love.graphics.setBackgroundColor(114, 114, 114)

  ----- init -----
  Basic:init()
  Snake:init(0, 0)
end

function love.update(dt)
  Basic.info.FPS.fps = love.timer.getFPS()

  Snake:move(dt)

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
  ---------- debug ----------
  if DEBUG then
    love.graphics.setColor(1, 0, 0.5, 1)
    --love.graphics.print("???:" .. tostring(Basic:Move(123124)), Basic.info.FPS.x, Basic.info.FPS.y + 50)
    love.graphics.print("time: " .. tostring(love.timer.getTime()), Basic.info.FPS.x, Basic.info.FPS.y + 25)
    love.graphics.print("speed: " .. tostring(Snake.head.speed), Basic.info.FPS.x, Basic.info.FPS.y + 50)
    --[[
    love.graphics.print("ox: " .. tostring(Self_plane.info.ox), Basic.info.FPS.x, Basic.info.FPS.y + 50)
    love.graphics.print("oy: " .. tostring(Self_plane.info.oy), Basic.info.FPS.x + 100, Basic.info.FPS.y + 50)
    ]]
  end
end
