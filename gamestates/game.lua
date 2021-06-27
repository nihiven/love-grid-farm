-- JUICE: shake the grid when plot changes

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


--- GAME OBJECT ---
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
    x = 0,
    y = 0,
    color = {1,0,1}
  },

  -- canvas related
  _canvas = {
    data = nil,
    color = rgbtolove(0,0,0)
  },

  -- mouse related
  _mouse = {
    paused = false,
    x = 0,
    y = 0,
    -- change since last update
    dx = 0,
    dy = 0,
    -- relative to the grid
    rx = 0,
    ry = 0,
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

-- TODO: holding down keys doesn't do anything
local cursor = love.mouse.newCursor(love.image.newImageData("images/pointer.png"), 0, 0)

function game:drawStats(stats)
  local wwidth, wheight = love.graphics.getWidth(), love.graphics.getHeight()

  -- if draw flag is set and passed stats aren't nil
  if (self._debug.draw and stats ~= nil) then
    local str = string.format(
      "Draw Calls: %i | Texture Memory: %.2f MB\nMouse [x:%i y:%i] [rx:%i ry:%i] | Paused: %s\nPlot: %i,%i",
      stats.drawcalls,
      stats.texturememory / 1024 / 1024,
      self._mouse.x,
      self._mouse.y,
      self._mouse.rx,
      self._mouse.ry,
      self._mouse.paused,
      self._active.x and self._active.x or -1,
      self._active.y and self._active.y or -1
    )

    -- get the string height to use when setting origin y
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
    love.graphics.rectangle('fill', ax, ay, self._plot.width, self._plot.height)
  end
end

function game:updateMouse()
  local ox, oy = self._mouse.x, self._mouse.y
  local x, y = love.mouse.getPosition() -- get the position of the mouse
  
  -- mouse coords didn't change, return false
  if (ox == x and oy == y) then
    return false
  end
  -- window relative
  self._mouse.x = x
  self._mouse.y = y

  -- grid relative
  self._mouse.rx = x - self._plot.x
  self._mouse.ry = y - self._plot.y

  -- unpause mouse
  self:unpauseMouse()
  return true
end

-- returns bool - did plot change
function game:updateActivePlotFromMouse()
  -- store old values
  local ox, oy = self._active.x, self._active.y 

  -- check to see if the active plot is within bounds, 
  -- use grid relative values (rx, ry), store new values
  local nx, ny = self:getPlot(self._mouse.rx, self._mouse.ry)

  -- confine the active plot to the grid on the x axis, store new values
  self._active.x = clamp(0, nx or 0, self._plot.count-1) -- -1 for zero index
  self._active.y = clamp(0, ny or 0, self._plot.count-1) -- -1 for zero index

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

-- plot selection via keypress
-- x,y are number of plots to move in each direction
-- returns the x,y delta
function game:movePlot(x, y)
  -- NOTE: we need to disable the mouse until it moves again
  -- NOTE: otherwise it will immediately override movePlot results
  -- REVIEW: we might not want to pause the mouse if the keypress has no effect
  local ox, oy = self._active.x, self._active.y

  -- move based on plot movement
  local nx = clamp(0, self._active.x + (x or 0), self._plot.count-1)
  local ny = clamp(0, self._active.y + (y or 0), self._plot.count-1)

  -- store the x,y delta
  local dx, dy = nx - ox, ny - oy

  -- update _active properties
  self._active.x = self._active.x + dx
  self._active.y = self._active.y + dy

  -- update _plots properties
  self._plots[ox][oy].selected = false
  self._plots[self._active.x][self._active.y].selected = true

  if (dx ~= 0 or dy ~= 0) then
    -- REVIEW: play sound is now in two places
    love.audio.play(self._plot.sounds.grid.change)
    
    -- pause mouse updates
    self:pauseMouse() 
  end

  return dx, dy
end

function game:pauseMouse()
  if (not self._mouse.paused) then
    self._mouse.paused = true
    print('mouse paused')
  end
end

function game:unpauseMouse()
  if (self._mouse.paused) then
    self._mouse.paused = false
    print('mouse unpaused')
  end
end

---- LOVE CALLBACKS ----
function game:update(dt)
  -- REVIEW: does updateActivePlot move into updateMouse??
  -- returns true if mouse moved
  if (self:updateMouse()) then
    -- returns true if the active plot changed from mouse movement
    if (self:updateActivePlotFromMouse() == true) then
      love.audio.play(self._plot.sounds.grid.change)
    end
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
    p = function() prinspect(self._plots[self._active.x][self._active.y]) end,
    
    -- arrow movement
    up = function() self:movePlot(0,-1) end,
    down = function() self:movePlot(0,1) end,
    left = function() self:movePlot(-1,0) end,
    right = function() self:movePlot(1,0) end,

    -- wasd movement
    w = function() self:movePlot(0,-1) end,
    s = function() self:movePlot(0,1) end,
    a = function() self:movePlot(-1,0) end,
    d = function() self:movePlot(1,0) end,

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