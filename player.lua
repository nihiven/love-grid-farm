local player = {
  _VERSION = 'player module v1.0.0',
  _DESCRIPTION = 'Grid Farm Player Module',
  _URL = 'http://nvn.io',
  _LICENSE = 'MIT'
}

-- private functions
local privatefunction()
  return true
end


-- public functions
function player.load()
  osString = love.system.getOS()
  print(osString)
end

-- return module table
return player