return function(path, options)
	local img

	options.linear = options.linear or false
	local success, err = pcall(function()
		img = love.graphics.newImage(path, options)
	end)

	if not success then
		LS13.Logging.LogError(string.format("Failed to load image: %s %s", path, err))
		img = love.graphics.newImage("resources/textures/core/error.png", { linear = false })
	end

	return img
end
