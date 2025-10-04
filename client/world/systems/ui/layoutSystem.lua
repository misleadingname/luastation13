local layoutSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTransform" } })

function layoutSystem:update()
	-- sort the entities in such a way that the parent is always before the child
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

	-- update layout
	for _, ent in ipairs(sorted) do
		local trans = ent.UiTransform
		local parent = ent.UiElement.parent
		if parent then
			local parentTrans = ent.UiElement.parent.UiTransform
			if not parent.UiLayout then -- there's no layout moving for us
				trans.cpos.x = parentTrans.cpos.x + trans.position.x
				trans.cpos.y = parentTrans.cpos.y + trans.position.y
			end
		else
			trans.cpos.x = trans.position.x
			trans.cpos.y = trans.position.y
		end
	end

	-- -- debug print
	-- for _, ent in ipairs(sorted) do
	-- 	LS13.Logging.LogDebug("%s <- %s", ent.UiTransform.cpos,
	-- 		ent.UiElement.parent and ent.UiElement.parent.UiTransform.cpos or nil)
	-- end
end

LS13.ECS.Systems.UiLayoutSystem = layoutSystem
