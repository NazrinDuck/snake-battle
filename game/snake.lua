require("const")
Snake = {}

Snake.info = {
  body_nums = 1,
  accelerate = 250,
  rot_speed = math.pi * 0.5,
  color = { 0, 153 / 255, 76 / 255 },
  func_health = nil,
}

Snake.snake = {
  name = "player",
  color = Snake.info.color,
  head = {
    name = "head",
    info = {
      _x = 0,
      _y = 0,
      rot = 0,
      sx = SIZE,
      sy = SIZE,
      ox = 0,
      oy = 0,
    },
    color = Snake.info.color,
    radius = 0,
    speed = SPEED_NORMAL,
    image = love.graphics.newImage("images/head.png"),
  },

  body = {},

  tail = {
    info = {
      _x = 0,
      _y = 0,
      rot = 0,
      sx = SIZE,
      sy = SIZE,
      ox = 0,
      oy = 0,
    },
    radius = 0,
    speed = SPEED_NORMAL,
    image = love.graphics.newImage("images/tail.png"),
  },
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

function Snake:init(_x, _y, func_health)
  self.info.func_health = func_health
  self.snake.head.info._x = _x
  self.snake.head.info._y = _y
  self.snake.head.info.ox = self.snake.head.image:getWidth() / 2
  self.snake.head.info.oy = self.snake.head.image:getHeight() / 2
  self.snake.head.radius = (self.snake.head.info.ox + self.snake.head.info.oy) * SIZE / 2
  self.snake.head = self.info.func_health(self.snake.head, 100, ARMOR)

  local body = {
    info = {
      _x = _x - 30,
      _y = _y,
      rot = 0,
      sx = SIZE,
      sy = SIZE,
      ox = 0,
      oy = 0,
    },
    radius = 0,
    speed = 250,
    image = love.graphics.newImage("images/body.png"),
  }
  body.info.ox = body.image:getWidth() / 2
  body.info.oy = body.image:getHeight() / 2
  body.radius = (body.info.ox + body.info.oy) * SIZE / 2
  body = self.info.func_health(body, 100, 0)

  table.insert(self.snake.body, body)

  self.snake.tail.info._x = _x - 60
  self.snake.tail.info._y = _y
  self.snake.tail.info.ox = self.snake.tail.image:getWidth() / 2
  self.snake.tail.info.oy = self.snake.tail.image:getHeight() / 2
  self.snake.tail.radius = (self.snake.tail.info.ox + self.snake.tail.info.oy) * SIZE / 2
  self.snake.tail = self.info.func_health(self.snake.tail, 100, 0)

  table.insert(self.snake.body, self.snake.tail)
end

function Snake:move(dt, border, enemy)
  border = border or {
    height = 0,
    width = 0,
  }
  local new_x = self.snake.head.info._x + dt * self.snake.head.speed * math.cos(self.snake.head.info.rot)
  local new_y = self.snake.head.info._y + dt * self.snake.head.speed * math.sin(self.snake.head.info.rot)
  for _, snake in ipairs(enemy) do
    if distance({ _x = new_x, _y = new_y }, snake.head.info) <= snake.head.radius then
      self.snake.head.health = self.snake.head.health - (HARM * dt) * ((100 - self.snake.head.armor) / 100)
      snake.head.health = snake.head.health - (HARM * dt) * ((100 - snake.head.armor) / 100)
      goto continue
    end
    for _, body in ipairs(snake.bodys) do
      if distance({ _x = new_x, _y = new_y }, body.info) <= body.radius then
        self.snake.head.health = self.snake.head.health - (HARM * dt) * ((100 - self.snake.head.armor) / 100)
        body.health = body.health - (HARM * dt) * ((100 - body.armor) / 100)
        goto continue
      end
    end
  end

  if
      new_x - self.snake.head.info.ox * SIZE >= 0
      and new_x + self.snake.head.info.ox * SIZE < border.width
      and new_y - self.snake.head.info.oy * SIZE >= 0
      and new_y + self.snake.head.info.oy * SIZE < border.height
  then
    self.snake.head.info._x = new_x
    self.snake.head.info._y = new_y
  else
    self.snake.head.health = self.snake.head.health - (HARM * dt) * ((100 - self.snake.head.armor) / 100)
  end
  ::continue::

  self:keyboard_reaction(dt)
  self:move_body(dt)
end

function Snake:move_body(dt)
  for i, body in ipairs(self.snake.body) do
    local pre = {}
    if i == 1 then
      pre = self.snake.head
    else
      pre = self.snake.body[i - 1]
    end
    body.info._x = body.info._x + dt * body.speed * math.cos(body.info.rot)
    body.info._y = body.info._y + dt * body.speed * math.sin(body.info.rot)

    local dangle = angle(body.info, pre.info)
    body.info.rot = dangle

    if distance(body.info, pre.info) >= 75 and body.speed <= SPEED_HIGH then
      body.speed = body.speed + dt * self.info.accelerate
      goto continue
    elseif distance(body.info, pre.info) <= 50 and body.speed >= SPEED_LOW then
      body.speed = body.speed - dt * self.info.accelerate
      goto continue
    end

    if body.speed >= SPEED_NORMAL then
      body.speed = body.speed - dt * self.info.accelerate
      goto continue
    else
      body.speed = body.speed + dt * self.info.accelerate
      goto continue
    end
    ::continue::
  end
end

function Snake:keyboard_reaction(dt)
  if love.keyboard.isDown("up") and self.snake.head.speed <= SPEED_HIGH then
    self.snake.head.speed = self.snake.head.speed + dt * self.info.accelerate
  elseif self.snake.head.speed >= SPEED_NORMAL then
    self.snake.head.speed = self.snake.head.speed - dt * self.info.accelerate
  end

  if love.keyboard.isDown("down") and self.snake.head.speed >= SPEED_LOW then
    self.snake.head.speed = self.snake.head.speed - dt * self.info.accelerate
  elseif self.snake.head.speed <= SPEED_NORMAL then
    self.snake.head.speed = self.snake.head.speed + dt * self.info.accelerate
  end

  if love.keyboard.isDown("left") then
    self.snake.head.info.rot = self.snake.head.info.rot - self.info.rot_speed * dt
  end
  if love.keyboard.isDown("right") then
    self.snake.head.info.rot = self.snake.head.info.rot + self.info.rot_speed * dt
  end
end

function Snake:add_body()
  local index = 1
  local new_x = self.snake.body[index].info._x
  local new_y = self.snake.body[index].info._y
  local new_rot = self.snake.body[index].info.rot

  local body = {
    info = {
      _x = new_x,
      _y = new_y,
      rot = new_rot,
      sx = SIZE,
      sy = SIZE,
      ox = 0,
      oy = 0,
    },
    radius = 0,
    speed = 250,
    image = love.graphics.newImage("images/body.png"),
  }
  body.info.ox = body.image:getWidth() / 2
  body.info.oy = body.image:getHeight() / 2
  body.radius = (body.info.ox + body.info.oy) * SIZE / 2
  body = self.info.func_health(body, 100, 0)

  table.insert(self.snake.body, index, body)

  Snake.info.body_nums = #self.snake.body
  Snake.snake.head.armor = Snake.snake.head.armor + ARMOR
end

return Snake
