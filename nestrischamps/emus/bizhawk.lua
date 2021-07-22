function onLoad()
    connect(DEFAULTURL, DEFAULTSECRET)

    while true do -- main loop
        loop()
	    emu.frameadvance()
    end
end
