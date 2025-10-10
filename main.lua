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
	LS13.Logging.LogFatal("Unhandled error: %s %s", error, debug.traceback())
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
		require("love.keyboard")
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
			msaa = t.window.msaa,

			borderless = t.window.borderless,
			minheight = t.window.minheight,
			minwidth = t.window.minwidth,
		})

		_G.iconPath = t.window.icon
		love.window.setTitle(t.window.title)
	end

	_G.LS13 = runMode == "server" and require("server") or require("client")
	LS13.Info = require("info")
	LS13.Role = runMode
	LS13.LaunchArgs = args

	local head = (love.filesystem.read(".git/refs/heads/master") or ""):gsub("\n", "")
	local branch = (love.filesystem.read(".git/HEAD") or ""):gsub("^ref: .*/", ""):gsub("\n", "")
	if branch == "" then branch = nil end
	if head == "" then head = nil end

	print(
		string.format(
			"Running %s/%s %s@%s %s w/ %s",
			LS13.Info.Name,
			LS13.Info.Ident,
			LS13.Info.Version,
			branch and "(" .. branch .. "/" .. head .. ")" or "off-git, release",
			"(find out love2d version somehow)",
			_VERSION
		)
	)
	xpcall(function()
		shared.load()
		LS13.load()
	end, handleError)
end

function love.update(dt)
	LS13.preframe() -- only for fps capping, for the love of god do not make it error
	xpcall(function()
		shared.update(dt)
		LS13.update(dt)
	end, handleError)
	if SERVER then
		LS13.postframe() -- only for fps capping on server
	end
end
