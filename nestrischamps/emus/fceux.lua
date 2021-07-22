require("iuplua")
local dialog

function createDialog()
    local defaultUrl = DEFAULTURL or "ws://nestrischamps.herokuapp.com/ws/room/producer"
    local defaultSecret = DEFAULTSECRET or ""

    local urlInput = iup.text{size="400x",value=defaultUrl}
    local secretInput = iup.text{size="400x",value=defaultSecret}

    local function closeDialog()
        if dialog then
            dialog:destroy()
            dialog = nil
        end
    end

    local function onConnect()
        local url = urlInput.value
        local secret = secretInput.value

        closeDialog()

        connect(url, secret)
    end

    -- close the dialog when the script ends
    emu.registerexit(closeDialog)

    dialog =
        iup.dialog{
            title="NestrisChamps config",
            iup.vbox{
                iup.hbox{
                    iup.vbox{
                        iup.label{title="Websocket URL (no ssl)"},
                        urlInput,
                        iup.label{title="Secret"},
                        secretInput,
                        iup.button{
                            title="Connect!",
                            action = function (self)
                                onConnect()
                            end
                        },
                    }
                },
                gap="5",
                alignment="ARIGHT",
                margin="5x5"
            } -- /vbox
        }

    dialog:show()
end

function onLoad()
    if AUTOCONNECT then
        connect(DEFAULTURL, DEFAULTSECRET)
    else
        createDialog()
    end

    while true do -- main loop
        loop()
	    emu.frameadvance()
    end
end
