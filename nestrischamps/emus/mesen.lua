memory = {}

function memory.readbyte(address)
    return emu.read(address, emu.memType.nesDebug or emu.memType.cpuDebug) -- handle constants for both mesen 2 and 1
end

function memory.readbyterange(address, bytes)
    local str = ""
    for i = 0, bytes - 1 do
        local chr = string.char(memory.readbyte(address + i))
        str = str .. chr
    end
    return str
end

function print(...)
    emu.log(...)
end

function onLoad()
    connect(DEFAULTURL, DEFAULTSECRET)

    emu.addEventCallback(loop, emu.eventType.endFrame) -- main loop
end
