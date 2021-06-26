function love.conf(t)
  t.identity = "GRidFarm"      -- The name of the save directory (string)
  t.version = "11.3"                  -- The LÖVE version this game was made for (string)
  t.console = true                    -- Attach a console (boolean, Windows only)
  t.window.title = "GRidFarm"      -- The window title (string)
  t.window.width = 800
  t.window.height = 600
  t.window.borderless = true         -- Remove all border visuals from the window (boolean)
  t.window.resizable = false          -- Let the window be user-resizable (boolean)
  t.window.fullscreen = false         -- Enable fullscreen (boolean)
  t.window.fullscreentype = "desktop" -- Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)
  t.window.vsync = 1                  -- Vertical sync mode (number)
  t.window.msaa = 0                   -- The number of samples to use with multi-sampled antialiasing (number)

	t.modules.physics = false
	t.modules.sound = false
end
