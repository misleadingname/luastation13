local renderTilemapSystem = LS13.ECSManager.system({ pool = { "World" } })

function renderTilemapSystem:draw(z)
	local worldEnt = self.pool[1]
	local tilemap = worldEnt.World.tilemap

	-- TODO: draw tilemap at z here
end

LS13.ECS.Systems.RenderTilemapSystem = renderTilemapSystem
