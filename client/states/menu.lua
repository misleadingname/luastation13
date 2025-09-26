local MenuState = {}

local bg
local lobbyMusic
local music

local defaultFont

local shuffledSongs = {}
local function rollSong()
	if #shuffledSongs == 0 then
		shuffledSongs = lume.shuffle(lume.clone(lobbyMusic))
	end

	music = table.remove(shuffledSongs)
	love.audio.play(music.sound)
end

function MenuState:enter()
	lobbyMusic = LS13.AssetManager.GetPrefixed("Music.Lobby")
	bg = love.graphics.newImage("/resources/textures/core/pepper.png")

	defaultFont = LS13.AssetManager.Get("Font.Default").font

	-- Initialize UI system
	LS13.UI.manager:setCurrentScene("menu")

	rollSong()
end

function MenuState:update(dt)
	if not music.sound:isPlaying() then
		rollSong()
	end

	-- Update UI system
	LS13.UI.update(dt)
end

function MenuState:draw()
	-- tile bg
	local w, h = bg:getDimensions()
	local sx, sy = love.graphics.getDimensions()

	love.graphics.setColor(1, 1, 1, 0.25)
	for x = 0, sx * 2, w do
		for y = 0, sy * 2, h do
			local t = love.timer.getTime()
			love.graphics.draw(bg, x - w / 2 + math.sin(t * 2) * w, y - h / 2 + math.cos(t * 4) * w, 0, 1, 1)
		end
	end

	love.graphics.setColor(1, 1, 1, 1)

	-- Render hierarchical UI
	LS13.UI.render()

	-- Debug info
	love.graphics.setFont(defaultFont)
	if music then
		love.graphics.print("Music: " .. music.name .. " by " .. music.author, 10, sy - 40)
	end
end

-- Input handling for UI
function MenuState:mousemoved(x, y)
	LS13.UI.handleMouse(x, y)
end

function MenuState:mousepressed(x, y, button)
	LS13.UI.handleMousePressed(x, y, button)
end

function MenuState:mousereleased(x, y, button)
	LS13.UI.handleMouseReleased(x, y, button)
end

function MenuState:keypressed(key, scancode, isrepeat)
	LS13.UI.handleKeyPressed(key, scancode, isrepeat)
end

function MenuState:keyreleased(key, scancode)
	LS13.UI.handleKeyReleased(key, scancode)
end

function MenuState:textinput(text)
	LS13.UI.handleTextInput(text)
end

return MenuState
