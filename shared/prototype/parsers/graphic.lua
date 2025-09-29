local GraphicType = {
	Static = "static",
	Animated = "animated"
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
		fps = node.FPS or 10,
		loopDelay = node.LoopDelay or 0,
	}

	LS13.AssetManager.Push(data, data.id)
end
