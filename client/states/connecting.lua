local ConnectingState = LS13.StateManager.new("Connecting")

local bgSpace1
local bgSpace2
local bgSpace3

function ConnectingState:enter()
	LS13.UI.clear()
	LS13.Networking.start(LS13.Networking.ConnectingIp)
end

function ConnectingState:update(dt)
end

function ConnectingState:draw()
	bgSpace1 = LS13.AssetManager.Get("Graphic.BG.SpaceLayer1").image
	bgSpace2 = LS13.AssetManager.Get("Graphic.BG.SpaceLayer2").image
	bgSpace3 = LS13.AssetManager.Get("Graphic.BG.SpaceLayer3").image

	local scrW, scrH = love.graphics.getDimensions()
	local time = love.timer.getTime()
	local bgX, bgY = time * 24, time * 6

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(
		bgSpace1,
		love.graphics.newQuad(bgX / 2.5 - scrW / 2, bgY / 2.5 - scrH / 2, scrW, scrH, 480, 480)
	)
	love.graphics.setBlendMode("add")
	love.graphics.draw(
		bgSpace2,
		love.graphics.newQuad(bgX / 1.5 - scrW / 2, bgY / 1.5 - scrH / 2, scrW, scrH, 480, 480)
	)
	love.graphics.draw(
		bgSpace3,
		love.graphics.newQuad(bgX / 1.0 - scrW / 2, bgY / 1.0 - scrH / 2, scrW, scrH, 480, 480)
	)
	love.graphics.setBlendMode("alpha")
end

function ConnectingState:exit() end

return ConnectingState
