local tilemapSystem = LS13.ECSManager.system({ pool = { "World" } })

function tilemapSystem:draw()
	local worldEnt = self.pool[1]

	-- draw worldEnt.World.tilemap here
end

LS13.ECS.Systems.TilemapSystem = tilemapSystem
