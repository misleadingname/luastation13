return function(path, options)
	local snd
	local success, err = pcall(function()
		snd = love.audio.newSource(path, options and options.mode or "static")
	end)

	if not success then
		LS13.Logging.LogError(string.format("Failed to load sound: %s %s", path, err))
		snd = love.audio.newSource("resources/sound/core/default.ogg", "static")
	end

	return snd
end
