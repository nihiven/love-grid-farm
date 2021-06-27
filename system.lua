inspect = require 'inspect'

function prinspect(...)
	print(inspect(...))
end

--[[ loop through every object, calling the func parameter ]] 
local function callfuncontable(objects, func, ...)
	for key, value in pairs(objects) do
		value[func](...)
	end
end

-- Clamps a value to a certain range.
-- @param min - The minimum value.
-- @param val - The value to clamp.
-- @param max - The maximum value.
function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end