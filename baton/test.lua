local batontest = {
  _VERSION = 'baton test v1.0.0',
  _DESCRIPTION = 'baton Test Library',
  _URL = 'http://nvn.io',
  _LICENSE = 'MIT',
  batoninst = nil,
}

local pairDisplayAlpha = 0
local pairDisplayTargetAlpha = 0
local pairDisplayRadius = 128
local buttonDisplayAlpha = 0
local buttonDisplayTargetAlpha = 0

local updates = 0
local updateTime = 0

function batontest:setbaton(baton)
  assert(baton, "Missing argument setbaton(): baton instance to use for testing")
	self.batoninst = baton
end

function batontest:update(dt)
  assert(self.batoninst ~= nil, "Baton instance not set: use setbaton() to specify a baton instance before calling update()")

	local time = love.timer.getTime()

	self.batoninst:update()

	pairDisplayTargetAlpha = self.batoninst:pressed 'move' and 1
	                      or self.batoninst:released 'move' and 1
	                      or self.batoninst:down 'move' and .5
	                      or 0
	if pairDisplayAlpha > pairDisplayTargetAlpha then
		pairDisplayAlpha = pairDisplayAlpha - 4 * dt
	end
	if pairDisplayAlpha < pairDisplayTargetAlpha then
		pairDisplayAlpha = pairDisplayTargetAlpha
	end

	buttonDisplayTargetAlpha = self.batoninst:pressed 'action' and 1
	                        or self.batoninst:released 'action' and 1
	                        or self.batoninst:down 'action' and .5
	                        or 0
	if buttonDisplayAlpha > buttonDisplayTargetAlpha then
		buttonDisplayAlpha = buttonDisplayAlpha - 4 * dt
	end
	if buttonDisplayAlpha < buttonDisplayTargetAlpha then
		buttonDisplayAlpha = buttonDisplayTargetAlpha
	end

	updateTime = updateTime + (love.timer.getTime() - time)
	updates = updates + 1
end

function batontest:draw()
  love.graphics.setColor(1, 1, 1)
	love.graphics.print('Current active device: ' .. tostring(self.batoninst:getActiveDevice()))
	love.graphics.print('Average update time (us): ' .. math.floor(updateTime/updates*1000000), 0, 16)
	love.graphics.print('Memory usage (kb): ' .. math.floor(collectgarbage 'count'), 0, 32)

	love.graphics.push()
	love.graphics.translate(400, 300)

	love.graphics.setColor(.25, .25, .25, pairDisplayAlpha)
	love.graphics.circle('fill', 0, 0, pairDisplayRadius)

	love.graphics.setColor(1, 1, 1)
	love.graphics.circle('line', 0, 0, pairDisplayRadius)

	local r = pairDisplayRadius * self.batoninst.config.deadzone
	if self.batoninst.config.squareDeadzone then
		love.graphics.rectangle('line', -r, -r, r*2, r*2)
	else
		love.graphics.circle('line', 0, 0, r)
	end

	love.graphics.setColor(.5, .5, .5)
	local x, y = self.batoninst:getRaw 'move'
	love.graphics.circle('fill', x*pairDisplayRadius, y*pairDisplayRadius, 4)
	love.graphics.setColor(1, 1, 1)
	x, y = self.batoninst:get 'move'
	love.graphics.circle('fill', x*pairDisplayRadius, y*pairDisplayRadius, 4)

	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle('line', -50, 150, 100, 100)
	love.graphics.setColor(1, 1, 1, buttonDisplayAlpha)
	love.graphics.rectangle('fill', -50, 150, 100, 100)

	love.graphics.pop()
end


return batontest