local game = {
  -- farms are ALWAYS square
  _plots = 10, -- so this is 5^2
  _plotWidth = 50,
  _plotHeight = 50,
  _plotColor = {0, 1, 1},
  _x = 10,
  _y = 10,
  -- canvas related
  _canvas = nil,
  _canvasColor = {0,0,0},
  -- gamestate relate
  _previous = nil
}

-- NEXT: what grid is the mouse in?

-- Draw the grid to a canvas, then reuse the canvas instead of redrawing the grid.
function game:drawGrid(refreshCanvas)
  if (self._canvas == nil or refreshCanvas) then
    print('refresh canvas')

    -- create canvas
    local width = self._plotWidth * self._plots
    local height = self._plotHeight * self._plots
    self._canvas = love.graphics.newCanvas(width, height)

    -- setup canvas
    love.graphics.setCanvas(self._canvas)
    love.graphics.setColor(self._plotColor)
    love.graphics.clear(self._canvasColor)

    -- draw grid
    for row=0,self._plots-1,1 do
      -- loop for columns
      for col=0,self._plots-1,1 do
        local x = (col * self._plotWidth)
        local y = (row * self._plotHeight)
        
        love.graphics.rectangle('line', x, y, self._plotWidth, self._plotHeight)
      end
    end

    -- return to main canvas
    love.graphics.setCanvas()
  end

  love.graphics.setColor(1, 1, 1, 1) -- must reset colors per docs
  love.graphics.setBlendMode('alpha', 'premultiplied') -- use premult mode due to precalc alpha values
  love.graphics.draw(self._canvas, self._x, self._y)
  love.graphics.setBlendMode("alpha") -- return to default blend mode
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
end

function game:init()
  print('init game')
  game:drawGrid{refreshCanvas=true} -- force canvas refresh
end

function game:draw()
  self:drawGrid()
end

-- gamestate callbacks
function game:enter(previous)
  self._previous = previous
end

return game