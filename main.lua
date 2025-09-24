require("conf")
local shared = require("shared")

function love.load(args, unfiltered)
	local runMode = "client"
	if args[1] == "server" then
		runMode = "server"
	end

	if runMode == "client" then -- setup window
		require("love.window")
		local t = { modules = {}, audio = {}, window = {} }
		love.conf(t)

		love.window.setMode(t.window.width, t.window.height, {
			usedpiscale = t.window.usedpiscale,
			fullscreen = t.window.fullscreen,
			resizable = t.window.resizable,
			display = t.window.display,
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

	shared.load(args)
	LS13.load(args)
end

function love.update(dt)
	shared.update(dt)
	LS13.update(dt)
end
