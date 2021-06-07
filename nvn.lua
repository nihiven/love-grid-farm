local nvn = {
  _VERSION = 'nvn v1.0.0',
  _DESCRIPTION = 'Master nihiven Library',
  _URL = 'http://nvn.io',
  _LICENSE = 'MIT'
}

-- private functions
local function privatefunction()
  return true
end


-- public functions
function nvn.load()
  osString = love.system.getOS()
  print(osString)
end

-- return module table
return nvn