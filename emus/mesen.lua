-- environment.lua doesn't work yet
DEFAULTURL = "ws://nestrischamps.herokuapp.com/ws/room/producer"
DEFAULTCOOKIE = ""
LOGGING = false

memory = {}

function memory.readbyte(address)
    return emu.read(address, 0)
end

function print(...)
    emu.log(...)
end

function onLoad()
    connect(DEFAULTURL, DEFAULTCOOKIE)

    emu.addEventCallback(loop, emu.eventType.endFrame) -- main loop
end
