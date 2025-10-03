_G.lume = require("lib.lume.lume") -- needed for lurker
local lurker = require("lib.lurker.lurker")

function HandleError(error)
	if not LS13.Logging then
		print("[LOGGER FAIL] Unhandled error: " .. error .. "\n" .. debug.traceback())
	else
		LS13.Logging.LogFatal("Unhandled error: %s %s", error, debug.traceback())
	end
end

function Crash(reason)
	error(string.format("SOOOD!!! (crash) %s", reason))
end

local shared = {}

function shared.load()
	print("whats up im the shared yo")
	math.randomseed(os.time())

	CLIENT = LS13.Role == "client"
	SERVER = LS13.Role == "server"

	if CLIENT and SERVER then -- let's prevent a disaster
		error("what kind of evil ass magic did you manage to put on this cursed land to make this happen...")
	end

	LS13.PrototypeManager = require("shared.prototype")
	LS13.AssetManager = require("shared.assets.manager")
	LS13.StateManager = require("shared.states")
	LS13.ECSManager = require("lib.concord")
	LS13.Logging = require("shared.logging")
	LS13.Util = require("shared.utilities")
	LS13.ECS = {
		Components = {},
		Systems = {},
	}

	require("shared.math")
	require("shared.world")

	if love.filesystem.isFused() then
		local dir = love.filesystem.getSourceBaseDirectory()
		dir = dir:gsub("\\", "/")
		LS13.Logging.LogInfo("Source Base Directory: %s", dir)

		local path = dir .. "/resources"
		local info = love.filesystem.getInfo(path, "directory")
		LS13.Util.PrintTable(info)

		LS13.Logging.LogDebug("Fused! Mounting resource directory: %s", path)
		local mounted = love.filesystem.mount(path, "resources")
		if not mounted then
			LS13.Logging.LogFatal("Failed to mount resource directory")
			love.event.quit(1)
		end
	end

	LS13.Logging.LogDebug(LS13.Util.Gilb())
	DEBUG = LS13.Util.GetArgument("debug")

	LS13.Logging.LogLevel = DEBUG and 0 or 1
	LS13.Logging.LogInfo("Init done in %ss!", os.clock())
end

function shared.update(dt)
	LS13.PrototypeManager.UpdateWatchdog()
	lurker.update()
end

return shared
