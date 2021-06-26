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
