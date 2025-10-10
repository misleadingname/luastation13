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

	local dbgStart = LS13.ECSManager.entity("dbgStart")
	dbgStart:give("UiElement")
	dbgStart:give("UiTransform", Vector2.new(32, 32), Vector2.new(160, 24))
	dbgStart:give("UiPanel", "Graphic.UiButton")
	dbgStart:give("UiTarget")
	dbgStart:give("UiLabel", "start round", Color.white, "Font.Default", "center", "center")
	dbgStart.UiTarget.onClick = function()
		LS13.Networking.sendVerb("DebugStartRound")
	end

	LS13.UI.world:addEntity(dbgStart)
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
