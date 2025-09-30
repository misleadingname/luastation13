return function(node)
    local data = {
        id = node._attr and node._attr.Id and node._attr.Id,
        type = "sound",

        fileName = node.FileName and node.FileName or "resources/sound/core/default.ogg",
        soundMode = node.SoundMode and node.SoundMode or "static",
        looping = node.Looping and node.Looping == "true",
        volume = node.Volume and node.Volume or 1.0,

        name = node.Name and node.Name,
        author = node.Author and node.Author
    }

    local snd = love.audio.newSource(data.fileName, data.soundMode)
    snd:setLooping(data.looping)
    snd:setVolume(data.volume)

    data.sound = snd
    LS13.AssetManager.Push(data, data.id)
end
