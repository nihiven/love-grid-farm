require 'system'

local log = require 'log'
local inspect = require 'inspect'
local nvn = require 'nvn'
local player = require 'player'
local baton = require 'baton.baton'
--local batontest = require 'baton.test'


-- object list
local objects = {
	nvn,
	player,
	batontest,
	log
}

--[[
	loop through every object, calling func
--]] 
local function callfuncontable(objects, func, ...)
	for key, value in pairs(objects) do
		value[func](...)
	end
end

-- input mapping
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
	if (batontest ~= nil) then batontest:setbaton(input) end
	log:write('ok ok ok ')
	log:write('alright alright alright')
end

function love.update(dt)
	if (batontest ~= nil) then batontest:update(dt) end
end

function love.draw()
	if (batontest ~= nil) then batontest:draw() end
	log:draw()
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	end

	if key == 'enter' then
		print('try it out')
	end

	if key == 'k' then
		log:write('k')
	end
end

