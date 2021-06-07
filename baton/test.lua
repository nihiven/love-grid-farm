local batontest = {
  _VERSION = 'baton test v1.0.0',
  _DESCRIPTION = 'baton Test Library',
  _URL = 'http://nvn.io',
  _LICENSE = 'MIT',
  intput = nil
}

function batontest.input(input)
  assert(input, "Missing argument: baton instance to use for testing")
	assert(input ~= batontest, "Can't call input with colon operator")
  batontest.input = input
end

function batontest.update(dt)
  assert(batontest.input, "Set .input to an instance of baton before calling update()")
  batontest.input.update(dt)
end

function batontest.draw()
  love.graphics.setColor(1, 1, 1)
	love.graphics.print('Current active device: ' .. tostring(input:getActiveDevice()))
	love.graphics.print('Average update time (us): ' .. math.floor(updateTime/updates*1000000), 0, 16)
	love.graphics.print('Memory usage (kb): ' .. math.floor(collectgarbage 'count'), 0, 32)

	love.graphics.push()
	love.graphics.translate(400, 300)

	love.graphics.setColor(.25, .25, .25, pairDisplayAlpha)
	love.graphics.circle('fill', 0, 0, pairDisplayRadius)

	love.graphics.setColor(1, 1, 1)
	love.graphics.circle('line', 0, 0, pairDisplayRadius)

	local r = pairDisplayRadius * input.config.deadzone
	if input.config.squareDeadzone then
		love.graphics.rectangle('line', -r, -r, r*2, r*2)
	else
		love.graphics.circle('line', 0, 0, r)
	end

	love.graphics.setColor(.5, .5, .5)
	local x, y = input:getRaw 'move'
	love.graphics.circle('fill', x*pairDisplayRadius, y*pairDisplayRadius, 4)
	love.graphics.setColor(1, 1, 1)
	x, y = input:get 'move'
	love.graphics.circle('fill', x*pairDisplayRadius, y*pairDisplayRadius, 4)

	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle('line', -50, 150, 100, 100)
	love.graphics.setColor(1, 1, 1, buttonDisplayAlpha)
	love.graphics.rectangle('fill', -50, 150, 100, 100)

	love.graphics.pop()
end


return batontest