Snake = {}

SIZE = 0.2

SPEED_LOW = 125
SPEED_NORMAL = 225
SPEED_HIGH = 280

Snake.info = {
  body_nums = 1,
  accelerate = 250,
  rot_speed = math.pi * 0.5,
  color = { 0, 153 / 255, 76 / 255 },
}

Snake.snake = {}

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
  color = Snake.info.color,
  radius = 0,
  speed = SPEED_NORMAL,
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
  speed = SPEED_NORMAL,
  image = love.graphics.newImage("images/tail.png"),
}

Snake.bullet = {
  bullets = {},
  mesh = nil,
  speed = 150,
  radius = 12,
  fly_time = 3,
  shoot_gap = 1.5,
  timer = 0,
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

  table.insert(self.body, body)

  self.tail.info._x = _x - 60
  self.tail.info._y = _y
  self.tail.info.ox = self.tail.image:getWidth() / 2
  self.tail.info.oy = self.tail.image:getHeight() / 2
  self.tail.radius = (self.tail.info.ox + self.tail.info.oy) * SIZE / 2
  table.insert(self.body, self.tail)

  self:init_mesh()
end

function Snake:init_mesh()
  local segments = 60
  local vertices = {}

  table.insert(vertices, { 0, 0, 0.5, 0.5, 1, 1, 1, 0.6 })

  for i = 0, segments do
    local a = (i / segments) * math.pi * 2

    local x = math.cos(a)
    local y = math.sin(a)

    local u = (x + 1) * 0.5
    local v = (y + 1) * 0.5
    table.insert(vertices, { x, y, u, v })
  end
  self.bullet.mesh = love.graphics.newMesh(vertices, "fan")
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
  self:shoot(dt)
  self:move_body(dt)
  self:move_bullet(dt)
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
  if love.keyboard.isDown("right") then
    self.head.info.rot = self.head.info.rot + self.info.rot_speed * dt
  end
end

function Snake:draw()
  love.graphics.setColor(self.info.color)
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
  end
  self:draw_bullet()
end

function Snake:add_body()
  local index = #self.body - 1
  local new_x = self.body[index].info._x
  local new_y = self.body[index].info._y
  local new_rot = self.body[index].info.rot

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

  table.insert(self.body, index, body)

  Snake.info.body_nums = #self.body
end

----- shoot start -----

function Snake:shoot(dt)
  if self.bullet.timer < self.bullet.shoot_gap then
    self.bullet.timer = self.bullet.timer + dt
    return
  end

  if love.keyboard.isDown("z") and self.bullet.timer >= self.bullet.shoot_gap then
    self.bullet.timer = 0
    local bullet = {
      info = {
        _x = self.head.info._x,
        _y = self.head.info._y,
        rot = self.head.info.rot,
      },
      speed = self.bullet.speed + self.head.speed,
      color = self.info.color,
      timer = 0,
    }
    table.insert(self.bullet.bullets, bullet)
  end
end

function Snake:move_bullet(dt)
  for i, bullet in ipairs(self.bullet.bullets) do
    local rot = bullet.info.rot
    bullet.info._x = bullet.info._x + bullet.speed * dt * math.cos(rot)
    bullet.info._y = bullet.info._y + bullet.speed * dt * math.sin(rot)
    bullet.timer = bullet.timer + dt
    if bullet.timer > self.bullet.fly_time then
      table.remove(self.bullet.bullets, i)
    end
  end
end

function Snake:draw_bullet()
  for _, bullet in ipairs(self.bullet.bullets) do
    love.graphics.setColor(bullet.color)
    love.graphics.draw(
      self.bullet.mesh,
      bullet.info._x,
      bullet.info._y,
      bullet.info.rot,
      self.bullet.radius,
      self.bullet.radius
    )
  end
end

----- shoot end -----

return Snake
