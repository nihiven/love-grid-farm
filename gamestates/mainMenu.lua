local menu = require 'menu'
local mainMenu = menu()

-- menu options
mainMenu:setFont(fonts.menu)

-- menu display items
mainMenu:setItems(
  {
    { 'New Game', function() gamestate.switch(gamestates.game) end },
    { 'Debug Menu', function() gamestate.switch(gamestates.debugMenu) end },
    { 'Quit', function() love.event.quit() end }
  }
)

-- menu key presses
mainMenu:addKeys(
  {
    escape = function() love.event.quit() end,
    f = function() log:write('f you too!') end
  }
)

return mainMenu