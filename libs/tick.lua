-- tick
-- https://github.com/bjornbytes/tick
-- MIT License

--TODO: Figure out how to implement this without a library
-- i cant impelment int :(((((((((((

local tick = {
  framerate = nil,
  rate = .03,
  timescale = 1,
  sleep = .001,
  dt = 0,
  accum = 0,
  tick = 1,
  frame = 1
}

local timer = love.timer
local graphics = love.graphics

love.run = function()
  if not timer then
    error('love.timer is required for tick')
  end

  ---@diagnostic disable-next-line
  if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
  timer.step()
  local lastframe = 0

  if love.update then love.update(0) end

  return function()
    tick.dt = timer.step() * tick.timescale
    tick.accum = tick.accum + tick.dt
    while tick.accum >= tick.rate do
      tick.accum = tick.accum - tick.rate

      if love.event then
        love.event.pump()
        for name, a, b, c, d, e, f in love.event.poll() do
          if name == 'quit' then
            if not love.quit or not love.quit() then
              return a or 0
            end
          end

          ---@diagnostic disable-next-line
          love.handlers[name](a, b, c, d, e, f)
        end
      end

      tick.tick = tick.tick + 1
      if love.update then love.update(tick.rate) end
    end

    -- https://github.com/bjornbytes/tick/pull/11
    -- maybe...
    --TODO: Add arg. option to switch to non-patch version
    if tick.framerate then
      local affinity = math.min(0.85, 0.96655 - 0.0019425 * tick.framerate)
      while timer.getTime() - lastframe < 1 / tick.framerate do
        if timer.getTime() - lastframe < 1 / tick.framerate * affinity then timer.sleep(0.001) end
      end
    end

    lastframe = timer.getTime()
    if graphics and graphics.isActive() then
      graphics.origin()
      graphics.clear(graphics.getBackgroundColor())
      tick.frame = tick.frame + 1
      if love.draw then love.draw() end
      graphics.present()
    end

    timer.sleep(tick.sleep)
  end
end

return tick
