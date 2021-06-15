local menu = require 'menu'
local mainMenu = menu()

mainMenu:setFont(fonts.menu)

mainMenu:setItems(
  {
    { 'New Game', function() gamestate.switch(gamestates.game) end },
    { 'Debug Menu', function() gamestate.switch(gamestates.debugMenu) end }
  }
)

mainMenu:setKeys(
  escape=function() love.event.quit() end,
  backspace=print('eat shit')
)

return mainMenu