local MenuState = {}

local bg
local music
local lobbyMusic

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
	rollSong()

	local container = require("client/ui/elements/container")
	local label = require("client/ui/elements/label")

	local manager = LS13.UI.Manager("MenuTestScene")
	local cont = container(manager.scene)

	local lbl = label(manager.scene)
	lbl.props.text = "Test Label"

	cont:AddChild(lbl)
	manager:SetRootElement(cont)
	LS13.UI.PushManager(manager)
end

function MenuState:update(dt)
	if not music.sound:isPlaying() then
		rollSong()
	end
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

	-- Debug info
	love.graphics.setFont(defaultFont)
	if music then
		love.graphics.print("Music: " .. music.name .. " by " .. music.author, 10, sy - 40)
	end
end

return MenuState
