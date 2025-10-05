local MenuState = LS13.StateManager.new("Menu")

local bgSpace1
local bgSpace2
local bgSpace3

local music
local lobbyMusic

local defaultFont

local shuffledSongs = {}

function MenuState:rollSong()
	LS13.Logging.LogInfo("Rolling lobby song...")
	if music and music.sound:isPlaying() then
		music.sound:stop()
	end

	if #shuffledSongs == 0 then
		shuffledSongs = lume.shuffle(lume.clone(lobbyMusic))
	end

	music = table.remove(shuffledSongs)

	LS13.Logging.LogInfo("Rolled on lobby song %s (%s by %s)!", music.id, music.name, music.author)
	love.audio.play(music.sound)
end

function MenuState:enter()
	defaultFont = LS13.AssetManager.Get("Font.Default").font
	bgSpace1 = LS13.AssetManager.Get("Graphic.BG.SpaceLayer1").image
	bgSpace2 = LS13.AssetManager.Get("Graphic.BG.SpaceLayer2").image
	bgSpace3 = LS13.AssetManager.Get("Graphic.BG.SpaceLayer3").image
	lobbyMusic = LS13.AssetManager.GetPrefixed("Music.Lobby")
	MenuState:rollSong()

	LS13.UI.test_scene()
end

function MenuState:update(dt)
	if not music.sound:isPlaying() then
		MenuState:rollSong()
	end
end

function MenuState:draw()
	local scrW, scrH = love.graphics.getDimensions()

	local time = love.timer.getTime()

	local bgX, bgY = time * 25, time * 5

	love.graphics.draw(bgSpace1, love.graphics.newQuad(bgX / 2.5, bgY / 2.5, scrW, scrH, 480, 480))
	love.graphics.setBlendMode("add")
	love.graphics.draw(bgSpace2, love.graphics.newQuad(bgX / 1.5, bgY / 1.5, scrW, scrH, 480, 480))
	love.graphics.draw(bgSpace3, love.graphics.newQuad(bgX, bgY, scrW, scrH, 480, 480))
	love.graphics.setBlendMode("alpha")

	love.graphics.setFont(defaultFont)
	if music then
		love.graphics.print("Music: " .. music.name .. " by " .. music.author, 10, scrH - 40)
	end
end

return MenuState
