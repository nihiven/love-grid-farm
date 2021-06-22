local game = {
  -- gamestate related
  _previous = nil,

  -- farming related
  _plot = {
    -- farms are ALWAYS square
    count = 10, -- so this is 5^2
    width = 50,
    height = 50,
    color = {0, 1, 1},
    x = 10,
    y = 10
  },

  -- the active plot
  _active = {
    x = nil,
    y = nil,
    color = {1,0,1}
  },

  -- canvas related
  _canvas = {
    data = nil,
    color = {0,0,0}
  },

  -- mouse related
  _mouse = {
    x = 0,
    y = 0,
    dx = 0,
    dy = 0,
    isTouch = false
  },

  -- debug settings
  _debug = {
    font = fonts.debug,
    stats = nil,
    draw = true,
    padx = 10,
    pady = 65
  }
}

-- NEXT: confine highlight to grid
-- NEXT: click every time the active plot changes
-- NEXT: arrows change active plot



--- HELPER FUNCTIONS ----
function _log(message)
  -- check for the log object, print otherwise
  if (log) then
    log:write(message)
  else
    print(message)
  end
end

function game:drawStats()
  -- stats are updated at the end of game:draw()
  local wwidth, wheight = love.graphics.getWidth(), love.graphics.getHeight()

  if (self._debug.draw and self._debug.stats ~= nil) then
    local str = string.format(
      "Draw Calls: %i\nTexture Memory: %.2f MB\nMouse x:%i | y:%i\nPlot: %i,%i",
      self._debug.stats.drawcalls,
      self._debug.stats.texturememory / 1024 / 1024,
      self._mouse.x,
      self._mouse.y,
      self._active.x and self._active.x or -1,
      self._active.y and self._active.y or -1
    )
    local sheight = self._debug.font:getHeight(str)

    love.graphics.setColor({0.7, 0.7, 0.7})
    love.graphics.print(str, self._debug.padx, wheight - sheight - self._debug.pady)
  end
end


---- GAME FUNCTIONS ----

-- Draw the grid to a canvas, then reuse the canvas instead of redrawing the grid.
function game:drawPlots(refreshCanvas)
  if (self._canvas.data == nil or refreshCanvas) then
    print('refreshing canvas...')

    -- create canvas
    local width = self._plot.width * self._plot.count
    local height = self._plot.height * self._plot.count
    self._canvas.data = love.graphics.newCanvas(width, height)

    -- setup canvas
    love.graphics.setCanvas(self._canvas.data)
    love.graphics.setColor(self._plot.color)
    love.graphics.clear(self._canvas.color)

    -- draw grid
    for row=0,self._plot.count-1,1 do
      -- loop for columns
      for col=0,self._plot.count-1,1 do
        local x = (col * self._plot.width)
        local y = (row * self._plot.height)
        
        love.graphics.rectangle('line', x, y, self._plot.width, self._plot.height)
      end
    end

    -- return to main canvas
    love.graphics.setCanvas()
  end

  love.graphics.setColor(1, 1, 1, 1) -- must reset colors per docs
  love.graphics.setBlendMode('alpha', 'premultiplied') -- use premult mode due to precalc alpha values
  love.graphics.draw(self._canvas.data, self._plot.x, self._plot.y)
  love.graphics.setBlendMode("alpha") -- return to default blend mode

  -- draw active plot
  if (self._active.x) then
    local ax = self._active.x * self._plot.width + self._plot.x
    local ay = self._active.y * self._plot.height + self._plot.y
    love.graphics.setColor(self._active.color)
    love.graphics.rectangle('line', ax, ay, self._plot.width, self._plot.height)
  end
end

function game:setMouse(x, y, dx, dy, istouch)
  -- offset mouse coords to be relative to the grid location
  self._mouse.x = x - self._plot.x
  self._mouse.y = y - self._plot.y

  -- just copy over
  self._mouse.dx = dx
  self._mouse.dy = dy
  self._mouse.istouch = istouch

  self._active.x, self._active.y = self:getPlot(self._mouse.x, self._mouse.y)

  -- 
end

function game:getPlot(x, y)
  return math.floor(x / self._plot.width), math.floor(y / self._plot.height)
end

---- LOVE CALLBACKS ----
function game:update(dt)
end

function game:mousemoved(x, y, dx, dy, istouch)
  self:setMouse(x, y, dx, dy, istouch)
end

function game:mousepressed(x, y, button, istouch, presses)
  print(x, y, button, istouch, presses)
end

function game:keypressed(key)
  -- experimental key map
  local keys = {
    s = function() print(inspect(self._graphicsStats)) end,
    u = function() prinspect(self._active) end,
    x = function() print('jeb hit x') end,

    -- REVIEW: menus need some work
    escape = function() gamestate.push(self._previous) end
  }

  if (keys[key]) then
    keys[key]()
  end

end

function game:draw()
  self:drawPlots()
  self:drawStats()

  -- should be last
  self._debug.stats = love.graphics.getStats()
end


---- GAMESTATE CALLBACKS ----
 -- init is called only once when the gamestate is first loaded
function game:init()
  print('init game')
  game:drawPlots{refreshCanvas=true} -- force canvas refresh
end

-- enter is called every time the gamestate is loaded
function game:enter(previous)
  self._previous = previous
end

return game