local ChessPieces = {}

local class_mt = {

    __call = function (class, i,j, colorPiece, playerColor)
        if not colorPiece then return {} end

        local this = {}
        local tt = require("tools/tabletools")

        this.i, this.j = i,j

        this.colorPiece = colorPiece
        this.colorName = string.sub(colorPiece,1,1)
        this.pieceName = string.sub(colorPiece,2,2)

        this.playerColor = playerColor

        this.moves_num = 0

        class.getPawnMoves = function(self, board)
            local i,j = self.i, self.j
            local k = self.colorName == self.playerColor and -1 or 1
            local available, offensive = {}, {}

            local _i = i+k

            if board[_i][j] and not board[_i][j].colorPiece then
                if board[i+2*k][j] and not board[i+2*k][j].colorPiece and self.moves_num == 0 then 
                    table.insert(available, {i+2*k, j})
                end
                table.insert(available, {_i, j})
            end
            
            local piece
            for _,_j in ipairs({j+1, j-1}) do
                piece = board[_i][_j]
                if piece and piece.colorPiece and self.colorName ~= piece.colorName then
                    table.insert(offensive, {_i, _j})
                end
            end

            return available, offensive
        end

        class.getKnightMoves = function(self, board)
            local i0,j0 = self.i, self.j
            local available, offensive = {}, {}

            local Di, Dj, ratio
            for iF, array in ipairs(board) do
                for jF, piece in ipairs(array) do
                    Di = iF - i0
                    Dj = jF - j0
                    ratio = {math.abs(Di), math.abs(Dj)}
                    if tt.equals(ratio,{1,2}) or tt.equals(ratio,{2,1}) then
                        if not piece.colorPiece then
                            table.insert(available, {iF, jF})
                        elseif self.colorName ~= piece.colorName then
                            table.insert(offensive, {iF, jF})
                        end
                    end
                end
            end

            return available, offensive
        end

        class.getKingMoves = function(self, board)
            local i0,j0 = self.i, self.j
            local available, offensive = {}, {}

            local Di, Dj, ratio
            for iF, array in ipairs(board) do
                for jF, piece in ipairs(array) do
                    Di = iF - i0
                    Dj = jF - j0
                    ratio = {math.abs(Di), math.abs(Dj)}
                    if tt.equals(ratio,{0,1}) or tt.equals(ratio,{1,1}) or tt.equals(ratio,{1,0}) then
                        if not piece.colorPiece then
                            table.insert(available, {iF, jF})
                        elseif self.colorName ~= piece.colorName then
                            table.insert(offensive, {iF, jF})
                        end
                    end
                end
            end

            return available, offensive
        end

        class.getRookMoves = function(self, board)
            local i,j = self.i, self.j
            local available, offensive = {}, {}

            local i_n = -(i-1)
            local j_n = -(j-1)
            local i_p = 8-i
            local j_p = 8-j

            local line_lst = {i_n, j_n, i_p, j_p}
            
            local iVec, jVec
            for index,dir in ipairs(line_lst) do
                for mod=1,math.abs(dir),1 do
                    if index == 1 then iVec = -1; jVec = 0
                    elseif index == 2 then iVec = 0; jVec = -1
                    elseif index == 3 then iVec = 1; jVec = 0
                    elseif index == 4 then iVec = 0; jVec = 1
                    end

                    local r,c = i + iVec*mod, j + jVec*mod

                    local piece = board[r][c]
                    if not piece.colorPiece then
                        table.insert(available, {r,c})
                    else
                        if self.colorName ~= piece.colorName then
                            table.insert(offensive, {r,c})
                        end
                        break
                    end
                end
            end

            return available, offensive
        end

        class.getBishopMoves = function(self, board)
            local i,j = self.i, self.j
            local available, offensive = {}, {}

            local i_n = -(i-1)
            local j_n = -(j-1)
            local i_p = 8-i
            local j_p = 8-j

            local diagonals_lst = {{i_n,j_n}, {i_n,j_p}, {i_p, j_n}, {i_p, j_p}}


            local iDiag,jDiag, iVec,jVec, r,c, piece
            for _, diagonal in ipairs(diagonals_lst) do
                iDiag ,jDiag = unpack(diagonal)
                for mod=1,math.min(math.abs(iDiag),math.abs(jDiag)),1 do
                    iVec = iDiag < 0 and -1 or 1
                    jVec = jDiag < 0 and -1 or 1

                    r,c = i + iVec*mod, j + jVec*mod

                    piece = board[r][c]
                    if not piece.colorPiece then
                        table.insert(available, {r,c})
                    else
                        if self.colorName ~= piece.colorName then
                            table.insert(offensive, {r,c})
                        end
                        break
                    end
                end
            end
            return available, offensive
        end

        class.getQueenMoves = function(self, board)
            local i,j = self.i, self.j

            local i_n = -(i-1)
            local j_n = -(j-1)
            local i_p = 8-i
            local j_p = 8-j

            local rookAvailable, rookOffensive = {}, {}
            local line_lst = {i_n, j_n, i_p, j_p}

            local iVec, jVec
            for index,dir in ipairs(line_lst) do
                for mod=1,math.abs(dir),1 do
                    if index == 1 then iVec = -1; jVec = 0
                    elseif index == 2 then iVec = 0; jVec = -1
                    elseif index == 3 then iVec = 1; jVec = 0
                    elseif index == 4 then iVec = 0; jVec = 1
                    end

                    local r,c = i + iVec*mod, j + jVec*mod

                    local piece = board[r][c]
                    if not piece.colorPiece then
                        table.insert(rookAvailable, {r,c})
                    else
                        if self.colorName ~= piece.colorName then
                            table.insert(rookOffensive, {r,c})
                        end
                        break
                    end
                end
            end

            local bishopAvailable, bishopOffensive = {}, {}
            local diagonals_lst = {{i_n,j_n}, {i_n,j_p}, {i_p, j_n}, {i_p, j_p}}

            local iDiag,jDiag, iVec,jVec, r,c, piece
            for _, diagonal in ipairs(diagonals_lst) do
                iDiag ,jDiag = unpack(diagonal)
                for mod=1,math.min(math.abs(iDiag),math.abs(jDiag)),1 do
                    iVec = iDiag < 0 and -1 or 1
                    jVec = jDiag < 0 and -1 or 1

                    r,c = i + iVec*mod, j + jVec*mod

                    piece = board[r][c]
                    if not piece.colorPiece then
                        table.insert(bishopAvailable, {r,c})
                    else
                        if self.colorName ~= piece.colorName then
                            table.insert(bishopOffensive, {r,c})
                        end
                        break
                    end
                end
            end

            local available = tt.concat(rookAvailable, bishopAvailable)
            local offensive = tt.concat(rookOffensive, bishopOffensive)
            return available, offensive
        end


        this.imageWidth, this.imageHeight = 1200, 400
        if colorPiece == "wK" then
            this.getMoves = class.getKingMoves
            this.quad =  love.graphics.newQuad(0*200,0, 200,200, this.imageWidth, this.imageHeight)
        elseif colorPiece == "wQ" then
            this.getMoves = class.getQueenMoves
            this.quad = love.graphics.newQuad(1*200,0, 200,200, this.imageWidth, this.imageHeight)
        elseif colorPiece == "wB" then
            this.getMoves = class.getBishopMoves
            this.quad = love.graphics.newQuad(2*200,0, 200,200, this.imageWidth, this.imageHeight)
        elseif colorPiece == "wN" then
            this.getMoves = class.getKnightMoves
            this.quad = love.graphics.newQuad(3*200,0, 200,200, this.imageWidth, this.imageHeight)
        elseif colorPiece == "wR" then
            this.getMoves = class.getRookMoves
            this.quad = love.graphics.newQuad(4*200,0, 200,200, this.imageWidth, this.imageHeight)
        elseif colorPiece == "wP" then
            this.getMoves = class.getPawnMoves
            this.quad = love.graphics.newQuad(5*200,0, 200,200, this.imageWidth, this.imageHeight)
        elseif colorPiece == "bK" then
            this.getMoves = class.getKingMoves
            this.quad = love.graphics.newQuad(0*200,200, 200,200, this.imageWidth, this.imageHeight)
        elseif colorPiece == "bQ" then
            this.getMoves = class.getQueenMoves
            this.quad = love.graphics.newQuad(1*200,200, 200,200, this.imageWidth, this.imageHeight)
        elseif colorPiece == "bB" then
            this.getMoves = class.getBishopMoves
            this.quad = love.graphics.newQuad(2*200,200, 200,200, this.imageWidth, this.imageHeight)
        elseif colorPiece == "bN" then
            this.getMoves = class.getKnightMoves
            this.quad = love.graphics.newQuad(3*200,200, 200,200, this.imageWidth, this.imageHeight)
        elseif colorPiece == "bR" then
            this.getMoves = class.getRookMoves
            this.quad = love.graphics.newQuad(4*200,200, 200,200, this.imageWidth, this.imageHeight)
        elseif colorPiece == "bP" then
            this.getMoves = class.getPawnMoves
            this.quad = love.graphics.newQuad(5*200,200, 200,200, this.imageWidth, this.imageHeight)
        end

        return this
    end
}

setmetatable(ChessPieces, class_mt)
return ChessPieces
