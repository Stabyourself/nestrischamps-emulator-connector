local playfield = require "nestrischamps.playfield"

local frameManager = {}
frameManager.frame = nil

function frameManager.update(time, gameNo)
    local score = getScore()
    local lines = getLines()
    local level = getLevel()
    local preview = getNextPiece()

    local statistics = {}
    for i = 1, 7 do
        statistics[i] = getPieceStatistic(i)
    end

    local playfield = playfield.getBinaryString()

    frameManager.frame = makeFrame(time, gameNo, score, lines, level, preview, playfield, statistics)
end

return frameManager
