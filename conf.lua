
function love.conf(t) -- 720x1520
    t.title = "Chess Demo"
    t.verssion = "11.3"
    t.window.vsync = 0
    t.window.fullscreen = true
    t.window.msaa=16
    t.modules.joystick = false
    t.modules.physics = false
end
