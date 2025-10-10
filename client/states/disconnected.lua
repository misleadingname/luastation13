local DisconnectedState = LS13.StateManager.new("Disconnected")

function DisconnectedState:enter()
	LS13.UI.clear()
	LS13.SoundManager.NewSource("Sound.AHelp"):play()
	local scene = LS13.UI.createScene("UI.Markup.Core.Disconnected")
	local quitButton = scene:getElementById("QuitButton")

	quitButton.UiTarget.onClick = function()
		love.event.quit()
	end
end

function DisconnectedState:update(dt)
end

function DisconnectedState:draw()
end

function DisconnectedState:exit() end

return DisconnectedState
