local parentSystem = LS13.ECSManager.system({ pool = { "UiElement" } })

function parentSystem:update()
	for _, entity in ipairs(self.pool) do
		entity.UiElement.children = {}
	end

	for _, entity in ipairs(self.pool) do
		local element = entity.UiElement
		if element.parent then
			if element.parent.UiElement then
				table.insert(element.parent.UiElement.children, entity)
			end
		end
	end
end

LS13.ECS.Systems.UiParentSystem = parentSystem
