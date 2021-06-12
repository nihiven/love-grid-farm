local menu = {
  _VERSION = 'nihiven Menu v1.0.0',
  _DESCRIPTION = 'nihiven Menu Object',
  _URL = 'http://nvn.io',
  _LICENSE = 'MIT',
  _name = 'Default Menu',
  _selectedItem = 1,
  _items = {
    { 'Item 1', function() log:write('Default Item One') end },
    { 'Item 2', function() log:write('Default Item Two') end },
  },
  _keys = {
    escape = function() log:write('pressed escape') end
  }
}

function menu:draw()
  local x, y = 10, 10
  for key, value in pairs(self._items) do
    if (key == self._selectedItem) then
      love.graphics.push('all')
      love.graphics.setColor({1,0,0})
      love.graphics.print(value[1], fonts.menu, x, y)
      love.graphics.pop()
    else
      love.graphics.print(value[1], fonts.menu, x, y)
    end
    y = y + 25
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
  self._items[item][2]()
end

function menu:move(direction)
  local slot = self._selectedItem + direction

  if (slot < 1) then slot = #self._items end
  if (slot > #self._items) then slot = 1 end
  self._selectedItem = slot
end


return menu