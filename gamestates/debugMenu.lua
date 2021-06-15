local inspect = require 'inspect'
local menu = require 'menu'
local debugMenu = menu()

-- replace existing menu items with this cool stuff
debugMenu:setItems(
  {
    { 'Test', function() print('jeb is cool') end },
    { 'Show Me God', showMeGod }
  }
)

debugMenu:addItem('Print Menu Object', function() print(inspect(debugMenu)) end)

debugMenu:setKeys(
  'escape', 
  function() gamestate.switch(gamestates.mainMenu) end
)


return debugMenu
