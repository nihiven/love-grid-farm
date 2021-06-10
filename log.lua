--[[
  Logging System
]]
local log = {
  _VERSION = 'nihiven Log v1.0.0',
  _DESCRIPTION = 'nihiven Log Library',
  _URL = 'http://nvn.io',
  _LICENSE = 'MIT',
  _x = 5, -- start messages at this x coord
  _y = 5, -- start messages at this y coord
  _print = true, -- print messages to the console
  _draw = true, -- draw the messages to the screen
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

  love.graphics.setColor(self._color)

  local y = (#self._messages * 15)
  for key, value in pairs(self._messages) do
    love.graphics.print(value, self._x, y)
    y = y - 15 
  end

end

return log