local textFieldSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTextField", "UiTarget" } })

function textFieldSystem:initalize()
end

function textFieldSystem:update(dt)
	for i = #self.pool, 1, -1 do
		local ent = self.pool[i]
		local field = ent.UiTextField
		local label = ent.UiLabel

		if label then
			label.text = field.value
		end
	end
end

LS13.ECS.Systems.UiTextFieldSystem = textFieldSystem
