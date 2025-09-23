local playfield = require "nestrischamps.playfield"

local frameManager = {}
frameManager.frame = nil

function frameManager.update(time, gameNo, curPieceDas)
    local score = getScore()
    local lines = getLines()
    local level = getLevel()
    local preview = getNextPiece()
    local instantDas = getInstantDas()
    local curPiece = getCurPiece()

    local statistics = {}
    for i = 1, 7 do
        statistics[i] = getPieceStatistic(i)
    end

    local playfield = playfield.getBinaryString()

    frameManager.frame = makeFrame(time, gameNo, score, lines, level, preview, playfield, statistics, curPiece, curPieceDas, instantDas)
end

return frameManager
