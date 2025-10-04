local targettingSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTransform", "UiTarget" } })

function targettingSystem:update(dt)
	local cursor = LS13.UI.cursor

	for _, ent in ipairs(self.pool) do
		local trans = ent.UiTransform
		local target = ent.UiTarget

		local lc, rc = -- left top corner, right bottom corner
			trans.cpos, trans.cpos + trans.size

		if
			cursor.position.x >= lc.x
			and cursor.position.x <= rc.x
			and cursor.position.y >= lc.y
			and cursor.position.y <= rc.y
		then
			target.hovered = true
		else
			target.hovered = false
		end
	end
end

function targettingSystem:press(btn)
	for _, ent in ipairs(self.pool) do
		local target = ent.UiTarget

		if target.hovered then
			target.selected = true
		end
	end
end

function targettingSystem:release(btn)
	for _, ent in ipairs(self.pool) do
		local target = ent.UiTarget

		if target.hovered then
			target.selected = false
			target.onClick(btn)
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

		local lc, rc = trans.cpos, trans.cpos + trans.size

		love.graphics.rectangle("line", lc.x, lc.y, rc.x - lc.x, rc.y - lc.y)
		if target.hovered then
			love.graphics.rectangle("fill", lc.x, lc.y, rc.x - lc.x, rc.y - lc.y)
		end
	end
end

LS13.ECS.Systems.UiTargettingSystem = targettingSystem
