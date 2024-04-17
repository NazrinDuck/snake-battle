Game = require("game")
Enemy = {}

MAX_ENEMY = 1

Enemy.snake = {
  nums = 0,
  accelerate = 250,
  rot_speed = math.pi * 0.5,
  color = { 204 / 255, 0, 0 },

  snakes = {},
}

local function distance(a, b)
  return math.sqrt((a._x - b._x) * (a._x - b._x) + (a._y - b._y) * (a._y - b._y))
end

local function angle(a, b)
  if a._x - b._x < 0 then
    return math.atan((a._y - b._y) / (a._x - b._x))
  end
  return math.atan((a._y - b._y) / (a._x - b._x)) + math.pi
end

function Enemy:init()
  self.snake.snakes.name = "enemy"
  local co = coroutine.create(Enemy.add_enemy_snake)
  coroutine.resume(co, 4)
  table.insert(Basic.objects, self.snake.snakes)
end

function Enemy:move(dt)
  local border = Basic:get_map_border()
  for _, snake in ipairs(self.snake.snakes) do
    local new_x = snake.head.info._x + dt * snake.head.speed * math.cos(snake.head.info.rot)
    local new_y = snake.head.info._y + dt * snake.head.speed * math.sin(snake.head.info.rot)

    if
        new_x - snake.head.info.ox * SIZE >= 0
        and new_x + snake.head.info.ox * SIZE < border.width
        and new_y - snake.head.info.oy * SIZE >= 0
        and new_y + snake.head.info.oy * SIZE < border.height
    then
      snake.head.info._x = new_x
      snake.head.info._y = new_y
    else
      snake.head.info.rot = snake.head.info.rot + dt * self.snake.rot_speed
    end

    for i, body in ipairs(snake.bodys) do
      local pre = {}
      if i == 1 then
        pre = snake.head
      else
        pre = snake.bodys[i - 1]
      end
      body.info._x = body.info._x + dt * body.speed * math.cos(body.info.rot)
      body.info._y = body.info._y + dt * body.speed * math.sin(body.info.rot)

      local dangle = angle(body.info, pre.info)
      body.info.rot = dangle

      if distance(body.info, pre.info) >= 75 and body.speed <= SPEED_HIGH then
        body.speed = body.speed + dt * self.snake.accelerate
        goto continue
      elseif distance(body.info, pre.info) <= 50 and body.speed >= SPEED_LOW then
        body.speed = body.speed - dt * self.snake.accelerate
        goto continue
      end

      if body.speed >= SPEED_NORMAL then
        body.speed = body.speed - dt * self.snake.accelerate
        goto continue
      else
        body.speed = body.speed + dt * self.snake.accelerate
        goto continue
      end
      ::continue::
    end
  end
end

function Enemy.add_enemy_snake(body_nums)
  local x = math.random() * Basic:get_map_border().width
  local y = math.random() * Basic:get_map_border().height

  local snake = {}
  local head = {
    name = "head",
    info = {
      _x = x,
      _y = y,
      rot = 0,
      sx = SIZE,
      sy = SIZE,
      ox = 0,
      oy = 0,
    },
    color = Enemy.snake.color,
    radius = 0,
    speed = SPEED_NORMAL,
    image = love.graphics.newImage("images/head.png"),
  }
  head.info.ox = head.image:getWidth() / 2
  head.info.oy = head.image:getHeight() / 2
  head.radius = (head.info.ox + head.info.oy) * SIZE / 2

  local bodys = {}
  for i = 1, body_nums, 1 do
    local body = {
      name = "head",
      info = {
        _x = x + 20 * i,
        _y = y,
        rot = 0,
        sx = SIZE,
        sy = SIZE,
        ox = 0,
        oy = 0,
      },
      color = Enemy.snake.color,
      radius = 0,
      speed = SPEED_NORMAL,
      image = love.graphics.newImage("images/body.png"),
    }
    body.info.ox = body.image:getWidth() / 2
    body.info.oy = body.image:getHeight() / 2
    body.radius = (body.info.ox + body.info.oy) * SIZE / 2
    table.insert(bodys, body)
  end

  local tail = {
    info = {
      _x = x,
      _y = y,
      rot = 0,
      sx = SIZE,
      sy = SIZE,
      ox = 0,
      oy = 0,
    },
    radius = 0,
    speed = SPEED_NORMAL,
    image = love.graphics.newImage("images/tail.png"),
  }
  tail.info.ox = tail.image:getWidth() / 2
  tail.info.oy = tail.image:getHeight() / 2
  tail.radius = (tail.info.ox + tail.info.oy) * SIZE / 2

  head = Game:generate_map(head, head.color)

  snake.head = head
  snake.bodys = bodys
  table.insert(bodys, tail)

  snake.color = Enemy.snake.color

  table.insert(Enemy.snake.snakes, snake)
  print(1)
end

return Enemy
