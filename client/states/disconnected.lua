local ConnectingState = LS13.StateManager.new("Disconnected")

function ConnectingState:enter()
	LS13.UI.clear()
	LS13.SoundManager.NewSource("Sound.AHelp"):play()
	local scene = LS13.UI.createScene("UI.Markup.Core.Disconnected")
	local quitButton = scene:getElementById("QuitButton")

	quitButton.UiTarget.onClick = function()
		love.event.quit()
	end
end

function ConnectingState:update(dt)
end

function ConnectingState:draw()
end

function ConnectingState:exit() end

return ConnectingState
