return function(node)
	local data = {
		id = node._attr and node._attr.Id and node._attr.Id,
		type = "sound",

		fileName = node.FileName and node.FileName,
		soundMode = node.SoundMode and node.SoundMode,
		looping = node.Looping and node.Looping == "true",

		name = node.Name and node.Name,
		author = node.Author and node.Author
	}

	local snd = love.audio.newSource(data.fileName, data.soundMode)
	snd:setLooping(data.looping)

	data.sound = snd
	LS13.AssetManager.Push(data, data.id)
end
