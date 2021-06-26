--- HELPER FUNCTIONS ----
function _log(message)
  -- check for the log object, print otherwise
  if (log) then
    log:write(message)
  else
    print(message)
  end
end

function rgbtolove(r, g, b, a)
  return {(r or 0)/255, (g or 0)/255, (b or 0)/255, (a or 1)}
end


local game = {
  -- gamestate related
  _previous = nil,

  -- farming related
  _plot = {
    -- farms are ALWAYS square
    count = 10, -- so this is 5^2
    width = 50,
    height = 50,
    color = {
      default = rgbtolove(100, 188, 216),
      planted = rgbtolove(38, 148, 16),
      watered = rgbtolove(255, 167, 5, 0.5),
      plowed = rgbtolove(204, 140, 22),
      seed = rgbtolove(52, 16, 59),
      fertilized = rgbtolove(25, 213, 227),
    },
    x = 10,
    y = 10
  },

  -- plot data
  _plots = {
    -- plot state goes in here
    -- set by buildPlots()
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
    color = rgbtolove(0,0,0)
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
    color = rgbtolove(154, 21, 102),
    font = fonts.debug,
    draw = true,
    padx = 10,
    pady = 65
  }
}

-- NEXT: confine highlight to grid
-- NEXT: click sound every time the active plot changes
-- NEXT: arrows change active plot
local mouse = love.graphics.newImage("pointer.png") -- load in a custom mouse image



function game:drawStats(stats)
  -- stats are updated at the end of game:draw()
  local wwidth, wheight = love.graphics.getWidth(), love.graphics.getHeight()

  if (self._debug.draw and stats ~= nil) then
    local str = string.format(
      "Draw Calls: %i\nTexture Memory: %.2f MB\nMouse x:%i | y:%i\nPlot: %i,%i",
      stats.drawcalls,
      stats.texturememory / 1024 / 1024,
      self._mouse.x,
      self._mouse.y,
      self._active.x and self._active.x or -1,
      self._active.y and self._active.y or -1
    )
    local sheight = self._debug.font:getHeight(str)

    love.graphics.setColor(self._debug.color)
    love.graphics.print(str, self._debug.padx, wheight - sheight - self._debug.pady)
  end
end


---- GAME FUNCTIONS ----
function game:buildPlots()
  -- fill all plot data
  for row=0,self._plot.count-1,1 do
    self._plots[row] = {}
    -- loop for columns
    for col=0,self._plot.count-1,1 do
      self._plots[row][col] = {
        planted = false,
        watered = false,
        plowed = false,
        seed = nil,
        fertilizer = nil,
        x = (col * self._plot.width),
        y = (row * self._plot.height)
      }
    end
  end
end

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
    love.graphics.setColor(self._plot.color.default)
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

function game:updateMouse(dt)
  local x, y = love.mouse.getPosition() -- get the position of the mouse

  -- offset mouse coords to be relative to the grid location
  self._mouse.x = x - self._plot.x
  self._mouse.y = y - self._plot.y

  -- just copy
  self._mouse.dx = dx
  self._mouse.dy = dy
  self._mouse.istouch = istouch

  self._active.x, self._active.y = self:getPlot(self._mouse.x, self._mouse.y)
end

function game:getPlot(x, y)
  return math.floor(x / self._plot.width), math.floor(y / self._plot.height)
end


---- LOVE CALLBACKS ----
function game:update(dt)
  self:updateMouse(dt)
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
    p = function() prinspect(self._plots[self._active.x][self._active.y]) end,

    -- REVIEW: menus need some work
    escape = function() gamestate.push(self._previous) end
  }

  if (keys[key]) then
    keys[key]()
  end

end

function game:draw()
  self:drawPlots()
  self:drawStats(love.graphics.getStats())

  local x, y = love.mouse.getPosition() -- get the position of the mouse
  love.graphics.draw(mouse, x, y) -- draw the custom mouse image
end


---- GAMESTATE CALLBACKS ----
 -- init is called only once when the gamestate is first loaded
function game:init()
  print('init game')
  game:buildPlots()
  game:drawPlots{refreshCanvas=true} -- force canvas refresh
end

-- enter is called every time the gamestate is switched to game
function game:enter(previous)
  self._previous = previous
 --s self.captureMouse()
end

-- leave is called every time the gamestate is switched away from game
function game:leave(previous)
  self.releaseMouse()
end

function game:captureMouse()
    love.mouse.setVisible(false) -- make default mouse invisible
end

function game:releaseMouse()
  love.mouse.setVisible(true)
end

return game