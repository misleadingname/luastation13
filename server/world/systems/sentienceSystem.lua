local sentienceSystem = LS13.ECSManager.system({ pool = { "Sentience" } })

function sentienceSystem:playerCommand(id, cmd)
	for _, ent in ipairs(self.pool) do
		local sentience = ent.Sentience
		if sentience.clientId ~= id or not sentience.inputEnabled then continue end

		sentience.playerCommand = cmd
	end
end

LS13.ECS.Systems.SentienceSystem = sentienceSystem

local basicTempCharSystem = LS13.ECSManager.system({ pool = { "BasicTempCharacter", "Transform", "Sentience", "Replicated" } })

function basicTempCharSystem:update(dt)
	for _, ent in ipairs(self.pool) do
		local transform = ent.Transform
		local sentience = ent.Sentience
		local graphic = ent.Graphic

		transform.rotation += dt * 4
		transform.scale = Vector2.new(math.sin(love.timer.getTime() * 2) + 1, math.cos(love.timer.getTime() * 2) + 2)
		graphic.tint = Color.fromHSV(love.timer.getTime() * 360, 1, 1)

		local cmd = sentience.playerCommand
		if not cmd then continue end

		transform.position += cmd.moveDirection * dt * 16
	end
end

LS13.ECS.Systems.BasicTempCharSystem = basicTempCharSystem
