return function(node)
	local data = {
		id = node._attr and node._attr.Id and node._attr.Id,
		type = "sound",

		fileName = node.FileName or "resources/sound/core/error.ogg",
		soundMode = node.SoundMode or "static",
		catagory = node.Catagory,
		looping = node.Looping == "true",
		volume = node.Volume or 1.0,

		name = node.Name,
		author = node.Author,
	}

	if data.soundMode == "static" then
		local sndData = LS13.AssetManager.Loader.Load(data.fileName)

		data.soundData = sndData
	end

	LS13.AssetManager.Push(data, data.id)
end
