return function(node)
	local data = {
		id = node._attr and node._attr.Id and node._attr.Id,
		type = "tile",

		graphic = node.Graphic or "Graphic.Fallback",
	}

	LS13.AssetManager.Push(data, data.id)
end
