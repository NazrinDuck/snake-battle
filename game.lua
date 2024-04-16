Basic = require("basic")

Game = {}

TIME_SNAP = 5
VALUE = 10

Game.resource = {
  name = "resource",
  radius = 20,
  color = { 50 / 255, 50 / 255, 255 / 255 },
  timer = 0,
  mesh = nil,
  resources = {},
}

local function distance(a, b)
  return math.sqrt((a._x - b._x) * (a._x - b._x) + (a._y - b._y) * (a._y - b._y))
end

function Game:init()
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
  self.resource.mesh = love.graphics.newMesh(vertices, "fan")

  math.randomseed(love.timer.getTime())
end

function Game:game_start(dt, player)
  self:generate_resource(dt)
  self:eat_resource(player)
end

function Game:generate_resource(dt)
  if #self.resource.resources > 20 then
    return
  end

  if self.resource.timer >= TIME_SNAP then
    local x = math.random() * Basic:get_map_border().width
    local y = math.random() * Basic:get_map_border().height
    self.resource.timer = 0

    local resource = {
      info = {
        _x = x,
        _y = y,
      },
      value = math.random() * 10 + 5,
      radius = self.resource.radius,
    }

    resource = Basic:add_point(resource, self.resource.color)

    table.insert(self.resource.resources, resource)
    table.insert(Basic.objects, self.resource)
  end
  self.resource.timer = self.resource.timer + dt
end

function Game:eat_resource(player)
  for i, resource in ipairs(self.resource.resources) do
    if self:collision(player, resource) then
      --print("collision happened")
      table.remove(self.resource.resources, i)
    end
  end
end

function Game:collision(a, b)
  if distance(a.info, b.info) <= a.radius + b.radius then
    return true
  end
  return false
end

return Game
