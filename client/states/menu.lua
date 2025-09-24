local MenuState = {}

local bg
local lobbyMusic
local music

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
	rollSong()
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
			love.graphics.draw(bg, x - w / 2 + math.sin(love.timer.getTime() * 2) * w, y - h / 2 + math.cos(love.timer.getTime() * 4) * w, 0, 1, 1)
		end
	end

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print(
	"sry to burst ur bubble but for now there's like NOTHING to show!!! (rn all of it is just engine work) lol laugh at this user")
	love.graphics.print("Music: " .. music.name .. " by " .. music.author, 0, 20)
end

return MenuState
