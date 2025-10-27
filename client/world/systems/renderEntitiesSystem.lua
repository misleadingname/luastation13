local renderEntitiesSystem = LS13.ECSManager.system({ pool = { "Transform", "Renderer" } })

function renderEntitiesSystem:draw(z)
	for _, ent in ipairs(self.pool) do
		local trans = ent.Transform

		if trans.z ~= z then
			continue
		end

		local rend = ent.Renderer

		if not rend.visible then
			continue
		end

		if ent.Graphic then
			local graphicId = ent.Graphic.graphicId
			local graphic = LS13.AssetManager.Get()
			local origin = ent.Graphic.origin

			love.graphics.draw(
				graphic.image,
				-- the viewport will use pixels and not world units
				trans.position.x * 32,
				trans.position.y * 32,
				trans.rotation,
				trans.scaleX,
				trans.scaleY,
				origin.x,
				origin.y
			)
		end
	end
end

LS13.ECS.Systems.RenderEntitiesSystem = renderEntitiesSystem
