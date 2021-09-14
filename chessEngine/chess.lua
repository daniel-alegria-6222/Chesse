local Chess = {}

local class_mt = {
    __call = function (self, chessSide, playerColor)
        local this = {}

        local rgb = require("tools/rgb")
        local tt = require("tools/tabletools")
        local Schemes = require("config/colorSchemes")
        local ChessBoard = require("chessEngine/chessboard")
        
        this.Sound = require("tools/sound")
        this.Sound:init("move", "sfx/move.ogg", "static")
        this.Sound:init("capture", "sfx/capture.ogg", "static")
        
        this.image = love.graphics.newImage("assets/pieces.png")

        this.Board = ChessBoard(playerColor)

        this.TILE_SIDE = tonumber(chessSide / 8)
        this.CHESS_SIDE = this.TILE_SIDE * 8
        this.OFFSET = love.graphics.getWidth()/2 - this.CHESS_SIDE / 2

        local scheme = {}
        for k,v in pairs(Schemes[Schemes.current]) do
            scheme[k] = rgb.toLove(unpack(v))
        end
        this.colors = {
            light={
                normal=scheme.light,
                mix1 = rgb.mix(scheme.light, scheme.color1),
                mix2 = rgb.mix(scheme.light, scheme.color2),
                mix3 = rgb.mix(scheme.light, scheme.color3),
            },
            dark={
                normal=scheme.dark,
                mix1 = rgb.mix(scheme.dark, scheme.color1),
                mix2 = rgb.mix(scheme.dark, scheme.color2),
                mix3 = rgb.mix(scheme.dark, scheme.color3),
            }
        }

        this.turn = "w"
        this.touched = nil

        --------- INSTANCE METHODS
        function this.getRelativePos(self, x, y)
            return math.floor((y - self.OFFSET)/self.TILE_SIDE)+1, math.floor(x/self.TILE_SIDE)+1
        end

        function this.assestMove(self, i0, j0)
            local piece = self.Board:getPieceAt(i0, j0)

            if piece and piece.colorName == self.turn then
                local available, offensive = piece:getMoves(self.Board.BOARD)
                self.touched = {i=i0, j=j0}

            else
                self.touched = nil
            end
        end

        function this.commitMove(self, iF, jF)
            local i0,j0 = self.touched.i, self.touched.j
            local piece0 = self.Board:getPieceAt(i0, j0)
            local pieceF = self.Board:getPieceAt(iF, jF)

            if pieceF then 
                if pieceF.colorName == piece0.colorName then
                    if (i0==iF and j0==jF) then
                        self.touched = nil
                    else
                        self:assestMove(iF, jF)
                    end

                elseif (i0~=iF or j0~=jF) then
                    local available, offensive = piece0:getMoves(self.Board.BOARD)
                    local a = tt.contains_table(available, {iF, jF})
                    local b = tt.contains_table(offensive, {iF, jF})

                    if a or b then
                        self.Board:makeMove(i0, j0, iF, jF)
                        self.turn = self.turn == "w" and "b" or "w"
                        -- self.Board:swapBoard()

                        self.touched = nil

                        if a then self.Sound:play("move", "sfx")
                        else self.Sound:play("capture", "sfx") end
                    end
                end
            end

        end

        function this.touchInputAt(self, x, y)
            if not self.Board.allowed then return end
            local i,j = self:getRelativePos(x,y)
            if not self.touched then
                self:assestMove(i,j)
            else
                self:commitMove(i,j)
            end
        end


        -- LOVE:DRAW()
        local sten = {}
        local myStencilFunction = function()
            love.graphics.circle(
                "fill",
                (2*sten.c-1)*this.TILE_SIDE/2,
                (2*sten.r-1)*this.TILE_SIDE/2 + this.OFFSET ,
                this.TILE_SIDE*11/20,
                50
            )
        end

        function this.drawTiles(self, r,c, type, colors)
            -- draw diff tile colors
            love.graphics.setColor(colors[(r+c)%2 + 1])
            if type == "normal" then
                love.graphics.rectangle(
                    "fill", 
                    (c-1)*self.TILE_SIDE, 
                    (r-1)*self.TILE_SIDE + self.OFFSET,
                    self.TILE_SIDE,
                    self.TILE_SIDE
                )
            elseif type == "available" then
                love.graphics.circle(
                    "fill",
                    (2*c-1)*self.TILE_SIDE/2,
                    (2*r-1)*self.TILE_SIDE/2 + self.OFFSET,
                    self.TILE_SIDE/7,
                    50
                )
            elseif type == "offensive" then
                sten.r, sten.c = r, c
                love.graphics.stencil(myStencilFunction, "replace", 1)
                love.graphics.setStencilTest("equal", 0)

                love.graphics.rectangle(
                    "fill",
                    (sten.c-1)*this.TILE_SIDE,
                    (sten.r-1)*this.TILE_SIDE + this.OFFSET,
                    this.TILE_SIDE,
                    this.TILE_SIDE
                )

                love.graphics.setStencilTest()
            end
        end

        function this.draw(self)

            for r,array in ipairs(self.Board.BOARD) do
                for c,piece in ipairs(array) do

                    local colors

                    if tt.contains_table(self.Board:getLastTiles(), {r,c}) then
                        colors = {self.colors.light.mix2, self.colors.dark.mix2}
                        self:drawTiles(r,c, "normal", colors)
                    else
                        colors = {self.colors.light.normal, self.colors.dark.normal}
                        self:drawTiles(r,c, "normal", colors)
                    end

                    if self.touched then
                        local i,j = self.touched.i, self.touched.j
                        local avail, offen = self.Board:getPieceAt(i,j):getMoves(self.Board.BOARD)

                        colors = {self.colors.light.mix1, self.colors.dark.mix1}
                        local type

                        if tt.contains_table(avail, {r,c}) then
                            type = "available"

                        elseif tt.contains_table(offen, {r,c}) then
                            type = "offensive"

                        elseif r == i and c == j then
                            type = "normal"
                        end
                        self:drawTiles(r,c, type, colors)

                    end

                    -- Draw each piece sprite
                    if piece.colorName then 
                        love.graphics.setColor(1,1,1)
                        love.graphics.draw(
                            self.image,
                            piece.quad,
                            (c-1)*self.TILE_SIDE,
                            (r-1)*self.TILE_SIDE + self.OFFSET,
                            0,
                            self.TILE_SIDE/200,
                            self.TILE_SIDE/200
                        )
                    end
                end
            end
        end
        --

        return this
    end
}

setmetatable(Chess, class_mt)

return Chess
