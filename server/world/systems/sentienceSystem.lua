local sentienceSystem = LS13.ECSManager.system({ pool = { "Sentience" } })

function sentienceSystem:playerCommand(id, cmd)
	for _, ent in ipairs(self.pool) do
		local sentience = ent.Sentience
		if sentience.clientId ~= id or not sentience._inputEnabled then continue end

		sentience._playerCommand = cmd
	end
end

LS13.ECS.Systems.SentienceSystem = sentienceSystem

local basicTempCharSystem = LS13.ECSManager.system({ pool = { "BasicTempCharacter", "Transform", "Sentience", "Replicated" } })

function basicTempCharSystem:update(dt)
	for _, ent in ipairs(self.pool) do
		local transform = ent.Transform
		local sentience = ent.Sentience
		local replicated = ent.Replicated

		local cmd = sentience._playerCommand
		if not cmd then continue end

		transform.position += cmd.MoveDirection * dt * 4
		replicated.dirty = true
	end
end

LS13.ECS.Systems.BasicTempCharSystem = basicTempCharSystem
