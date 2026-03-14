function love.conf(t)
    t.window.title = "stak"
    t.identity = "stak"
    t.version = "11.5"
    -- t.window.fullscreen = true
    t.window.icon = "/assets/icon.png"
    t.window.resizable = true
    t.window.minwidth = 800
    t.window.minheight = 600
    t.window.width = 800
    t.window.height = 600
    t.modules.physics = false
end
