memory = {}

function memory.readbyte(address)
    return emu.read(address, emu.memType.cpuDebug)
end

function print(...)
    emu.log(...)
end

function onLoad()
    connect(DEFAULTURL, DEFAULTSECRET)

    emu.addEventCallback(loop, emu.eventType.endFrame) -- main loop
end
