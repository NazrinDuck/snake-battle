Camera = {}

Camera._x = 0
Camera._y = 0

Camera.scala_x = 1
Camera.scala_y = 1
Camera.rot = 0

---camera set---
function Camera:set()
  love.graphics.push()
  love.graphics.rotate(-self.rot)
  love.graphics.scale(1 / self.scala_x, 1 / self.scala_y)
  love.graphics.translate(-self._x, -self._y)
end

function Camera:unset()
  love.graphics.pop()
end

function Camera:set_x(val)
  self._x = val
end

function Camera:set_y(val)
  self._y = val
end

function Camera:set_offset(x, y)
  if x then
    self:set_x(x)
  end
  if y then
    self:set_y(y)
  end
end

return Camera
