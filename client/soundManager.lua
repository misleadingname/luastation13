local soundManager = {}

function soundManager.NewSource(id)
	local source
	local data = LS13.AssetManager.Get(id)

	if data.soundMode == "static" then
		source = love.audio.newSource(data.soundData, data.soundMode)
	else
		source = love.audio.newSource(data.fileName, data.soundMode)
	end

	source:setVolume(data.volume)
	source:setLooping(data.looping)

	return source
end

return soundManager
