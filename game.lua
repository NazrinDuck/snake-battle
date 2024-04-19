Basic = require("basic")
Snake = require("snake")
Enemy = require("enemy")
Minimap = require("minimap")
Health = require("health")
require("const")

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
  Snake:init(250, 250, Health.generate_health)
  Enemy:init()

  Minimap:init({
    height = Basic.info.WINDOWS.HEIGHT,
    width = Basic.info.WINDOWS.WIDTH,
  }, Basic:get_map_border())
  Health:init()

  self:init_mesh()
  table.insert(Basic.objects, self.resource)

  Snake.snake.head = Minimap:generate_map(Snake.snake.head, Snake.info.color)
  table.insert(Basic.objects, Snake.snake)

  table.insert(Basic.objects, Enemy.snake.snakes)
  --self:add_enemy_snake()
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
  self:check_hit()
  Minimap:map_minimap(Basic.objects)
  Health:update(Basic.objects)

  Snake:move(dt, Basic:get_map_border(), Enemy.snake.snakes)
  Enemy:move(dt, Basic:get_map_border(), Snake.snake)
end

function Game:draw_game()
  Basic:draw_background()
  Basic:draw_objects()
  Snake:draw()
  Health:draw_health(Basic.objects)
end

function Game:draw_ui()
  Minimap:draw_minimap(Basic.objects)
  self:draw_score()
  self:draw_score_bar()
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

    resource = Minimap:generate_map(resource, self.resource.color)

    table.insert(self.resource.resources, resource)
  end
  self.resource.timer = self.resource.timer + dt
end

function Game:eat_resource()
  for i, resource in ipairs(self.resource.resources) do
    if self:collision(Snake.snake.head, resource) then
      self.score = self.score + resource.value
      self.sum_score = self.sum_score + resource.value
      self:update_score_bar()

      table.remove(self.resource.resources, i)
    end
  end
end

---resource end---

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

    if Snake.info.body_nums == 4 or Snake.info.body_nums == 8 then
      self:add_enemy_snake()
    end

    Snake:add_body()
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
function Game:add_enemy_snake()
  Enemy.snake.add_snake(math.random(4, 8), Basic:get_map_border(), Health.generate_health)
  local index = #Enemy.snake.snakes
  Enemy.snake.snakes[index].head =
      Minimap:generate_map(Enemy.snake.snakes[index].head, Enemy.snake.snakes[index].head.color)
end

---------------bullet start---------------
function Game:check_hit()
  if #Snake.bullet.bullets == 0 then
    return
  end

  for _, object in ipairs(Basic.objects) do
    if object.name == "enemy" then
      for i, bullet in ipairs(Snake.bullet.bullets) do
        for _, snake in ipairs(object) do
          if self:collision(bullet, snake.head) then
            snake.head.health = snake.head.health - bullet.harm * ((100 - snake.head.armor) / 100)
            table.remove(Snake.bullet.bullets, i)
          end
          for _, body in ipairs(snake.bodys) do
            if self:collision(bullet, body) then
              body.health = body.health - bullet.harm * ((100 - body.armor) / 100)
              table.remove(Snake.bullet.bullets, i)
            end
          end
        end
      end
    end
    if object.name == "player" then
    end
  end
end

function Game:check_colliion() end

return Game
