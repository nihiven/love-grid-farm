--[[ mostly enums ]]
require 'system'
log = require 'log'

--[[ assets ]]
fonts = {}
fonts.menu = love.graphics.setNewFont('fonts/Squares Bold Free.otf', 64)
fonts.log = love.graphics.setNewFont('fonts/AndromedaTV.TTF', 24)
fonts.debug = love.graphics.setNewFont('fonts/DigitaldreamFatNarrow.ttf', 18)


--[[ game states ]]
gamestates = {}
gamestates.mainMenu = require 'gamestates.mainMenu' -- displayed at startup
gamestates.debugMenu = require 'gamestates.debugMenu' -- displayed from main menu
gamestates.game = require 'gamestates.game' -- let's play a game


--[[ Global Game Objects ]]
inspect = require 'inspect'
player = require 'player'
gamestate = require 'gamestate'
nvn = require 'nvn'


--[[ Love Callbacks ]]
function love.load()
	log:setfont(fonts.log)
	log:write('alright, alright, alright')

	gamestate.registerEvents()
  gamestate.switch(gamestates.mainMenu)
end

function love.update(dt)
end

function love.draw()
	log:draw()
end

function love.keypressed(key)
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

