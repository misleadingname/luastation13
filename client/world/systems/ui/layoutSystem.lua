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
end

LS13.ECS.Systems.UiLayoutSystem = layoutSystem
