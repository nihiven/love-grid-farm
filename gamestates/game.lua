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
    y = 10,
    sounds = {
      grid = {
        change = love.audio.newSource("sounds/gridClick.ogg", "static")
      }
    }
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

-- NEXT: arrows change active plot
-- JUICE: shake the grid when plot changes
local cursor = love.mouse.newCursor(love.image.newImageData("pointer.png"), 0, 0)

function game:drawStats(stats)
  -- stats are updated at the end of game:draw()
  local wwidth, wheight = love.graphics.getWidth(), love.graphics.getHeight()

  if (self._debug.draw and stats ~= nil) then
    local str = string.format(
      "Draw Calls: %i\nTexture Memory: %.2f MB\nMouse [x:%i y:%i] [rx:%i ry:%i]\nPlot: %i,%i",
      stats.drawcalls,
      stats.texturememory / 1024 / 1024,
      self._mouse.x,
      self._mouse.y,
      self._mouse.rx,
      self._mouse.ry,
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
        selected = false,
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
    -- there isn't a canvas OR we're forcing a refresh
    prinspect(refreshCanvas)
    print(refreshCanvas and 'refreshing grid canvas...' or 'creating grid canvas...')

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

  -- draw the saved canvas
  love.graphics.setColor(1, 1, 1, 1) -- must reset colors per docs
  love.graphics.setBlendMode('alpha', 'premultiplied') -- use premult mode due to precalced alpha values
  love.graphics.draw(self._canvas.data, self._plot.x, self._plot.y)
  love.graphics.setBlendMode("alpha") -- return to default blend mode

  -- draw active plot
  if (self._active.x) then
    -- calculate grid origin coords
    local ax = self._active.x * self._plot.width + self._plot.x
    local ay = self._active.y * self._plot.height + self._plot.y

    -- change color and draw the highlight
    love.graphics.setColor(self._active.color)
    love.graphics.rectangle('line', ax, ay, self._plot.width, self._plot.height)
  end
end

function game:updateMouse()
  local x, y = love.mouse.getPosition() -- get the position of the mouse
  
  -- window relative
  self._mouse.x = x
  self._mouse.y = y

  -- grid relative
  self._mouse.rx = x - self._plot.x
  self._mouse.ry = y - self._plot.y
end

-- returns bool - did plot change
function game:updateActivePlot()
  -- store old values
  local ox, oy = self._active.x, self._active.y 

  -- check to see if the active plot is within bounds
  local nx, ny = self:getPlot(self._mouse.rx, self._mouse.ry)

  -- confine the active plot to the grid on the x axis
  if (nx >= 0 and nx < self._plot.count) then
    self._active.x = nx
    plotChanged = true
  end

  -- confine the active plot to the grid on the y axis
  if (ny >= 0 and ny < self._plot.count) then
    self._active.y = ny
    plotChanged = true
  end

  -- check to see if the old plot values are different than the new ones
  if (self._active.x == ox and self._active.y == oy) then
    -- plots weren't updated
    return false
  end

  -- update plot selected properties 
  if (ox ~= nil and oy ~= nil) then
    self._plots[ox][oy].selected = false
  end

  self._plots[self._active.x][self._active.y].selected = true

  -- plots were updated
  return true
end

function game:getPlot(x, y)
  return math.floor(x / self._plot.width), math.floor(y / self._plot.height)
end


---- LOVE CALLBACKS ----
function game:update(dt)
  self:updateMouse()

  -- returns true if the active plot changed
  if (self:updateActivePlot() == true) then
    love.audio.play(self._plot.sounds.grid.change)
  end
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

  -- if the given key is mapped, call it as a function
  if (keys[key]) then
    keys[key]()
  end

end

function game:draw()
  self:drawPlots()
  self:drawStats(love.graphics.getStats())
end


---- GAMESTATE CALLBACKS ----
 -- init is called only once when the gamestate is first loaded
function game:init()
  print('init game')
  game:buildPlots()
  game:drawPlots()
end

-- enter is called every time the gamestate is switched to game
function game:enter(previous)
  self._previous = previous
  self.captureMouse()
end

-- leave is called every time the gamestate is switched away from game
function game:leave(previous)
  self.releaseMouse()
end

function game:captureMouse()
  --love.mouse.setVisible(false) -- make default mouse invisible
  love.mouse.setGrabbed(true)
  love.mouse.setCursor(cursor)
end

function game:releaseMouse()
  love.mouse.setGrabbed(false)
  --love.mouse.setVisible(true)
end

return game