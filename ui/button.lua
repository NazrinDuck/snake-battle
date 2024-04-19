Button = {}
Button.buttons = {}

local function is_hover(object)
  local x, y = love.mouse.getPosition()
  if
      x <= object.info._x + object.info.ox * object.info.sx
      and x >= object.info._x - object.info.ox * object.info.sx
      and y <= object.info._y + object.info.oy * object.info.sy
      and y >= object.info._y - object.info.oy * object.info.sy
  then
    return true
  end
  return false
end
function Button:set_button(text, info, is_button, func)
  local font_height = love.graphics.getFont():getHeight()
  local font_width = love.graphics.getFont():getWidth(text)
  local button = {
    info = {
      _x = info._x,
      _y = info._y,
      sx = info.sx,
      sy = info.sy,
      ox = font_width / 2,
      oy = font_height / 2,
    },
    text = text,
    is_hover = false,
    is_button = is_button,
    func = func or nil
  }

  table.insert(Button.buttons, button)
end

function Button:draw()
  for _, button in ipairs(self.buttons) do
    if button.is_hover then
      love.graphics.setColor(0.8, 0.8, 0.8, 1)
    else
      love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.print(
      button.text,
      button.info._x,
      button.info._y,
      0,
      button.info.sx,
      button.info.sy,
      button.info.ox,
      button.info.oy
    )
  end
end

function Button:clear()
  for i = 1, #self.buttons, 1 do
    --table.remove(self.buttons, i)
  end
end

function Button:check_press()
  for _, button in ipairs(self.buttons) do
    if is_hover(button) and button.is_button then
      button.is_hover = true
      if love.mouse.isDown(1) then
        button.func()
      end
      goto continue
    end
    button.is_hover = false
    ::continue::
  end
end

return Button
