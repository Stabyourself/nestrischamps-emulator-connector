function onLoad()
    connect(DEFAULTURL, DEFAULTCOOKIE)

    while true do -- main loop
        loop()
	    emu.frameadvance()
    end
end
