local LobbyState = LS13.StateManager.new("Lobby")

local music
local musicSource

local lobbyMusic
local shuffledSongs = {}

local function rollSong()
	if musicSource and musicSource:isPlaying() then
		music.sound:stop()
	end

	if #shuffledSongs == 0 then
		shuffledSongs = lume.shuffle(lume.clone(lobbyMusic))
	end

	music = table.remove(shuffledSongs)

	musicSource = LS13.SoundManager.NewSource(music.id)

	LS13.Logging.LogInfo("Rolled on lobby song %s (%s by %s)!", music.id, music.name, music.author)
	love.audio.play(musicSource)
end

function LobbyState:enter()
	lobbyMusic = LS13.AssetManager.GetPrefixed("Sound.Lobby")
	rollSong()

	LS13.UI.createScene("UI.Markup.TestScene")
end

function LobbyState:update(dt)
	if not musicSource:isPlaying() then
		rollSong()
	end
end

function LobbyState:draw() end

function LobbyState:exit()
	musicSource:stop()
end

return LobbyState
