require("const")
Health = {
  mesh = nil,
  height = 15,
  width = 50,
  background_color = { 0.3, 0.3, 0.3, 0.4 },
}
MAX_HEALTH = 100

function Health:init()
  local length = self.height
  local vertices_health_bar = {
    { length / 2,  length / 2 - 80,  0, 0, 1, 1, 1 },
    { length / 2,  -length / 2 - 80, 1, 0, 1, 1, 1 },
    { -length / 2, -length / 2 - 80, 1, 0, 1, 1, 1 },
    { -length / 2, length / 2 - 80,  0, 0, 1, 1, 1 },
  }
  self.mesh = love.graphics.newMesh(vertices_health_bar, "fan")
end

function Health.generate_health(object, health, armor)
  if object == nil then
    return {}
  end
  object.health = health
  object.armor = armor
  object.health_bar = {
    sx = 1,
    sy = 1,
  }

  return object
end

function Health:update(objects)
  for _, object in ipairs(objects) do
    if object.name == "player" then
      object.head.health_bar.sx = (self.width / self.height) * (object.head.health / MAX_HEALTH)
      for i, body in ipairs(object.body) do
        if body.health <= 0 then
          object.head.armor = object.head.armor - ARMOR
          table.remove(object.body, i)
        end
        body.health_bar.sx = (self.width / self.height) * (body.health / MAX_HEALTH)
      end
      goto continue
    end

    if object.name == "enemy" then
      for i, snake in ipairs(object) do
        snake.head.health_bar.sx = (self.width / self.height) * (snake.head.health / MAX_HEALTH)
        if snake.head.health <= 0 then
          table.remove(object, i)
        end
        for j, body in ipairs(snake.bodys) do
          body.health_bar.sx = (self.width / self.height) * (body.health / MAX_HEALTH)
          if body.health <= 0 then
            snake.head.armor = snake.head.armor - ARMOR
            table.remove(snake.bodys, j)
          end
        end
      end
      goto continue
    end
    ::continue::
  end
end

function Health:draw_health(objects)
  for _, object in ipairs(objects) do
    if object.name == "player" then
      love.graphics.setColor(self.background_color)
      love.graphics.draw(
        self.mesh,
        object.head.info._x,
        object.head.info._y,
        0,
        self.width / self.height,
        object.head.health_bar.sy
      )

      love.graphics.setColor(object.color)
      love.graphics.draw(
        self.mesh,
        object.head.info._x,
        object.head.info._y,
        0,
        object.head.health_bar.sx,
        object.head.health_bar.sy
      )

      for _, body in ipairs(object.body) do
        love.graphics.setColor(self.background_color)
        love.graphics.draw(
          self.mesh,
          body.info._x,
          body.info._y,
          0,
          self.width / self.height,
          body.health_bar.sy
        )

        love.graphics.setColor(object.color)
        love.graphics.draw(self.mesh, body.info._x, body.info._y, 0, body.health_bar.sx, body.health_bar.sy)
      end
      goto continue
    end

    if object.name == "enemy" then
      for _, snake in ipairs(object) do
        love.graphics.setColor(self.background_color)
        love.graphics.draw(
          self.mesh,
          snake.head.info._x,
          snake.head.info._y,
          0,
          self.width / self.height,
          snake.head.health_bar.sy
        )
        love.graphics.setColor(snake.color)
        love.graphics.draw(
          self.mesh,
          snake.head.info._x,
          snake.head.info._y,
          0,
          snake.head.health_bar.sx,
          snake.head.health_bar.sy
        )
        for _, body in ipairs(snake.bodys) do
          love.graphics.setColor(self.background_color)
          love.graphics.draw(
            self.mesh,
            body.info._x,
            body.info._y,
            0,
            self.width / self.height,
            body.health_bar.sy
          )
          love.graphics.setColor(snake.color)
          love.graphics.draw(self.mesh, body.info._x, body.info._y, 0, body.health_bar.sx, body.health_bar.sy)
        end
      end
      goto continue
    end
    ::continue::
  end
end

return Health
