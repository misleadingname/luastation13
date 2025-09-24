_G.lume = require("lib/lume/lume") -- needed for lurker
local lurker = require("lib/lurker/lurker")

local shared = {}

function shared.load(args)
	print("whats up im the shared yo")
	math.randomseed(os.time())

	CLIENT = LS13.Role == "client"
	SERVER = LS13.Role == "server"
	DEBUG = args[2] == "debug"

	if CLIENT and SERVER then -- let's prevent a disaster
		error("what kind of evil ass magic did you manage to put on this cursed land to make this happen...")
	end

	LS13.PrototypeManager = require("shared/prototype")
	LS13.AssetManager = require("shared/assetmanager")
	LS13.Util = require("shared/utilities")
end

function shared.update(dt)
	lurker.update()

	if LS13.AssetManager.Loader then
		LS13.AssetManager.Loader.Update(dt, 8)
	end
end

return shared
