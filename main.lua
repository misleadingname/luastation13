local shared = require("shared")
require("conf")

local function help()
	local name = (love.filesystem.getSource()):match("(%w+)/?$")

	print(string.format("%s [help/server/client] [args]", name))
	print("argument reference:")
	print("\t--debug - runs in debug mode")

	print()
	love.event.quit(0)
end

local function handleError(error)
	LS13.Logging.PrintFatal(string.format("Unhandled error: %s %s", error, debug.traceback()))
end

function love.load(args)
	local runMode = "client"
	if args[1] == "server" then
		runMode = "server"
	elseif args[1] == "help" then
		help()
		return
	end

	if runMode == "client" then -- setup window
		require("love.window")
		local t = { modules = {}, audio = {}, window = {}, graphics = {} }
		love.conf(t)

		love.window.setMode(t.window.width, t.window.height, {
			usedpiscale = t.window.usedpiscale,
			fullscreen = t.window.fullscreen,
			resizable = t.window.resizable,
			displayindex = t.window.displayindex,
			depth = t.window.depth,
			vsync = t.window.vsync,
			stencil = t.window.stencil,
			highdpi = t.window.highdpi,
			msaa = t.window.msaa,

			borderless = t.window.borderless,
			minheight = t.window.minheight,
			minwidth = t.window.minwidth,
		})

		love.window.setIcon(love.image.newImageData(t.window.icon))
		love.window.setTitle(t.window.title)
	end

	_G.LS13 = runMode == "server" and require("server") or require("client")
	LS13.Role = runMode
	LS13.LaunchArgs = args

	xpcall(function()
		shared.load(args)
		LS13.load(args)
	end, handleError)
end

function love.update(dt)
	xpcall(function()
		shared.update(dt)
		LS13.update(dt)
	end, handleError)
end
