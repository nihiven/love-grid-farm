local nvn = require 'nvn'
local player = require 'player'
local baton = require 'baton.baton'
local batontest = require 'baton.test'
local objects = {}

local input = baton.new {
	controls = {
		left = {'key:left', 'axis:leftx-', 'button:dpleft'},
		right = {'key:right', 'axis:leftx+', 'button:dpright'},
		up = {'key:up', 'axis:lefty-', 'button:dpup'},
		down = {'key:down', 'axis:lefty+', 'button:dpdown'},
		action = {'key:x', 'button:a', 'mouse:1'},
	},
	pairs = {
		move = {'left', 'right', 'up', 'down'}
	},
	joystick = love.joystick.getJoysticks()[1],
	deadzone = .33,
}

function love.load()
  -- set baton instance within batontest
  --batontest.input(baton)
end

function love.update(dt)
	input:update()
  batontest.update()
end

function love.draw()

end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	end
end

