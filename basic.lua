Basic = {}

Basic.info = {
  WINDOWS = {
    HEIGHT = 960,
    WIDTH = 1280,
    BACKGROUND = {
      image = love.graphics.newImage("images/background.png"),
      _x = 0,
      _y = 0,
      rot = 0,
      sx = 3,
      sy = 3,
      ox = 0,
      oy = 0,
    },
  },
  FPS = {
    x = 0,
    y = 250,
    fps = 0,
  },
}

Basic.objects = {}

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
  love.graphics.setColor(1, 1, 1, 1)
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

  for _, object in ipairs(self.objects) do
    if object.name == "head" then
      love.graphics.setColor(object.color)
      love.graphics.draw(
        object.image,
        object.info._x,
        object.info._y,
        object.info.rot,
        object.info.sx,
        object.info.sy,
        object.info.ox,
        object.info.oy
      )
      goto continue
    end

    if object.name == "resource" then
      for _, resource in ipairs(object.resources) do
        love.graphics.setColor(object.color)
        love.graphics.draw(
          object.mesh,
          resource.info._x,
          resource.info._y,
          0,
          resource.radius + 2 * resource.value,
          resource.radius + 2 * resource.value
        )
      end
      goto continue
    end

    if object.name == "enemy" then
      for _, snake in ipairs(object) do
        love.graphics.setColor(snake.color)
        love.graphics.draw(
          snake.head.image,
          snake.head.info._x,
          snake.head.info._y,
          snake.head.info.rot,
          snake.head.info.sx,
          snake.head.info.sy,
          snake.head.info.ox,
          snake.head.info.oy
        )
        for _, body in ipairs(snake.bodys) do
          love.graphics.draw(
            body.image,
            body.info._x,
            body.info._y,
            body.info.rot,
            body.info.sx,
            body.info.sy,
            body.info.ox,
            body.info.oy
          )
        end
      end
      goto continue
    end

    ::continue::
  end
end

function Basic:get_map_border()
  return {
    height = self.info.WINDOWS.BACKGROUND.image:getHeight() * self.info.WINDOWS.BACKGROUND.sy,
    width = self.info.WINDOWS.BACKGROUND.image:getWidth() * self.info.WINDOWS.BACKGROUND.sx,
  }
end

function Basic:draw_fps()
  love.graphics.setColor(1, 0, 0.5, 1)
  love.graphics.print("FPS: " .. tostring(self.info.FPS.fps), self.info.FPS.x, self.info.FPS.y)
end

return Basic
