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
      sx = 4,
      sy = 4,
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
Basic.minimap = {
  _x = 0,
  _y = 0,
  height = 250,
  width = 250,
  mesh = nil,
}

---basic minimap---
function Basic:add_point(object, color)
  if object == nil then
    return {}
  end
  local map_point = {
    map_x = object.info._x * (self.minimap.width / self.info.WINDOWS.WIDTH),
    map_y = object.info._y * (self.minimap.height / self.info.WINDOWS.HEIGHT),
    map_color = color,
  }

  object = setmetatable(object, {
    __index = map_point,
  })
  table.insert(self.objects, object)

  return object
end

function Basic:map_minimap()
  for _, object in ipairs(self.objects) do
    if object.name == "head" then
      object.map_x = object.info._x * (self.minimap.width / self:get_map_border().width)
      object.map_y = object.info._y * (self.minimap.height / self:get_map_border().height)
      goto continue
    end

    if object.name == "resource" then
      for _, resource in ipairs(object.resources) do
        resource.map_x = resource.info._x * (self.minimap.width / self:get_map_border().width)
        resource.map_y = resource.info._y * (self.minimap.height / self:get_map_border().height)
      end
      goto continue
    end
    ::continue::
  end
end

function Basic:init(objects)
  if type(objects) == "table" then
    for _, object in ipairs(objects) do
      self:add_point(object.item, object.color)
    end
  end
  local success = love.window.setMode(
    self.info.WINDOWS.WIDTH,
    self.info.WINDOWS.HEIGHT,
    { vsync = true, minwidth = 400, minheight = 300 }
  )
  if not success then
    print("fail")
  end

  --segments = segments or 40
  local segments = 60
  local vertices = {}

  table.insert(vertices, { 0, 0, 0.5, 0.5, 255, 255, 255 })

  for i = 0, segments do
    local angle = (i / segments) * math.pi * 2

    local x = math.cos(angle)
    local y = math.sin(angle)

    local u = (x + 1) * 0.5
    local v = (y + 1) * 0.5

    table.insert(vertices, { x, y, u, v })
  end
  self.minimap.mesh = love.graphics.newMesh(vertices, "fan")
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
        love.graphics.draw(object.mesh, resource.info._x, resource.info._y, 0, object.radius, object.radius)
      end
      goto continue
    end

    ::continue::
  end
  --[[
]]
end

function Basic:draw_minimap()
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("line", self.minimap._x, self.minimap._y, self.minimap.width, self.minimap.height)
  love.graphics.setColor(0.8, 0.8, 0.8, 0.8)
  love.graphics.rectangle("fill", self.minimap._x, self.minimap._y, self.minimap.width, self.minimap.height)

  for _, object in ipairs(self.objects) do
    if object.name == "head" then
      love.graphics.setColor(object.map_color)
      love.graphics.draw(self.minimap.mesh, object.map_x, object.map_y, 0, 5, 5)
      goto continue
    end

    if object.name == "resource" then
      for _, resource in ipairs(object.resources) do
        love.graphics.setColor(resource.map_color)
        love.graphics.draw(self.minimap.mesh, resource.map_x, resource.map_y, 0, 5, 5)
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
