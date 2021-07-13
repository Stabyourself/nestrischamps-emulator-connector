-- try to load environment.lua for default dialog values
local f=io.open("environment.lua","r")
if f~=nil then
    io.close(f)
    require "environment"
end

PIECETABLE = {0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 3, 4, 4, 5, 5, 5, 5, 6, 6} -- corresponds to PIECEPOSITIONTABLE

PIECEGRAPHICTABLE = {"01", "10", "11", "01", "10", "11", "01"} -- which graphic each piece uses

PIECEPOSITIONTABLE = {
    { { -1,  0 }, {  0,  0 }, {  1,  0 }, {  0, -1 }, },  -- 00: T up
    { {  0, -1 }, {  0,  0 }, {  1,  0 }, {  0,  1 }, },  -- 01: T right
    { { -1,  0 }, {  0,  0 }, {  1,  0 }, {  0,  1 }, },  -- 02: T down (spawn)
    { {  0, -1 }, { -1,  0 }, {  0,  0 }, {  0,  1 }, },  -- 03: T left

    { {  0, -1 }, {  0,  0 }, { -1,  1 }, {  0,  1 }, },  -- 04: J left
    { { -1, -1 }, { -1,  0 }, {  0,  0 }, {  1,  0 }, },  -- 05: J up
    { {  0, -1 }, {  1, -1 }, {  0,  0 }, {  0,  1 }, },  -- 06: J right
    { { -1,  0 }, {  0,  0 }, {  1,  0 }, {  1,  1 }, },  -- 07: J down (spawn)

    { { -1,  0 }, {  0,  0 }, {  0,  1 }, {  1,  1 }, },  -- 08: Z horizontal (spawn)
    { {  1, -1 }, {  0,  0 }, {  1,  0 }, {  0,  1 }, },  -- 09: Z vertical

    { { -1,  0 }, {  0,  0 }, { -1,  1 }, {  0,  1 }, },  -- 0A: O (spawn)

    { {  0,  0 }, {  1,  0 }, { -1,  1 }, {  0,  1 }, },  -- 0B: S horizontal (spawn)
    { {  0, -1 }, {  0,  0 }, {  1,  0 }, {  1,  1 }, },  -- 0C: S vertical

    { {  0, -1 }, {  0,  0 }, {  0,  1 }, {  1,  1 }, },  -- 0D: L right
    { { -1,  0 }, {  0,  0 }, {  1,  0 }, { -1,  1 }, },  -- 0E: L down (spawn)
    { { -1, -1 }, {  0, -1 }, {  0,  0 }, {  0,  1 }, },  -- 0F: L left
    { {  1, -1 }, { -1,  0 }, {  0,  0 }, {  1,  0 }, },  -- 10: L up

    { {  0, -2 }, {  0, -1 }, {  0,  0 }, {  0,  1 }, },  -- 11: I vertical
    { { -2,  0 }, { -1,  0 }, {  0,  0 }, {  1,  0 }, },  -- 12: I horizontal (spawn)
}

PLAYFIELDGRAPHICTABLE = {} -- graphics used in the playfield
PLAYFIELDGRAPHICTABLE[0xef] = "00" --empty
PLAYFIELDGRAPHICTABLE[0x7b] = "01" -- 1
PLAYFIELDGRAPHICTABLE[0x7d] = "10" -- 2
PLAYFIELDGRAPHICTABLE[0x7c] = "11" -- 3
