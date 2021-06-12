local Object = require 'classic'
local mainMenu = Object:extend()

function mainMenu:init()
  self.name = 'Main Menu'
  self.selectedItem = 1
  self.items = {
    { 'New Game', self.newGame },
    { 'Debug', function() gamestate.switch(gamestates.debugmenu) end },
    { 'Quit', self.quitGame },
  }
end

function mainMenu:enter()
  log:write('enter()')
end

function mainMenu:leave()
  log:write('leave()')
end

function mainMenu:draw()
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

function mainMenu:keypressed(key, code)
  if key == "escape" then
    self:quitGame()
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

function mainMenu:selectItem(item)
  log:write('selectItem()')
  self.items[item][2]()
end

function mainMenu:move(direction)
  local slot = self.selectedItem + direction

  if (slot < 1) then slot = #self.items end
  if (slot > #self.items) then slot = 1 end
  self.selectedItem = slot
end

function mainMenu:newGame()
  log:write('newGame()')
  gamestate.switch(gamestates.newGame)
end

function mainMenu:quitGame()
  log:write('quitGame()')
  gamestate.quit()
end

return mainMenu()
