require "variables"
require "dialog"
require "lib.websocket"
require "getters"
require "util"
local playfield = require "playfield"


local conn
function connect(url, cookie) -- called by the GUI
    local err
    conn, err = wsopen(url, cookie)
    if not conn then
        print("Connection failed: " .. err)
        return
    else
        print("Connected successfully!")
    end
end

local startTime = socket.gettime()*1000 -- questionable use of socket
local lastFrame = startTime
local gameNo = 0
local state = {}

function newGameStarted()
    print("Started a game")
    gameNo = gameNo + 1

    state = {
        pieceX = -1,
        pieceY = -1,
        pieceID = -1,
    }

    playfield.initialize()
end

playfield.initialize()

local bootStatus = getGameStatus()
if bootStatus >= 1 and bootStatus <= 10 then -- ingame when this script started
    newGameStarted()
end
local previousGameStatus = bootStatus



while true do
    local gameStatus = getGameStatus()
    local sendFrame = false
    local time = socket.gettime()*1000

    if gameStatus == 1 then -- piece active
        local stateChanged = false

        if previousGameStatus == 0 then -- just started a game!
            newGameStarted()
        end

        if previousGameStatus == 8 then -- line clear done
            playfield.invalidate()
            stateChanged = true
        end

        -- check if the state changed!
        -- ways the state can change in status 1:
        --     pieceX or pieceY changed (movement)
        --     currentPiece changes (rotation, piece entry)

        local pieceX, pieceY = getCurrentPosition()
        local pieceID = getCurrentPiece()

        if pieceX ~= state.pieceX or pieceY ~= state.pieceY or pieceID ~= state.pieceID then
            stateChanged = true
        end

        if stateChanged then
            sendFrame = true
            playfield.invalidate()
            playfield.update()

            -- update state cache
            state.pieceX = pieceX
            state.pieceY = pieceY
            state.pieceID = pieceID
        end

    elseif gameStatus == 4 or gameStatus == 6 then -- line clear
        if gameStatus == 4 and previousGameStatus ~= 4 then -- line clear go brrr
            playfield.lineClearAnimation(getLinesBeingCleared())
        end

        if playfield.lineClearUpdate() then
            sendFrame = true
        end

    elseif gameStatus == 5 then -- dummy frame, but we're abusing it for score update.
        sendFrame = true

    elseif gameStatus  == 10 then -- curtain + rocket
        if previousGameStatus ~= 10 then
            playfield.curtainNum = 0
        end

        if playfield.curtainUpdate() then
            playfield.invalidate()
            playfield.update()
            sendFrame = true
        end

    end

    -- send a frame every 5 seconds no matter what, to stop the connection from dying
    if time - lastFrame >= 5000 then -- 5 seconds
        sendFrame = true
    end

    if sendFrame then
        local ms = math.floor(time - startTime)
        local score = getScore()
        local lines = getLines()
        local level = getLevel()
        local preview = getNextPiece()

        local statistics = {}
        for i = 1, 7 do
            statistics[i] = getPieceStatistic(i)
        end

        local playfield = playfield.getBinaryString()

        local s = makeFrame(ms, score, lines, level, preview, playfield, gameNo, statistics)

        if conn then
            -- print("Sending frame! " .. math.random())
            wssend(conn, 2, s)
        end

        lastFrame = time
    end

    previousGameStatus = gameStatus

	emu.frameadvance()
end
