local clientInit = require("/client")
local serverInit = require("/server")

Shared = require("/shared")

function love.load(args, unfiltered)
	local runMode = "client"
	if args[1] == "server" then
		runMode = "server"
	end

	_G.LS13 = runMode == "server" and serverInit or clientInit
	LS13.Role = runMode

	Shared.load(args)
	LS13.load(args)
end	

function love.update(dt)
	Shared.update(dt)
	LS13.update(dt)
end