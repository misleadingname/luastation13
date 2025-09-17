local clientInit = require("/client")
local serverInit = require("/server")

Shared = require("/shared")

function love.load(args)
	local runMode = "client"
	if args[1] == "server" then
		runMode = "server"
	end

	_G.NS17 = runMode == "server" and serverInit or clientInit

	Shared.load()
	NS17.load()
end

function love.update(dt)
	Shared.update(dt)
	NS17.update(dt)
end