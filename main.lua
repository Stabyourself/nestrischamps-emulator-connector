require "variables"
require "dialog"
require "lib.websocket"
require "getters"
require "util"
local frameManager = require "frameManager"
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
    local time = socket.gettime()*1000

    local newFrame = false
    local resendFrame = false

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
            -- ways the state can change in pieceState 1:
            --     pieceX or pieceY changed (movement)
            --     currentPiece changes (rotation, piece entry)

            local pieceX, pieceY = getCurrentPosition()
            local pieceID = getCurrentPiece()

            if pieceX ~= state.pieceX or pieceY ~= state.pieceY or pieceID ~= state.pieceID then
                stateChanged = true
            end

            if stateChanged then
                newFrame = true
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
                newFrame = true
            end

        elseif pieceState == 5 then -- dummy frame, but we're abusing it for score update.
            newFrame = true

        elseif pieceState  == 10 then -- curtain + rocket
            if previousPieceState ~= 10 then
                playfield.curtainNum = 0
            end

            if playfield.curtainUpdate() then
                playfield.invalidate()
                playfield.update()
                newFrame = true
            end

        end
    end



    -- send a frame every 5 seconds no matter what, to stop the connection from dying
    if time - lastFrame >= 5000 then -- 5 seconds
        local resendFrame = true
    end

    if (newFrame or resendFrame) and conn then
        -- print("Sending frame! " .. math.random())

        if newFrame then
            frameManager.update(math.floor(time - startTime), gameNo)
        end

        wssend(conn, 2, frameManager.frame)

        lastFrame = time
    end

    previousPieceState = pieceState
    previousGameState = gameState

	emu.frameadvance()
end
