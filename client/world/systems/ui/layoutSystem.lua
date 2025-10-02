local layoutSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTransform" } })

function layoutSystem:update()
    local sorted = {}
    for _, ent in ipairs(self.pool) do
        LS13.Logging.LogDebug("%s: %s", ent.UiElement.parent, ent)
        table.insert(sorted, ent)
    end
end

LS13.ECS.Systems.UiLayoutSystem = layoutSystem
