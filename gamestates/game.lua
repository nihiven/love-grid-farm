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

  -- canvas related
  _canvas = {
    data = nil,
    color = {0,0,0}
  },

  -- mouse related
  _mouse = {
    x = nil,
    y = nil,
    dx = nil,
    dy = nil,
    isTouch = nil
  },

  -- debug settings
  _debug = {
    font = fonts.debug,
    stats = nil,
    draw = true,
    padx = 10,
    pady = 25
  }
}

-- NEXT: what grid is the mouse in?


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
      "Draw Calls: %f\nTexture Memory: %.2f MB",
      self._debug.stats.drawcalls,
      self._debug.stats.texturememory / 1024 / 1024
    )
    local sheight = self._debug.font:getHeight(str)
    
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
end

function game:setMouse(x, y, dx, dy, istouch)
  -- offset mouse coords to be relative to the grid location
  self._mouseX = x - self._x
  self._mouseY = y - self._y

  -- just copy over
  self._mouseXD = dx
  self._mouseYD = dy
  self._istouch = istouch
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
  if (key == 'backspace') then
    if (self._previous == nil) then
      log:write('no previous state to switch to')
    else
      gamestate.switch(self._previous)
    end
  end

  if (key == 'escape') then
    gamestate.push(self._previous)
  end

  if (key == 's') then
    print(inspect(self._graphicsStats))
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