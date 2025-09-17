local LoadingState = {}

local splash = love.graphics.newImage("/resources/textures/core/splash.png")

function LoadingState:enter()
	NS17.AssetManager.LoadAssets("/resources")
end

function LoadingState:update(dt)
	local loading = NS17.AssetManager.IsLoading()
	local loaded = NS17.AssetManager.GetLoaded()
	local total = NS17.AssetManager.GetTotal()
	local errors = NS17.AssetManager.GetErrors()

	if not loading and total > 0 then
		local music = NS17.AssetManager.Get("resources/sound/music/lobby/endless_space.ogg")
		love.audio.play(music) -- test

		-- NS17.StateManager:setState(NS17.States.menu)
	end
end

function LoadingState:draw()
	local w, h = splash:getDimensions()
	local sx, sy = love.graphics.getDimensions()
	local scale = math.min(math.min(sx / w, sy / h) * 0.8, .75)

	love.graphics.draw(splash, sx / 2 - w / 2 * scale, sy / 2 - h / 2 * scale, 0, scale, scale)

	local loaded = NS17.AssetManager.GetLoaded()
	local total = NS17.AssetManager.GetTotal()

	if total > 0 then
		local progress = loaded / total
		local height = 8
		love.graphics.rectangle("fill", 0, sy - height, sx * progress, height)
	end
end

return LoadingState
