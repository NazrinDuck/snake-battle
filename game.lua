Basic = require("basic")
Snake = require("snake")

Game = {}

TIME_GAP = 5
RESOURCE_VALUE = 10
MAX_RESOURCES = 10
MAX_SCORE = 50

Game.sum_score = 0
Game.score = 0

Game.resource = {
  name = "resource",
  radius = 10,
  color = { 50 / 255, 50 / 255, 255 / 255 },
  timer = 0,
  mesh = nil,
  resources = {},
}

Game.minimap = {
  _x = 0,
  _y = 0,
  height = 250,
  width = 250,
  mesh = nil,
  border_mesh = nil,
}

Game.score_bar = {
  info = {
    _x = Basic.info.WINDOWS.WIDTH - 50,
    _y = Basic.info.WINDOWS.HEIGHT - 50,
    rot = 0,
    sx = 1,
    sy = 0,
  },
  height = 850,
  width = 40,
  mesh = nil,
}

local function distance(a, b)
  return math.sqrt((a._x - b._x) * (a._x - b._x) + (a._y - b._y) * (a._y - b._y))
end

function Game:collision(a, b)
  if distance(a.info, b.info) <= a.radius + b.radius then
    return true
  end
  return false
end

function Game:init()
  self:init_mesh()

  Snake.head = self:generate_map(Snake.head, Snake.info.color)
  table.insert(Basic.objects, Snake.head)
  table.insert(Basic.objects, self.resource)
end

function Game:init_mesh()
  --segments = segments or 40
  local segments = 60
  local vertices = {}

  table.insert(vertices, { 0, 0, 0.5, 0.5, 0.8, 0.8, 0.8, 0.4 })

  for i = 0, segments do
    local angle = (i / segments) * math.pi * 2

    local x = math.cos(angle)
    local y = math.sin(angle)

    local u = (x + 1) * 0.5
    local v = (y + 1) * 0.5

    table.insert(vertices, { x, y, u, v })
  end
  self.resource.mesh = love.graphics.newMesh(vertices, "fan")
  self.minimap.mesh = love.graphics.newMesh(vertices, "fan")

  local height = Basic.info.WINDOWS.HEIGHT * self.minimap.height / Basic:get_map_border().height
  local width = Basic.info.WINDOWS.WIDTH * self.minimap.width / Basic:get_map_border().width

  local vertices_border = {
    { -width / 2, -height / 2, 0, 0, 1, 1, 1 },
    { width / 2,  -height / 2, 1, 0, 1, 1, 1 },
    { width / 2,  height / 2,  1, 0, 1, 1, 1 },
    { -width / 2, height / 2,  0, 0, 1, 1, 1 },
  }

  self.minimap.border_mesh = love.graphics.newMesh(vertices_border, "fan")

  local length = self.score_bar.width
  local vertices_score_bar = {
    { -length, -length, 0, 0, 1, 1, 1 },
    { -length, 0,       1, 0, 1, 1, 1 },
    { 0,       0,       1, 0, 1, 1, 1 },
    { 0,       -length, 0, 0, 1, 1, 1 },
  }
  self.score_bar.mesh = love.graphics.newMesh(vertices_score_bar, "fan")
end

function Game:game_start(dt)
  self:generate_resource(dt)
  self:eat_resource()
  self:map_minimap()

  local width, height = love.graphics.getDimensions()
  Basic.info.WINDOWS.WIDTH = width
  Basic.info.WINDOWS.HEIGHT = height
end

---resource start---

function Game:generate_resource(dt)
  if #self.resource.resources > MAX_RESOURCES then
    return
  end

  if self.resource.timer >= TIME_GAP then
    local x = math.random() * Basic:get_map_border().width
    local y = math.random() * Basic:get_map_border().height
    self.resource.timer = 0

    local resource = {
      info = {
        _x = x,
        _y = y,
      },
      value = math.random() * 10 + RESOURCE_VALUE,
      radius = self.resource.radius,
    }

    resource = self:generate_map(resource, self.resource.color)

    table.insert(self.resource.resources, resource)
  end
  self.resource.timer = self.resource.timer + dt
end

function Game:eat_resource()
  for i, resource in ipairs(self.resource.resources) do
    if self:collision(Snake.head, resource) then
      self.score = self.score + resource.value
      self.sum_score = self.sum_score + resource.value
      self:update_score_bar()

      table.remove(self.resource.resources, i)
    end
  end
end

---resource end---

---------------minimap start---------------
function Game:generate_map(object, color)
  if object == nil then
    return {}
  end
  local map_point = {
    map_x = object.info._x * (self.minimap.width / Basic.info.WINDOWS.WIDTH),
    map_y = object.info._y * (self.minimap.height / Basic.info.WINDOWS.HEIGHT),
    map_color = color,
  }

  object = setmetatable(object, {
    __index = map_point,
  })

  return object
end

function Game:map_minimap()
  for _, object in ipairs(Basic.objects) do
    if object.name == "head" then
      object.map_x = object.info._x * (self.minimap.width / Basic:get_map_border().width)
      object.map_y = object.info._y * (self.minimap.height / Basic:get_map_border().height)
      goto continue
    end

    if object.name == "resource" then
      for _, resource in ipairs(object.resources) do
        resource.map_x = resource.info._x * (self.minimap.width / Basic:get_map_border().width)
        resource.map_y = resource.info._y * (self.minimap.height / Basic:get_map_border().height)
      end
      goto continue
    end

    if object.name == "enemy" then
      for _, snake in ipairs(object) do
        snake.head.map_x = snake.head.info._x * (self.minimap.width / Basic:get_map_border().width)
        snake.head.map_y = snake.head.info._y * (self.minimap.height / Basic:get_map_border().height)
      end
      goto continue
    end
    ::continue::
  end
end

function Game:draw_minimap()
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("line", self.minimap._x, self.minimap._y, self.minimap.width, self.minimap.height)
  love.graphics.setColor(0.8, 0.8, 0.8, 0.8)
  love.graphics.rectangle("fill", self.minimap._x, self.minimap._y, self.minimap.width, self.minimap.height)

  for _, object in ipairs(Basic.objects) do
    if object.name == "head" then
      love.graphics.setColor(0.8, 0, 0, 0.3)
      love.graphics.draw(self.minimap.border_mesh, object.map_x, object.map_y, 0, 1, 1)

      love.graphics.setColor(object.map_color)
      love.graphics.draw(self.minimap.mesh, object.map_x, object.map_y, 0, 4, 4)
      goto continue
    end

    if object.name == "resource" then
      for _, resource in ipairs(object.resources) do
        love.graphics.setColor(resource.map_color)
        love.graphics.draw(self.minimap.mesh, resource.map_x, resource.map_y, 0, 4, 4)
      end
      goto continue
    end

    if object.name == "enemy" then
      for _, snake in ipairs(object) do
        love.graphics.setColor(snake.head.map_color)
        love.graphics.draw(self.minimap.mesh, snake.head.map_x, snake.head.map_y, 0, 4, 4)
      end
      goto continue
    end
    ::continue::
  end
end

---------------minimap end---------------
--
--
--
---------------score_bar start---------------
function Game:update_score_bar()
  if Snake.info.body_nums == 10 then
    return
  end

  while self.score >= MAX_SCORE do
    if Snake.info.body_nums == 9 then
      Snake:add_body()
      self.score_bar.info.sy = self.score_bar.height / self.score_bar.width
      return
    end
    self.score = self.score - MAX_SCORE
    Snake:add_body()

    --[[
    if Snake.info.body_nums == 4 then
      coroutine.create(Enemy.add_enemy_snake)
    end
    ]]
  end

  local max_height = self.score_bar.height
  local new_height = (self.score / MAX_SCORE) * max_height
  self.score_bar.info.sy = new_height / self.score_bar.width
end

function Game:draw_score()
  love.graphics.setColor(1, 0.2, 0.2, 1)
  love.graphics.print(
    "score: " .. tostring(math.floor(self.sum_score * 10)),
    Basic.info.FPS.x,
    Basic.info.FPS.y + 125
  )
end

function Game:draw_score_bar()
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle(
    "line",
    self.score_bar.info._x,
    self.score_bar.info._y,
    -self.score_bar.width,
    -self.score_bar.height
  )
  love.graphics.setColor(0.6, 0.6, 0.6, 0.6)
  love.graphics.rectangle(
    "fill",
    self.score_bar.info._x,
    self.score_bar.info._y,
    -self.score_bar.width,
    -self.score_bar.height
  )
  love.graphics.setColor(0.5, 0.5, 1, 0.8)
  love.graphics.draw(
    self.score_bar.mesh,
    self.score_bar.info._x,
    self.score_bar.info._y,
    0,
    self.score_bar.info.sx,
    self.score_bar.info.sy
  )
end

---------------score_bar end---------------
return Game
