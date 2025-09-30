local ecs = LS13.ECSManager

local graphicsRenderSystem = ecs.system({ pool = { "Transform", "Graphic" } })

LS13.ECS.Systems.GraphicsRenderSystem = graphicsRenderSystem
