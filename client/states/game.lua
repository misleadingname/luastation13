local GameState = LS13.StateManager.new("Game")

local viewportCanvas
local worldCanvas

-- TODO: make the background use Location prototypes when they exist
local bgSpace1
local bgSpace2
local bgSpace3

function GameState:enter()
	bgSpace1 = LS13.AssetManager.Get("Graphic.BG.SpaceLayer1").image
	bgSpace2 = LS13.AssetManager.Get("Graphic.BG.SpaceLayer2").image
	bgSpace3 = LS13.AssetManager.Get("Graphic.BG.SpaceLayer3").image

	-- TODO: move this to a function so it can be ran whenever the viewport needs to be rescaled
	local vpScale = 1 -- TODO: use setting or something idk

	viewportCanvas = love.graphics.newCanvas(VIEWPORT_WIDTH * vpScale, VIEWPORT_HEIGHT * vpScale)
	worldCanvas = love.graphics.newCanvas(VIEWPORT_WIDTH * vpScale, VIEWPORT_HEIGHT * vpScale)
	-- END TODO
end

function GameState:update(dt) end

function GameState:draw()
	local world

	if LS13.WorldManager then
		world = LS13.WorldManager.getCurrentWorld()
	end

	if not world then
		return
	end

	local worldEnt = world:getEntities()[1] -- TODO: misname make this work

	local zMin = worldEnt.zMin
	local zMax = worldEnt.zMax

	local vpWidth, vpHeight = viewportCanvas:getPixelDimensions()

	local vpScale = 1 -- TODO: use setting or something idk

	local camX = 0
	local camY = 0
	local camZ = 0
	local camZoom = 1

	love.graphics.setCanvas(worldCanvas)

	love.graphics.clear(0, 0, 0, 0)

	for z = zMin, camZ, 1 do
		local cameraTransform = love.math.newTransform()

		cameraTransform:translate(-vpWidth / 2 - camX, -vpHeight / 2 - camY)
		cameraTransform:scale(camZoom * vpScale, camZoom * vpScale)

		love.graphics.applyTransform(cameraTransform)

		world:emit("draw", z)

		if DEBUG then
			love.graphics.setColor(1, 0, 0)
			love.graphics.line(-32, 0, 32, 0)

			love.graphics.setColor(0, 1, 0)
			love.graphics.line(0, -32, 0, 32)
		end

		love.graphics.applyTransform(love.math.newTransform())

		-- depth effect
		if z ~= camZ then
			love.graphics.setBlendMode("multiply")
			love.graphics.setColor(0.9, 0.9, 0.9, 1)
			love.graphics.rectangle("fill", 0, 0, vpWidth, vpHeight)
			love.graphics.setBlendMode("alpha")
		end
	end

	love.graphics.setCanvas(viewportCanvas)

	local bgX, bgY = -camX, -camY

	-- TODO: use location prototype based background
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setBlendMode("alpha")
	love.graphics.draw(
		bgSpace1,
		love.graphics.newQuad(bgX / 2.5 - vpWidth / 2, bgY / 2.5 - vpHeight / 2, vpWidth, vpHeight, 480, 480)
	)
	love.graphics.setBlendMode("add")
	love.graphics.draw(
		bgSpace2,
		love.graphics.newQuad(bgX / 1.5 - vpWidth / 2, bgY / 1.5 - vpHeight / 2, vpWidth, vpHeight, 480, 480)
	)
	love.graphics.draw(
		bgSpace3,
		love.graphics.newQuad(bgX / 1.0 - vpWidth / 2, bgY / 1.0 - vpHeight / 2, vpWidth, vpHeight, 480, 480)
	)
	love.graphics.setBlendMode("alpha")
	-- END TODO

	love.graphics.draw(worldCanvas, 0, 0)

	love.graphics.setCanvas()

	love.graphics.draw(viewportCanvas, 0, 0) -- TODO: move to ui
end

function GameState:exit() end

return GameState
