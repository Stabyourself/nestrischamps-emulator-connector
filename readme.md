## What
A lua script for FCEUX, Mesen, and Bizhawk that grabs frame data directly from the emulator using memory readouts and then sends it to https://github.com/timotheeg/nestrischamps for cool rendering stuff.

Can easily be ported to other emulators that support Lua scripting.

## Why
Because OCR is slow and unnecessary for emulators.

## How
### FCEUX
- Extract to FCEUX/luaScripts
- Run FCEUX, run Tetris
- Go to File -> Lua -> New Lua Script Window
- Browse to FCEUX/luaScripts/nestrischamps.lua
- Hit run
- Enter the websocket URL and your cookie

### Mesen
- Extract to Mesen/lua, creating the folder if it doesn't exist
- Copy Mesen/lua/nestrischamps/environment.lua.example to Mesen/lua/nestrischamps/environment.lua
- Edit the file you just copied, putting your cookie into the DEFAULTCOOKIE string
- Run Mesen, run Tetris
- Go to Debug -> Script Window
- Go to File -> Open and browse to Mesen/lua/nestrischamps.lua

### Bizhawk
- Extract to Bizhawk/Lua
- Copy Bizhawk/Lua/nestrischamps/environment.lua.example to Bizhawk/Lua/nestrischamps/environment.lua
- Edit the file you just copied, putting your cookie into the DEFAULTCOOKIE string
- Run Bizhawk, run Tetris
- Go to Tools -> Lua Console
- Go to Script -> Open Script and browse to Bizhawk/Lua/nestrischamps.lua

If it worked, it should say "Connected successfully!". You can then go to your renderer (go to https://nestrischamps.herokuapp.com/renderers and select Simple 1p) and it should display any game you start.

To find your cookie, you can go to your browser's devtools while on the NestrisChamps website. You'll find Cookies in the "Application" tab in webkit and the "Storage" tab in Firefox. It looks something like `s%3A...`
