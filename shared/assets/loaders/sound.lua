return function(path, options)
	return love.audio.newSource(path, options and options.mode or "static")
end
