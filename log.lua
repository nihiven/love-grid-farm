--[[
  Logging System
]]
local log = {
  _VERSION = 'nihiven Log v1.0.0',
  _DESCRIPTION = 'nihiven Log Library',
  _URL = 'http://nvn.io',
  _LICENSE = 'MIT',
  _x = 5, -- start messages at this x coord
  _y = 600, -- start messages at this y coord
  _print = true, -- print messages to the console
  _draw = true, -- draw the messages to the screen
  _font = nil,
  _color = {0, 255, 0, 1}, -- color to draw messages
  _messages = {}
}

function log:write(message)
  if (self._print) then print(message) end
  table.insert(self._messages, message)
end

function log:draw()
  if (self._draw == false) then 
    return
  end

  if (self._color ~= nil) then 
    love.graphics.setColor(self._color)
  end

  local y = (#self._messages * 15) + self._y
  for key, value in pairs(self._messages) do
    if (self._font == nil) then
      love.graphics.print(value, self._x, y)
    else
      love.graphics.print(value, self._font, self._x, y)
    end
    y = y - 15 
  end

end

function log:toggledraw()
  self._draw =  not self._draw
end

function log:setfont(font)
  self._font = font
end

return log