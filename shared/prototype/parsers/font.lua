return function(node)
	local data = {
		id = node._attr and node._attr.Id and node._attr.Id,
		type = "font",

		fileName = node.FileName and node.FileName or "/resources/fonts/verdana.ttf",
		filter = node.Filter and node.Filter or "nearest",
		size = node.Size and tonumber(node.Size) or 16,
	}

	local font
	if SERVER then
		font = nil
	else
		font = love.graphics.newFont(data.fileName, data.size)
		font:setFilter(data.filter, data.filter)
	end

	data.font = font
	LS13.AssetManager.Push(data, data.id)
end
