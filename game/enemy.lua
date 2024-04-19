require("const")
Enemy = {}

Enemy.snake = {
  nums = 0,
  accelerate = 250,
  rot_speed = math.pi * 0.5,
  color = { 204 / 255, 0, 0 },

  snakes = {},
  add_snake = nil,
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
  self.snake.add_snake = coroutine.wrap(Enemy.add_snake)
  self.snake.snakes.name = "enemy"
end

function Enemy:move(dt, border, player, func_shoot)
  local turn_border = {
    height = border.height - MIN_DISTANCE,
    width = border.width - MIN_DISTANCE,
  }
  for _, snake in ipairs(self.snake.snakes) do
    local new_x = snake.head.info._x + dt * snake.head.speed * math.cos(snake.head.info.rot)
    local new_y = snake.head.info._y + dt * snake.head.speed * math.sin(snake.head.info.rot)

    ------ avoid collision ------
    if new_x - snake.head.info.ox * SIZE < MIN_DISTANCE or new_y - snake.head.info.oy * SIZE < MIN_DISTANCE then
      snake.head.info.rot = snake.head.info.rot + dt * self.snake.rot_speed
      goto skip_track
    end

    if
        new_x + snake.head.info.ox * SIZE >= turn_border.width
        or new_y + snake.head.info.oy * SIZE >= turn_border.height
    then
      snake.head.info.rot = snake.head.info.rot - dt * self.snake.rot_speed
      goto skip_track
    end

    ------ track ------
    Enemy:track_player(dt, Snake.snake, snake, func_shoot)
    ::skip_track::

    ------ if collision ------
    local dis = distance({ _x = new_x, _y = new_y }, player.head.info)

    if dis <= player.head.radius then
      snake.head.health = snake.head.health - (HARM * dt) * ((100 - snake.head.armor) / 100)
      player.head.health = player.head.health - (HARM * dt) * ((100 - player.head.armor) / 100)
      goto continue
    end
    for _, body in ipairs(player.body) do
      if distance({ _x = new_x, _y = new_y }, body.info) <= body.radius then
        snake.head.health = snake.head.health - (HARM * dt) * ((100 - snake.head.armor) / 100)
        body.health = body.health - (HARM * dt) * ((100 - body.armor) / 100)
        goto continue
      end
    end

    if
        new_x - snake.head.info.ox * SIZE >= 0
        and new_x + snake.head.info.ox * SIZE < border.width
        and new_y - snake.head.info.oy * SIZE >= 0
        and new_y + snake.head.info.oy * SIZE < border.height
    then
      snake.head.info._x = new_x
      snake.head.info._y = new_y
    end
    ::continue::
    local dangle = angle(snake.head.info, player.head.info)
    if dis <= 800 then
      if math.abs(snake.head.info.rot - dangle) <= math.pi / 6 then
        func_shoot(snake.head, "enemy")
      end
    end
    ------ body move ------
    --

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
        goto continue_end
      elseif distance(body.info, pre.info) <= 50 and body.speed >= SPEED_LOW then
        body.speed = body.speed - dt * self.snake.accelerate
        goto continue_end
      end

      if body.speed >= SPEED_NORMAL then
        body.speed = body.speed - dt * self.snake.accelerate
        goto continue_end
      else
        body.speed = body.speed + dt * self.snake.accelerate
        goto continue_end
      end
      ::continue_end::
    end
  end
end

function Enemy.add_snake(body_nums, border, func_health)
  ::restart::

  border = {
    height = border.height - MIN_DISTANCE * 2,
    width = border.width - MIN_DISTANCE * 2,
  }

  local x = math.random() * border.width + MIN_DISTANCE
  local y = math.random() * border.height + MIN_DISTANCE

  local snake = {}
  local head = {
    info = {
      _x = x,
      _y = y,
      rot = math.random() * 2 * math.pi,
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
  head = func_health(head, 100, ARMOR * (body_nums + 1))

  local bodys = {}
  for i = 1, body_nums, 1 do
    local body = {
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
    body = func_health(body, 100, 0)
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
  tail = func_health(tail, 100, 0)
  table.insert(bodys, tail)

  snake.head = head
  snake.bodys = bodys

  snake.color = Enemy.snake.color
  table.insert(Enemy.snake.snakes, snake)
  coroutine.yield()
  goto restart
end

function Enemy:track_player(dt, player, snake)
  local dis = distance(player.head.info, snake.head.info)
  local dangle = angle(snake.head.info, player.head.info)
  if dis <= 800 and dis >= 180 then
    if snake.head.info.rot < dangle then
      snake.head.info.rot = snake.head.info.rot + dt * self.snake.rot_speed
    else
      snake.head.info.rot = snake.head.info.rot - dt * self.snake.rot_speed
    end
  elseif dis < 180 then
    if snake.head.info.rot < -dangle then
      snake.head.info.rot = snake.head.info.rot + dt * self.snake.rot_speed
    else
      snake.head.info.rot = snake.head.info.rot - dt * self.snake.rot_speed
    end
  end
end

return Enemy
