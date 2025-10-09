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
	local viewportScale = 1 -- TODO: use setting or something idk

	viewportCanvas = love.graphics.newCanvas(VIEWPORT_WIDTH * viewportScale, VIEWPORT_HEIGHT * viewportScale)
	worldCanvas = love.graphics.newCanvas(VIEWPORT_WIDTH * viewportScale, VIEWPORT_HEIGHT * viewportScale)
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

	local worldEnt = world:getEntities()[1]

	local zMin = worldEnt.zMin
	local zMax = worldEnt.zMax

	local currentZ = 0 -- TODO: use player z

	local vpWidth, vpHeight = viewportCanvas:getPixelDimensions()

	love.graphics.setCanvas(worldCanvas)

	love.graphics.clear(0, 0, 0, 0)

	for z = zMin, currentZ, 1 do
		-- TODO: push camera transform here (scaled by depth and viewport scale)
		world:emit("draw", z)
		-- TODO: pop camera transform here
		-- depth effect
		if z ~= currentZ then
			love.graphics.setBlendMode("multiply")
			love.graphics.setColor(0.9, 0.9, 0.9, 1)
			love.graphics.rectangle("fill", 0, 0, vpWidth, vpHeight)
			love.graphics.setBlendMode("alpha")
		end
	end

	love.graphics.setCanvas(viewportCanvas)

	local bgX, bgY = 0, 0 -- be negative of camera x and y

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

	love.graphics.draw(worldCanvas, 0, 0)

	love.graphics.setCanvas()

	love.graphics.draw(viewportCanvas, 0, 0) -- TODO: move to ui
end

function GameState:exit() end

return GameState
