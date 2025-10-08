local MenuState = LS13.StateManager.new("Menu")

local bgSpace1
local bgSpace2
local bgSpace3

local defaultFont

function MenuState:enter()
	defaultFont = LS13.AssetManager.Get("Font.Default").font
	bgSpace1 = LS13.AssetManager.Get("Graphic.BG.SpaceLayer1").image
	bgSpace2 = LS13.AssetManager.Get("Graphic.BG.SpaceLayer2").image
	bgSpace3 = LS13.AssetManager.Get("Graphic.BG.SpaceLayer3").image

	LS13.UI.test_scene()
end

function MenuState:update(dt)
end

function MenuState:draw()
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

	love.graphics.setFont(defaultFont)
	if music then
		love.graphics.print("Music: " .. music.name .. " by " .. music.author, 10, scrH - 40)
	end
end

return MenuState
