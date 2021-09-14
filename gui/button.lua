local Button = {}

local class_mt = {
    __call = function (self, x,y,w,h, func)
        local this = {}

        local rgb = require("tools/rgb")
        
        this.Sound = require("tools/sound")
        this.Sound:init(tostring(func), "sfx/buttonpressed.flac", "static")

        this.x = x
        this.y = y
        this.w = w
        this.h = h

        this.func = func

        function this.onClick(self, x, y, argsTable)
            if self.x<=x and x<=self.x+self.w and self.y<=y and y<=self.y+self.h then
                self.func(unpack(argsTable))
                self.Sound:play(tostring(self.func), "sfx")
            else
            end
        end

        function this.draw(self)
            love.graphics.setColor(rgb.toLove(61,55,52))
            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
        end

        return this
    end
}

setmetatable(Button, class_mt)

return Button
