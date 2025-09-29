_G.lume = require("lib/lume/lume") -- needed for lurker
local lurker = require("lib/lurker/lurker")

local shared = {}

function shared.load(args)
	print("whats up im the shared yo")
	math.randomseed(os.time())

	CLIENT = LS13.Role == "client"
	SERVER = LS13.Role == "server"

	if CLIENT and SERVER then -- let's prevent a disaster
		error("what kind of evil ass magic did you manage to put on this cursed land to make this happen...")
	end

	LS13.PrototypeManager = require("shared/prototype")
	LS13.AssetManager = require("shared/assetmanager")
	LS13.ECSManager = require("lib/concord")
	LS13.Logging = require("shared/logging")
	LS13.Util = require("shared/utilities")
	LS13.Logging.PrintDebug(LS13.Util.Gilb())

	DEBUG = LS13.Util.GetArgument("debug")

	LS13.Logging.PrintLevel = DEBUG and 0 or 1
	LS13.Logging.PrintInfo(string.format("Init done in %ss!", os.clock()))
end

function shared.update(dt)
	lurker.update()
end

return shared
