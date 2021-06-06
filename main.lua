local nvn = require 'nvn'
local player = require 'player'

function love.load()
  nvn.load()
end

function love.draw(dt)
  love.graphics.print("Eat my ass", 10, 10)
end

