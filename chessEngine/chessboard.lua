local ChessBoard = {}

local class_mt = {
    __call = function (class, playerColor)
        local this = {}
        local ChessPieces = require("chessEngine/chesspieces")
        local tt = require("tools/tabletools")

        function this.genNewBoard(p,e, empty)
            empty = empty or false
            local BOARD = {
                {e.."R", e.."N", e.."B", e.."Q", e.."K", e.."B", e.."N", e.."R"},
                {e.."P", e.."P", e.."P", e.."P", e.."P", e.."P", e.."P", e.."P"},
                {"*", "*", "*", "*", "*", "*", "*", "*"},
                {"*", "*", "*", "*", "*", "*", "*", "*"},
                {"*", "*", "*", "*", "*", "*", "*", "*"},
                {"*", "*", "*", "*", "*", "*", "*", "*"},
                {p.."P", p.."P", p.."P", p.."P", p.."P", p.."P", p.."P", p.."P"},
                {p.."R", p.."N", p.."B", p.."Q", p.."K", p.."B", p.."N", p.."R"},
            }
            for row, array in ipairs(BOARD) do
                for column, elem in ipairs(array) do
                    if empty then
                        BOARD[row][column] = {i=row , j=column}
                        goto continue
                    end
                    
                    if elem ~= "*" then
                        BOARD[row][column] = ChessPieces(row, column, elem, playerColor)
                    else
                        BOARD[row][column] = {i=row , j=column}
                    end
                    ::continue::
                end
            end
            return BOARD
        end

        if playerColor then
            this.p = playerColor
            this.e = (playerColor == "w") and "b" or "w"
            this.BOARD = this.genNewBoard(this.p, this.e)
        end
        -----------
        this.history = {}
        this.nextHistLen = 1
        this.allowed = true

        function this.swapBoard(self)
            local newBOARD = self.genNewBoard(self.p,self.e, true)
            for row, array in ipairs(newBOARD) do
                for column, _ in ipairs(array) do
                    local i,j = 9-row, 9-column
                    local piece = self:getPieceAt(row,column)
                    piece.i, piece.j = i,j
                    newBOARD[i][j] = piece
                end
            end
            self.BOARD = newBOARD
        end

        function this.getPieceAt(self, i, j)
            if i and j and (1<=i and i<=8) and (1<=j and j<=8) then
                return self.BOARD[i][j]
            end
        end

        function this.makeMove(self, i0, j0, iF, jF)
            if self.allowed then
                local piece0 = self:getPieceAt(i0, j0)
                local pieceF = self:getPieceAt(iF, jF)

                if piece0.colorPiece and pieceF then
                    self.history[self.nextHistLen] = {
                        p0=tt.deepCopy(piece0),
                        pF=tt.deepCopy(pieceF)
                    }
                    self.nextHistLen = self.nextHistLen + 1

                    piece0.i, piece0.j = iF, jF
                    piece0.moves_num = piece0.moves_num + 1
                    self.BOARD[iF][jF] = piece0
                    self.BOARD[i0][j0] = {i=i0, j=j0}

                end
            end
        end

        function this.undoMove(self)
            self.nextHistLen = self.nextHistLen - 1
            if self.nextHistLen < 1 then
                self.nextHistLen = 1
                return
            end
            local move = self.history[self.nextHistLen]
            self.BOARD[move.p0.i][move.p0.j] = move.p0
            self.BOARD[move.pF.i][move.pF.j] = move.pF
            self.allowed = false
        end

        function this.redoMove(self)
            if self.nextHistLen ~= #self.history + 1 then
                local move = self.history[self.nextHistLen]
                local temp_p0 = tt.deepCopy(move.p0)

                temp_p0.i, temp_p0.j = move.pF.i, move.pF.j
                self.BOARD[move.pF.i][move.pF.j] = temp_p0
                self.BOARD[move.p0.i][move.p0.j] = {i=move.p0.i, j=move.p0.j}

                self.nextHistLen = self.nextHistLen + 1
            end

            if self.nextHistLen == #self.history + 1 then self.allowed=true end
        end

        function this.getLastTiles(self)
            local current = self.history[self.nextHistLen-1]
            if current then
                local p0 = current.p0
                local pF = current.pF
                return {{p0.i, p0.j}, {pF.i, pF.j}}
            else
                return {}
            end
        end

        return this
    end
}

setmetatable(ChessBoard, class_mt)

return ChessBoard
