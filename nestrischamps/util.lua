function toBits(num, bits)
    -- returns a table of bits, most significant first.
    bits = bits or math.max(1, select(2, math.frexp(num)))
    local t = {} -- will contain the bits
    for b = bits, 1, -1 do
        t[b] = math.fmod(num, 2)
        num = math.floor((num - t[b]) / 2)
    end
    return table.concat(t, "")
end


function makeFrame(ms, gameNo, score, lines, level, preview, playfield, statistics, curPiece, curPieceDas, instantDas)
    -- all of this is bad and slow
    bits = {
        "011", -- version (format format v3)
        "01", -- game type (classic)
        "000", -- player number (always 0 for client)
        toBits(gameNo, 16), -- game
        toBits(ms, 28), -- milliseconds
        toBits(lines, 12), -- lines
        toBits(level, 8), -- level
        toBits(score, 24), -- score
        toBits(instantDas, 5), -- instant das
        toBits(preview, 3), -- preview
        toBits(curPieceDas, 5), -- cur piece das
        toBits(curPiece, 3), -- cur piece
        toBits(statistics[1], 10), -- piece counts
        toBits(statistics[2], 10),
        toBits(statistics[3], 10),
        toBits(statistics[4], 10),
        toBits(statistics[5], 10),
        toBits(statistics[6], 10),
        toBits(statistics[7], 10),
        "11", -- wasted bits
        playfield, --playfield
    }

    local bitString = table.concat(bits)


    local out = ""

    for i = 1, #bitString, 8 do
        local num = tonumber(string.sub(bitString, i, i+7),2)

        out = out .. string.char(num)
    end

    return out
end

function log(...)
    if LOGGING then
        print(...)
    end
end
