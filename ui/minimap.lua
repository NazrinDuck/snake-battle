Minimap = {
  _x = 0,
  _y = 0,
  height = 250,
  width = 250,
  mesh = nil,
  border_mesh = nil,
}

Minimap.border = {
  width = 0,
  height = 0,
}

Minimap.map_border = {
  width = 0,
  height = 0,
}

function Minimap:init(border, map_border)
  self.border.width = border.width
  self.border.height = border.height

  self.map_border.width = map_border.width
  self.map_border.height = map_border.height

  --segments = segments or 40
  local segments = 60
  local vertices = {}

  table.insert(vertices, { 0, 0, 0.5, 0.5, 1, 1, 1 })

  for i = 0, segments do
    local angle = (i / segments) * math.pi * 2

    local x = math.cos(angle)
    local y = math.sin(angle)

    local u = (x + 1) * 0.5
    local v = (y + 1) * 0.5

    table.insert(vertices, { x, y, u, v })
  end
  self.mesh = love.graphics.newMesh(vertices, "fan")

  local height = self.border.height * self.height / map_border.height
  local width = self.border.width * self.width / map_border.width

  local vertices_border = {
    { -width / 2, -height / 2, 0, 0, 1, 1, 1 },
    { width / 2,  -height / 2, 1, 0, 1, 1, 1 },
    { width / 2,  height / 2,  1, 0, 1, 1, 1 },
    { -width / 2, height / 2,  0, 0, 1, 1, 1 },
  }

  self.border_mesh = love.graphics.newMesh(vertices_border, "fan")
end

function Minimap:generate_map(object, color)
  if object == nil then
    return {}
  end
  object.map_x = object.info._x * (self.width / self.border.width)
  object.map_y = object.info._y * (self.height / self.border.height)
  object.map_color = color

  return object
end

function Minimap:map_minimap(objects)
  for _, object in ipairs(objects) do
    if object.name == "player" then
      object.head.map_x = object.head.info._x * (self.width / self.map_border.width)
      object.head.map_y = object.head.info._y * (self.height / self.map_border.height)
      goto continue
    end

    if object.name == "resource" then
      for _, resource in ipairs(object.resources) do
        resource.map_x = resource.info._x * (self.width / self.map_border.width)
        resource.map_y = resource.info._y * (self.height / self.map_border.height)
      end
      goto continue
    end

    if object.name == "enemy" then
      for _, snake in ipairs(object) do
        snake.head.map_x = snake.head.info._x * (self.width / self.map_border.width)
        snake.head.map_y = snake.head.info._y * (self.height / self.map_border.height)
      end
      goto continue
    end
    ::continue::
  end
end

function Minimap:draw_minimap(objects)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("line", self._x, self._y, self.width, self.height)
  love.graphics.setColor(0.8, 0.8, 0.8, 0.8)
  love.graphics.rectangle("fill", self._x, self._y, self.width, self.height)

  for _, object in ipairs(objects) do
    if object.name == "player" then
      love.graphics.setColor(0.8, 0, 0, 0.3)
      love.graphics.draw(self.border_mesh, object.head.map_x, object.head.map_y, 0, 1, 1)

      love.graphics.setColor(object.head.map_color)
      love.graphics.draw(self.mesh, object.head.map_x, object.head.map_y, 0, 4, 4)
      goto continue
    end

    if object.name == "resource" then
      for _, resource in ipairs(object.resources) do
        love.graphics.setColor(resource.map_color)
        love.graphics.draw(self.mesh, resource.map_x, resource.map_y, 0, 4, 4)
      end
      goto continue
    end

    if object.name == "enemy" then
      for _, snake in ipairs(object) do
        love.graphics.setColor(snake.head.map_color)
        love.graphics.draw(self.mesh, snake.head.map_x, snake.head.map_y, 0, 4, 4)
      end
      goto continue
    end
    ::continue::
  end
end

return Minimap
