local classic = require 'classic'
local menu = classic:extend()

function menu:new()
  self._VERSION = 'nihiven Menu v1.0.0'
  self._DESCRIPTION = 'nihiven Menu Object'
  self._URL = 'http://nvn.io'
  self._LICENSE = 'MIT'
  self._name = 'Default Menu'

  -- internal function
  self._selectedItem = 1
  self._x = 5 -- start menu at this x coord
  self._y = 10 -- start menu at this y coord
  self._selectedColor = {1,0,0}
  self._normalColor = {1,1,1}
  self._font = nil
  self._items = {
    { 'Item 1', function() log:write('Default Item One') end },
    { 'Item 2', function() log:write('Default Item Two') end }
  }
  self._keys = {
    escape = function() log:write('pressed escape') end
  }

  -- options 
  self._lineSpacing = love.graphics.getFont().getHeight(love.graphics.getFont())
  self._centered = false -- if true, center menu on screen, ignore _x and _y values
end

function menu:draw()
  local x, y = self._x, self._y
  for key, value in pairs(self._items) do
    if (key == self._selectedItem) then
      love.graphics.setColor(self._selectedColor)
    else
      love.graphics.setColor(self._normalColor)
    end

    if (self._font ~= nil) then
      love.graphics.print(value[1], self._font, x, y)
    else
      love.graphics.print(value[1], x, y)
    end

    y = y + self._lineSpacing
  end
end


function menu:keypressed(key, code)
  if (self._keys[key] ~= nil) then
    self._keys[key]()
  end

  if (key == 'return') then
    self:selectItem(self._selectedItem)
  end

  if (key == 'up') then
    self:move(-1)
  end

  if (key == 'down') then
    self:move(1)
  end
end

function menu:selectItem(item)
  log:write('selectItem()')
  local action = self._items[item][2]
  if (action == nil) then
    log:write('No action for menu item: ' .. item)
  else
    action()
  end

end

function menu:move(direction)
  local slot = self._selectedItem + direction

  if (slot < 1) then slot = #self._items end
  if (slot > #self._items) then slot = 1 end
  self._selectedItem = slot
end

function menu:setCoords(x, y)
  self._x = x
  self._y = y
end

function menu:setLineSpacing(height)
  self._lineSpacing = height
end

function menu:setItems(items)
  self._items = items
end

function menu:addItem(item)
  table.append(self._items, item)
end

function menu:setKeys(keys)
  self._keys = keys
end

function menu:setKey(key, value)
  self._keys[key] = value
end

function menu:addKey(key, value)
  table.append(self._keys, { key, value })
end

function menu:setFont(font)
  self._font = font
  self._lineSpacing = font.getHeight(self._font)
end

return menu