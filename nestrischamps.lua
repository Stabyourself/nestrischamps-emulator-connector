-- find out which emu we're doing
-- this isn't optimal but I couldn't find a way to properly figure out the emu
local currentEmulator
if client then
    currentEmulator = "bizhawk"
elseif memory then
    currentEmulator = "fceux"
else
    currentEmulator = "mesen"
end

-- emulator specific GUI and tunnel stuff, all of them provide onLoad()
require("nestrischamps.emus." .. currentEmulator)
print("Detected " .. currentEmulator .. " emulator.")


require "nestrischamps.variables"
require "nestrischamps.lib.websocket"
require "nestrischamps.getters"
require "nestrischamps.util"
local frameManager = require "nestrischamps.frameManager"
local playfield = require "nestrischamps.playfield"
local socket = require "socket.core"


local conn
function connect(url, secret) -- called by the emu plugin file
    if not url or not secret then
        print("Settings not found. You need to set up an environment.lua for Mesen and Bizhawk, see environment.lua.example")
        error()
    end

    url = url .. "/" .. secret

    local err
    conn, err = wsopen(url)
    if not conn then
        print("Connection failed: " .. err)
        error()
    else
        print("Connected successfully!")

        if emu.registerexit then
            emu.registerexit(function()
                -- try our best to disconnect the socket on exit
                wsclose(conn)
            end)
        end
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


local DELAY_NEW_GAME_NUM_FRAMES = 1 -- num frames to wait before starting new game

local previousPieceState = -1
local previousGameState = -1
local numPendingFrames = -1

playfield.initialize()
frameManager.update(0, 0)

function loop()
    local gameState = getGameState()
    local pieceState = getPieceState()
    local time = socket.gettime()*1000

    local newFrame = false
    local resendFrame = false

    if gameState == 4 then --ingame, rocket, highscoreentry
        if previousGameState ~= 4 then -- possibly just started a game
            if numPendingFrames < 0 then
                -- Kinda gross delay before starting a new game :'(
                -- 1 frame delay is needed because gameState changes before the game data are reset
                -- We need to avoid sending one frame of old game data into the new game
                numPendingFrames = DELAY_NEW_GAME_NUM_FRAMES
            end

            numPendingFrames = numPendingFrames - 1

            if numPendingFrames < 0 then
                -- delay elapsed, start a new game
                newGameStarted()
            else
                -- delay ongoing, don't do anything
                return
            end
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
            if pieceState == 4 and previousPieceState ~= 4 then -- line clear go brrr
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
        resendFrame = true
    end

    if (newFrame or resendFrame) and conn then
        local ms = math.floor(time - startTime)

        if newFrame then
            frameManager.update(ms, gameNo)
            log("Sending new frame (" .. ms .. ")")
        elseif resendFrame then
            log("Resending an old frame.")
        end

        local success = wssend(conn, 2, frameManager.frame)
        --todo: something if not success (reconnect? hcf?)

        lastFrame = time
    end

    previousPieceState = pieceState
    previousGameState = gameState
end

onLoad()
