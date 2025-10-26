local interactionSystem = LS13.ECSManager.system({ pool = { "Interactable" } })

function interactionSystem:init(world)
	self.world = world
end

function interactionSystem:handleInteraction(entity, interactionName, actor, data)
	local handler = LS13.InteractionSystem.getHandler(interactionName)
	if not handler then
		return false, "Unknown interaction"
	end

	local valid, error = handler:validate(entity, actor, data)
	if not valid then
		return false, error
	end

	if handler.canPerform and not handler:canPerform(entity, actor) then
		return false, "Cannot perform interaction"
	end

	return handler:execute(entity, actor, data)
end

LS13.ECS.Systems.InteractionSystem = interactionSystem

