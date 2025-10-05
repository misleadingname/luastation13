return function(path)
	local data
	local success, err = pcall(function()
		data = love.sound.newSoundData(path)
	end)

	if not success then
		LS13.Logging.LogError(string.format("Failed to load sound: %s %s", path, err))
		data = love.sound.newSoundData("resources/sound/core/error.ogg")
	end

	return data
end
