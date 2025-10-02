local layoutSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTransform" } })

function layoutSystem:update()
	local unsorted = self.pool
	local progress = true
	local sorted = {}

	local function resolveNode(node)
		local parent = node.UiElement.parent
		if parent and not lume.find(sorted, parent) then return false end

		table.insert(sorted, node)
		return true
	end

	while #unsorted > 0 and progress do
		progress = false
		local remaining = {}
		for i, node in ipairs(unsorted) do
			if not resolveNode(node) then
				table.insert(remaining, node)
			else
				progress = true
			end
		end

		unsorted = remaining
	end

	for _, ent in ipairs(sorted) do
		local parent = ent.UiElement.parent
		if parent then
			if parent.UiLayout then
				-- TODO: layout
			else
				ent.UiTransform.cpos.x = parent.UiTransform.cpos.x + ent.UiTransform.position.x
				ent.UiTransform.cpos.y = parent.UiTransform.cpos.y + ent.UiTransform.position.y
			end
		else
			ent.UiTransform.cpos.x = ent.UiTransform.position.x
			ent.UiTransform.cpos.y = ent.UiTransform.position.y
		end
	end

	for _, ent in ipairs(sorted) do
		LS13.Logging.LogDebug("%s <- %s", ent.UiTransform.cpos,
			ent.UiElement.parent and ent.UiElement.parent.UiTransform.cpos or nil)
	end
end

LS13.ECS.Systems.UiLayoutSystem = layoutSystem
