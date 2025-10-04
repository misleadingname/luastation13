local targettingSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTransform", "UiTarget" } })

function targettingSystem:update(dt)
	local cursor = LS13.UI.cursor

	local hoveredEnt

	for i = #self.pool, 1, -1 do
		local ent = self.pool[i]
		local trans = ent.UiTransform
		local target = ent.UiTarget

		local lc, rc = trans.cpos, trans.cpos + trans.csize -- left top corner, right bottom corner

		if
			cursor.position.x >= lc.x
			and cursor.position.x <= rc.x
			and cursor.position.y >= lc.y
			and cursor.position.y <= rc.y
		then
			hoveredEnt = ent
			break
		end
	end

	for _, ent in ipairs(self.pool) do
		local target = ent.UiTarget

		target.hovered = ent == hoveredEnt
	end
end

function targettingSystem:press(button)
	for _, ent in ipairs(self.pool) do
		local target = ent.UiTarget

		if target.hovered then
			target.selected = true
		end
	end
end

function targettingSystem:release(button)
	for _, ent in ipairs(self.pool) do
		local target = ent.UiTarget

		if target.hovered then
			target.selected = false
			target.onClick(button)
		end
	end
end

function targettingSystem:draw()
	if not DEBUG then
		return
	end

	for _, ent in ipairs(self.pool) do
		local trans = ent.UiTransform
		local target = ent.UiTarget

		local lc, rc = trans.cpos, trans.cpos + trans.csize

		love.graphics.rectangle("line", lc.x, lc.y, rc.x - lc.x, rc.y - lc.y)
		if target.hovered then
			love.graphics.rectangle("fill", lc.x, lc.y, rc.x - lc.x, rc.y - lc.y)
		end
	end
end

LS13.ECS.Systems.UiTargettingSystem = targettingSystem
