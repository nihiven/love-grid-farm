local Object = require 'classic'
local baseMenu = Object:extend()

function baseMenu:init()
  self:setDefaults()
end

function baseMenu:setDefaults()
  self.name = 'Menu'
  self.selectedItem = 1
  self.items = {
    { 'Item 1', function() log.debug('itemOne()') end },
    { 'Item 2', function() log.debug('itemTwo()') end },
  }
  self.keys = { }
  self.keys['escape'] = function() log.debug('pressed escape') end
end

function baseMenu:enter()
  log:write('enter()')
end

function baseMenu:leave()
  log:write('leave()')
end

function baseMenu:draw()
  local x, y = 10, 10
  for key, value in pairs(self.items) do
    if (key == self.selectedItem) then
      love.graphics.push("all")
      love.graphics.setColor({1,0,0})
      love.graphics.print(value[1], fonts.mainmenu, x, y)
      love.graphics.pop()
    else
      love.graphics.print(value[1], fonts.mainmenu, x, y)
    end
    y = y + 25
  end
end

function baseMenu:keypressed(key, code)
  if (self.keys[key] ~= nil) then
    self.keys[key]()
  end

  if (key == 'return') then
    self:selectItem(self.selectedItem)
  end

  if (key == 'up') then
    self:move(-1)
  end

  if (key == 'down') then
    self:move(1)
  end
end

function baseMenu:selectItem(item)
  log:write('selectItem()')
  self.items[item][2]()
end

function baseMenu:move(direction)
  local slot = self.selectedItem + direction

  if (slot < 1) then slot = #self.items end
  if (slot > #self.items) then slot = 1 end
  self.selectedItem = slot
end

return baseMenu
