local layoutSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTransform" } })

function layoutSystem:update()
    for _, ent in ipairs(self.pool) do
        LS13.Logging.LogDebug("%s", ent.UiElement.parent)
    end
end

LS13.ECS.Systems.UiLayoutSystem = layoutSystem
