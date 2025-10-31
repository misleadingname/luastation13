local cameraSystem = LS13.ECSManager.system({ pool = { "Transform", "Sentience" } })

function cameraSystem:update(z)
	for _, ent in ipairs(self.pool) do
		if ent.Sentience.clientId == LS13.Networking.getClientId() then
			local trans = ent.Transform
			LS13.StateManager.currentState.camX = trans.position.x
			LS13.StateManager.currentState.camY = trans.position.y
			LS13.StateManager.currentState.camZ = trans.z
		end
	end
end

LS13.ECS.Systems.CameraSystem = cameraSystem
