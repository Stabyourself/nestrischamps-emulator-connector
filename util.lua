function toBits(num, bits)
    -- returns a string of bits, most significant first.
    bits = bits or math.max(1, select(2, math.frexp(num)))

    local out = ""
    for b = bits-1, 0, -1 do
        out = out .. ((num >> b) & 1)
    end
    return out
end


function makeFrame(ms, gameNo, score, lines, level, preview, playfield, statistics)
    -- all of this is bad and slow
    bits = {
        "001", -- version
        "01", -- game type (classic)
        "000", -- player number (always 0 for client)
        toBits(gameNo, 16), -- game
        toBits(ms, 28), -- milliseconds
        toBits(score, 21), -- score
        toBits(lines, 9), -- lines
        toBits(level, 6), -- level
        "11111", -- DAS stuff
        toBits(preview, 3), -- preview
        "11111", -- DAS stuff
        "111", -- DAS stuff
        toBits(statistics[1], 8), -- piece counts
        toBits(statistics[2], 8),
        toBits(statistics[3], 8),
        toBits(statistics[4], 8),
        toBits(statistics[5], 8),
        toBits(statistics[6], 8),
        toBits(statistics[7], 8),
        playfield, --playfield
    }

    local bitString = table.concat(bits)


    local out = ""

    for i = 1, #bitString, 8 do
        local num = tonumber(string.sub(bitString, i, i+7),2)

        out = out .. string.char(num)
    end

    -- adding an empty byte to the end because the server expects 71 bytes
    out = out .. string.char(0)

    return out
end

function log(...)
    if LOGGING then
        print(...)
    end
end
