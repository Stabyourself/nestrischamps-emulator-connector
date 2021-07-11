require("iuplua")

local dialog

local defaultUrl = "ws://nestrischamps.herokuapp.com/ws/room/producer"

local defaultCookie = "nsid="

local urlInput = iup.text{size="400x",value=defaultUrl}
local cookieInput = iup.text{size="400x",value=defaultCookie}

local function onConnect()
    local url = urlInput.value
    local cookie = cookieInput.value

    dialog:destroy()
    dialog = nil

    connect(url, cookie)
end

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

dialog:show()
