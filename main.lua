--[[ mostly enums ]]
require 'system'
log = require 'log'

--[[ assets ]]
fonts = {}
fonts.menu = love.graphics.setNewFont('fonts/AndromedaTV.TTF', 24)
fonts.log = love.graphics.setNewFont('fonts/AndromedaTV.TTF', 24)


--[[ game states ]]
gamestates = {}
gamestates.mainMenu = require 'gamestates.mainMenu'
gamestates.debugMenu = require 'gamestates.debugMenu'


--[[ Game Objects ]]
inspect = require 'inspect'
local nvn = require 'nvn'
local baton = require 'baton.baton'
player = require 'player'
gamestate = require 'gamestate'
--local batontest = require 'baton.test'


--[[ objects that have callbacks ]]
local objects = {
	nvn,
	player,
	batontest,
	log
}


--[[ loop through every object, calling the func parameter ]] 
local function callfuncontable(objects, func, ...)
	for key, value in pairs(objects) do
		value[func](...)
	end
end


--[[ input mapping ]]
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


--[[ Love Callbacks ]]
function love.load()
  -- set baton instance within batontest
	if (batontest ~= nil) then batontest:setbaton(input) end

	log:setfont(fonts.log)
	log:write('ok ok ok ')
	log:write('alright, alright, alright. ooooohhhh')

	gamestate.registerEvents()
  gamestate.switch(gamestates.mainMenu)
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

	if key == 'l' then
		log:toggledraw()
	end
end

