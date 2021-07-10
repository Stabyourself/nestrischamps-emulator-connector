local playfield = {}

function playfield.initialize()
    playfield.blocks = {}

    for x = 1, 10 do
        playfield.blocks[x] = {}
    end

    playfield.invalid = false

    playfield.lineClearNum = 5

    playfield.curtainNum = 20
end

function playfield.update()
    if playfield.invalid then
        -- we believe the playfield is different from what we have stored
        for y = 1, 20 do
            for x = 1, 10 do
                playfield.blocks[x][y] = getBlock(x, y)
            end
        end

        -- insert the current piece
        local pieceID = getCurrentPiece()

        if pieceID < 19 then -- during entrypiecedelay the pieceID is 19 or something?
            local pieceX, pieceY = getCurrentPosition()
            local piece = PIECETABLE[pieceID+1]
            local graphic = PIECEGRAPHICTABLE[piece+1]

            for _, position in ipairs(PIECEPOSITIONTABLE[pieceID+1]) do
                local x, y = pieceX + position[1]+1, pieceY + position[2]+1

                playfield.blocks[x][y] = graphic
            end
        end

        playfield.invalid = false
    end
end

function playfield.lineClearUpdate()
    local lineClearAnimation = getLineClearAnimation()

    if lineClearAnimation > playfield.lineClearNum then
        playfield.lineClearNum = lineClearAnimation

        for _, y in ipairs(playfield.linesToClear) do
            playfield.blocks[6-lineClearAnimation][y] = "00"
            playfield.blocks[5+lineClearAnimation][y] = "00"
        end

        return true
    end

    return false
end

function playfield.curtainUpdate()
    local curtainAnimation = getCurtainAnimation()

    if curtainAnimation > playfield.curtainNum and curtainAnimation < 128 then
        playfield.curtainNum = curtainAnimation

        return true
    end
end

function playfield.lineClearAnimation(lines)
    playfield.linesToClear = lines
    playfield.lineClearNum = 0
end

function playfield.invalidate()
    playfield.invalid = true
end

function playfield.getBinaryString()
    -- if we never rendered the playfield, just do it now so we're safe
    if not playfield.blocks[1][1] then
        playfield.invalidate()
        playfield.update()
    end

    -- convert to bitstring (bad code)
    local binaryString = ""

    for y = 1, 20 do
        for x = 1, 10 do
            binaryString = binaryString .. playfield.blocks[x][y]
        end
    end

    return binaryString
end

return playfield
