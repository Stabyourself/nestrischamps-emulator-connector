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
    gameNo = gameNo + 1
    print("Started game #" .. gameNo)

    state = {
        pieceX = -1,
        pieceY = -1,
        pieceID = -1,
    }

    playfield.initialize()
end

playfield.initialize()


local previousPieceState = -1
local previousGameState = -1


while true do
    local gameState = getGameState()
    local pieceState = getPieceState()
    local sendFrame = false
    local time = socket.gettime()*1000

    if gameState == 4 then --ingame, rocket, highscoreentry
        if previousGameState ~= 4 then -- just started a game!
            newGameStarted()
        end

        if pieceState == 1 then -- piece active
            local stateChanged = false

            if previousPieceState == 8 then -- line clear done
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

        elseif pieceState == 4 or pieceState == 6 then -- line clear
            if gameStatus == 4 and previousPieceState ~= 4 then -- line clear go brrr
                playfield.lineClearAnimation(getLinesBeingCleared())
            end

            if playfield.lineClearUpdate() then
                sendFrame = true
            end

        elseif pieceState == 5 then -- dummy frame, but we're abusing it for score update.
            sendFrame = true

        elseif pieceState  == 10 then -- curtain + rocket
            if previousPieceState ~= 10 then
                playfield.curtainNum = 0
            end

            if playfield.curtainUpdate() then
                playfield.invalidate()
                playfield.update()
                sendFrame = true
            end

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

    previousPieceState = pieceState
    previousGameState = gameState

	emu.frameadvance()
end
