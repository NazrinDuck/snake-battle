Snake = {}

SIZE = 0.2

SPEED_LOW = 100
SPEED_NORMAL = 200
SPEED_HIGH = 280

Snake.info = {
  body_nums = 0,
  accelerate = 250,
  rot_speed = math.pi * 0.5,
}

Snake.head = {
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
  color = { 0, 153 / 255, 76 / 255 },
  radius = 0,
  speed = 250,
  image = love.graphics.newImage("images/head.png"),
}

Snake.body = {}

Snake.tail = {
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
  speed = 250,
  image = love.graphics.newImage("images/tail.png"),
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

function Snake:init(_x, _y)
  self.head.info._x = _x
  self.head.info._y = _y
  self.head.info.ox = self.head.image:getWidth() / 2
  self.head.info.oy = self.head.image:getHeight() / 2
  self.head.radius = (self.head.info.ox + self.head.info.oy) * SIZE / 2

  for i = 1, 10, 1 do
    local body = {
      info = {
        _x = _x - 30 * i,
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

    table.insert(self.body, body)
  end

  self.tail.info._x = _x - 330
  self.tail.info._y = _y
  self.tail.info.ox = self.tail.image:getWidth() / 2
  self.tail.info.oy = self.tail.image:getHeight() / 2
  self.tail.radius = (self.tail.info.ox + self.tail.info.oy) * SIZE / 2
  table.insert(self.body, self.tail)
end

function Snake:move(dt, border)
  border = border or {
    height = 0,
    width = 0,
  }
  local new_x = self.head.info._x + dt * self.head.speed * math.cos(self.head.info.rot)
  local new_y = self.head.info._y + dt * self.head.speed * math.sin(self.head.info.rot)

  if
      new_x - self.head.info.ox * SIZE >= 0
      and new_x + self.head.info.ox * SIZE < border.width
      and new_y - self.head.info.oy * SIZE >= 0
      and new_y + self.head.info.oy * SIZE < border.height
  then
    self.head.info._x = new_x
    self.head.info._y = new_y
  end

  self:keyboard_reaction(dt)
  Snake.info.body_nums = #self.body
  self:move_body(dt)
end

function Snake:move_body(dt)
  for i, body in ipairs(self.body) do
    local pre = {}
    if i == 1 then
      pre = self.head
    else
      pre = self.body[i - 1]
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
  if love.keyboard.isDown("up") and self.head.speed <= SPEED_HIGH then
    self.head.speed = self.head.speed + dt * self.info.accelerate
  elseif self.head.speed >= SPEED_NORMAL then
    self.head.speed = self.head.speed - dt * self.info.accelerate
  end

  if love.keyboard.isDown("down") and self.head.speed >= SPEED_LOW then
    self.head.speed = self.head.speed - dt * self.info.accelerate
  elseif self.head.speed <= SPEED_NORMAL then
    self.head.speed = self.head.speed + dt * self.info.accelerate
  end

  if love.keyboard.isDown("left") then
    self.head.info.rot = self.head.info.rot - self.info.rot_speed * dt
  end
  --self.head.info._x >= 0 + self.head.info.ox * self.head.info.sx
  if love.keyboard.isDown("right") then
    self.head.info.rot = self.head.info.rot + self.info.rot_speed * dt
  end
end

function Snake:draw()
  love.graphics.setColor(self.head.color)
  for _, body in ipairs(self.body) do
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

    --[[
    local dangle = angle(body.info, self.head.info)
    local d = distance(body.info, self.head.info)
    love.graphics.print("dangle: " .. tostring(dangle), 0, 100 + 25 * i)
    love.graphics.print("d: " .. tostring(d), 0, 125 + 25 * i)
    love.graphics.print("dx: " .. tostring(body.info._x - self.head.info._x), 0, 150 + 25 * i)
    --]]
  end
end

return Snake
