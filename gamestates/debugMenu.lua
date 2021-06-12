local debugMenu = require 'menu'

function debugMenu:init()

  self._items = {
    { 'Test', function() print('jeb is cool') end },
    { 'Show Me God', showMeGod },
  }

  self._keys['escape'] = function() gamestate.switch(gamestates.mainMenu) end
end

return debugMenu
