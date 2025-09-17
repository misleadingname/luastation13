_G.lume = require("lib/lume/lume") -- needed for lurker
local lurker = require("lib/lurker/lurker")

local shared = {}

function shared.load()
	print("whats up im the shared yo")
	math.randomseed(os.time())

	CLIENT = NS17.Role == "client"
	SERVER = NS17.Role == "server"

	if CLIENT and SERVER then -- let's prevent a disaster
		error("what kind of evil ass magic did you manage to put on this cursed land to make this happen...")
	end

	NS17.AssetManager = require("shared/assetmanager")
end

function shared.update(dt)
	lurker.update()

	if NS17.AssetManager then
		NS17.AssetManager.Update(dt, 8)
	end
end

return shared
