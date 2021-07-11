require("iuplua")

local dialog

local defaultUrl = DEFAULTURL or "ws://nestrischamps.herokuapp.com/ws/room/producer"
local defaultCookie = DEFAULTCOOKIE or ""

local urlInput = iup.text{size="400x",value=defaultUrl}
local cookieInput = iup.text{size="400x",value=defaultCookie}

local function closeDialog()
    if dialog then
        dialog:destroy()
        dialog = nil
    end
end

local function onConnect()
    local url = urlInput.value
    local cookie = cookieInput.value

    closeDialog()

    connect(url, cookie)
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
                    iup.label{title="Cookie"},
                    cookieInput,
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

function showDialog()
    dialog:show()
end
