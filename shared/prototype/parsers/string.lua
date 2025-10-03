return function(node)
	local data = {
		id = node._attr and node._attr.Id and node._attr.Id,
		type = "string",

		value = node[1] or "<Empty String>",
	}

	LS13.AssetManager.Push(data, data.id)
end
