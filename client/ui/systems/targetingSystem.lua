local targettingSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTransform", "UiTarget" } })

local focusedEnt
local hoverSound
local pressSound

function targettingSystem:initalize()
	hoverSound = LS13.SoundManager.NewSource("Sound.UiHover")
	pressSound = LS13.SoundManager.NewSource("Sound.UiClick")
end

function targettingSystem:update(dt)
	local cursor = LS13.UI.cursor
	local hoveredEnt

	for i = #self.pool, 1, -1 do
		local ent = self.pool[i]
		local trans = ent.UiTransform
		local target = ent.UiTarget
		local lc, rc = trans.cpos, trans.cpos + trans.csize

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
		if not target.hovered and hoveredEnt == ent then
			hoverSound:play()
		end

		target.hovered = (ent == hoveredEnt)
		target.focused = (ent == focusedEnt)
	end
end

function targettingSystem:press(button)
	local hit = false

	for _, ent in ipairs(self.pool) do
		local target = ent.UiTarget

		if target.hovered then
			target._prevSelected = target.selected
			target._pressed = true
			focusedEnt = ent
			hit = true

			if target.toggle then
				target.selected = not target.selected
			else
				target.selected = true
			end
		end
	end

	if not hit then focusedEnt = nil end
end

function targettingSystem:release(button)
	for _, ent in ipairs(self.pool) do
		local target = ent.UiTarget

		if target._pressed then
			target._pressed = false

			if target.hovered then
				if not target.toggle then
					target.selected = false
				end

				if target.onClick then
					target.onClick(button)
				end
				pressSound:play()
			else
				target.selected = target._prevSelected
			end

			target._prevSelected = nil
		end
	end
end

function targettingSystem:draw()
	if not DEBUG then return end

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
