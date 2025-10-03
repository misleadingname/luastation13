local LoadingState = LS13.StateManager.new("Loading")

local splash = love.graphics.newImage("/resources/textures/core/splash.png")
local frame = 0

function LoadingState:enter()
end

function LoadingState:update(dt)
	frame = frame + 1
	if frame == 1 then
		LS13.PrototypeManager.ParseAll()

		if DEBUG then
			LS13.Console.init()
			LS13.DebugOverlay.init()
		end

		local splashes = LS13.AssetManager.GetPrefixed("String.Splash")
		local splash = splashes[math.random(1, #splashes)]
		local title = love.window.getTitle()

		love.window.setTitle(string.format("%s: %s", title, splash.value))
		LS13.StateManager.switchState("Menu")
	elseif frame == 2 then
		Crash("failed to change states")
	end
end

function LoadingState:draw()
	local w, h = splash:getDimensions()
	local sx, sy = love.graphics.getDimensions()
	local scale = math.min(math.min(sx / w, sy / h) * 0.8, .75)

	love.graphics.draw(splash, sx / 2 - w / 2 * scale, sy / 2 - h / 2 * scale, 0, scale, scale)
end

return LoadingState
