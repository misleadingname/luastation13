return function(path, options)
	options.linear = options.linear or false
	return love.graphics.newImage(path, options)
end
