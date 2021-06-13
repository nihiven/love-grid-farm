local menu = require 'menu'
local mainMenu = menu()

mainMenu:setFont(fonts.menu)

mainMenu:setItems(
  {
    { 'New Game', function() print('jeb is cool') end },
    { 'Debug Menu', function() gamestate.switch(gamestates.debugMenu) end }
  }
)

return mainMenu