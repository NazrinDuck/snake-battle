Basic = {}
Basic.info = {
  WINDOWS = {
    HEIGHT = 960,
    WIDTH = 1280,
    BACKGROUND = {
      image = love.graphics.newImage("images/background.jpg"),
      _x = 0,
      _y = 0,
      rot = 0,
      sx = 6,
      sy = 6,
      ox = 0,
      oy = 0,
    },
  },
  FPS = {
    x = 0,
    y = 0,
    fps = 0,
  },
  POINT = {
    radius = 4,
  },
  TIME = 0,
}
function Basic:init()
  local success = love.window.setMode(
    self.info.WINDOWS.WIDTH,
    self.info.WINDOWS.HEIGHT,
    { vsync = true, minwidth = 400, minheight = 300 }
  )
  if not success then
    print("fail")
  end
end

function Basic:draw()
  love.graphics.setColor(255, 255, 255, 0.8)
  love.graphics.draw(
    self.info.WINDOWS.BACKGROUND.image,
    self.info.WINDOWS.BACKGROUND._x,
    self.info.WINDOWS.BACKGROUND._y,
    self.info.WINDOWS.BACKGROUND.rot,
    self.info.WINDOWS.BACKGROUND.sx,
    self.info.WINDOWS.BACKGROUND.sy,
    self.info.WINDOWS.BACKGROUND.ox,
    self.info.WINDOWS.BACKGROUND.oy
  )
end

function Basic:draw_fps()
  love.graphics.setColor(1, 0, 0.5, 1)
  love.graphics.print("FPS: " .. tostring(self.info.FPS.fps), self.info.FPS.x, self.info.FPS.y)
end

return Basic
