local GraphicType = {
	Static = "static",
	Animated = "animated",
	NineSlice = "nineSlice",
	Directional = "directional",
}

return function(node)
	local data = {
		id = node._attr and node._attr.Id and node._attr.Id,
		type = "graphic",

		fileName = node.FileName or "resources/textures/core/error.png",
		graphicType = GraphicType[node._attr.Type] or GraphicType.Static,
		frameWidth = node.FrameWidth or 32,
		frameHeight = node.FrameHeight or 32,

		frameCount = node.FrameCount or 1,
		loopDelay = node.LoopDelay or 0,
		fps = node.FPS or 10,
	}

	local img = LS13.AssetManager.Loader.Load(data.fileName)

	data.image = img
	LS13.AssetManager.Push(data, data.id)
end
