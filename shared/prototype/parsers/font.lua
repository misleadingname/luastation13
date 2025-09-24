local sound = {}

function sound:Parse(node)
	local data = {
		id = node._attr and node._attr.Id and node._attr.Id,
		type = "font",

		fileName = node.FileName and node.FileName,
		size = node.Size and tonumber(node.Size) or 16,
	}

	local font = love.graphics.newFont(data.fileName, data.size)
	
	data.font = font
	LS13.AssetManager.Push(data, data.id)
end

return sound
