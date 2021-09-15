-- FPS Optimizations
local min_dt = 1/24
local next_time = love.timer.getTime()

-- CONSTANS
Chess = require("chessEngine/chess")
Button = require("gui/button")

local _width = love.graphics.getWidth()
local _height = love.graphics.getHeight()



local function translate(x, y)
   local _y = x
   local _x = _height - y

   return _x, _y
end
------ LOVE SPECIFIC
-- FIRST
function love.load()
   local height = _width
   local width = _height

   chess = Chess(width, "w")

   local bWidth = 100 
   local bHeight = 50 
   local bX = width-bWidth-20
   local bY = height-bHeight-20

   undoButton = Button(bX-bWidth-15, bY, bWidth, bHeight, chess.Board.undoMove)
   redoButton = Button(bX, bY, bWidth, bHeight, chess.Board.redoMove)

   mainFont = love.graphics.newFont("assets/CascadiaCode.ttf", 20)

end

-- SECOND

function love.update(dt)
   chess.Sound:update()
   undoButton.Sound:update()
   redoButton.Sound:update()
   -- FPS Optimizations
   next_time = next_time + min_dt
end

--
function love.touchpressed(id, x, y, dx, dy, pressure)
   local rx, ry = translate(x,y)
   chess:touchInputAt(rx,ry)
   undoButton:onClick(rx,ry, {chess.Board})
   redoButton:onClick(rx,ry, {chess.Board})
end

-- function love.touchmoved(id, x, y, dx, dy, pressure)
-- end
-- function love.touchreleased(id, x, y, dx, dy, pressure)
-- end

-- THIRD
function love.draw()
   --- ROTATION
   love.graphics.translate(_width/2, _height/2)
	love.graphics.rotate(-math.pi / 2)
	love.graphics.translate(-_height/2, -_width/2)
   --

   chess:draw()
   undoButton:draw()
   redoButton:draw()

   --- DEBUGGING
   love.graphics.setFont(mainFont)
   love.graphics.setColor(1,1,1)
   love.graphics.print("Nunca te olvidare Jhaidi",15, 100)
   love.graphics.print(
      string.format(
         "Movimiento: %s / %s",
         chess.Board.nextHistLen-1,
         #chess.Board.history
      ),
      15,
      50
   )
   --

   --- FPS Optimizations
   local cur_time = love.timer.getTime()
   if next_time <= cur_time then
      next_time = cur_time
      return
   end
   love.timer.sleep(next_time - cur_time)
   --

end