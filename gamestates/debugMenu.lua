local menu = require 'menu'
local debugMenu = menu()

debugMenu:setItems(
  {
    { 'Test', function() print('jeb is cool') end },
    { 'Show Me God', showMeGod }
  }
)

debugMenu:setKeys(
  'escape', 
  function() gamestate.switch(gamestates.mainMenu) end
)


return debugMenu
