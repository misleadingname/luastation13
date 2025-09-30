local GraphicType = {
	Static = "static",
	Animated = "animated",
	NineSlice = "nineSlice",
}

return function(node)
	local data = {
		id = node._attr and node._attr.Id and node._attr.Id,
		type = "graphic",

		fileName = node.FileName or "resources/textures/core/default.png",
		graphicType = GraphicType[node._attr.Type] or GraphicType.Static,
		frameWidth = node.FrameWidth or 32,
		frameHeight = node.FrameHeight or 32,

		frameCount = node.FrameCount or 1,
		loopDelay = node.LoopDelay or 0,
		fps = node.FPS or 10,
	}

	local img
	local success, err = pcall(function()
		img = love.graphics.newImage(data.fileName, { linear = false })
	end)

	if not success then
		LS13.Logging.LogError("Failed to load image %s: %s, falling back.", data.fileName, err)
		img = love.graphics.newImage("resources/textures/core/default.png")
	end

	data.image = img
	LS13.AssetManager.Push(data, data.id)
end
