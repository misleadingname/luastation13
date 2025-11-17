_G.lume = require("lib.lume.lume")
_G.bit = require("bit")
_G.utf8 = require("utf8")

function HandleError(error)
	if not LS13.Logging then
		print("[LOGGER FAIL] Unhandled error: " .. error .. "\n" .. debug.traceback())
	else
		LS13.Logging.LogFatal("Unhandled error: %s %s", error, debug.traceback())
	end
end

local shared = {}

function shared.load()
	math.randomseed(os.time())

	CLIENT = LS13.Role == "client"
	SERVER = LS13.Role == "server"

	if CLIENT and SERVER then -- let's prevent a disaster
		error("what kind of evil ass magic did you manage to put on this cursed land to make this happen...")
	end

	LS13.Util = require("shared.utilities")
	DEBUG = LS13.Util.GetArgument("debug")

	LS13.PrototypeManager = require("shared.prototype")
	LS13.AssetManager = require("shared.assets.manager")
	LS13.StateManager = require("shared.states")
	LS13.ECSManager = require("lib.concord")
	LS13.Logging = require("shared.logging")
	LS13.ECS = {
		Replication = {},
		Components = {},
		Systems = {},
	}

	require("shared.consts")
	require("shared.math")
	require("shared.world")

	if love.filesystem.isFused() then
		local dir = love.filesystem.getSourceBaseDirectory()
		dir = dir:gsub("\\", "/")
		LS13.Logging.LogInfo("Source Base Directory: %s", dir)

		local path = dir .. "/resources"
		LS13.Logging.LogDebug("Fused! Mounting resource directory: %s", path)
		local mounted = love.filesystem.mountFullPath(path, "resources")
		if not mounted then
			LS13.Logging.LogFatal("Failed to mount resource directory")
			love.event.quit(1)
		end
	end

	LS13.Logging.LogDebug(LS13.Util.Gilb())
	LS13.Logging.LogInfo("Init done in %ss!", os.clock())
end

function shared.update(dt)
	LS13.PrototypeManager.UpdateWatchdog()
end

return shared
