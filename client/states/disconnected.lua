local DisconnectedState = LS13.StateManager.new("Disconnected")

function DisconnectedState:enter()
	local disconnect = LS13.Networking.Disconnect
	local codes = lume.invert(NETWORK_DISCONNECT)

	LS13.UI.clear()
	LS13.SoundManager.NewSource("Sound.AHelp"):play()
	local scene = LS13.UI.createScene("UI.Markup.Core.Disconnected")

	local quitButton = scene:getElementById("QuitButton")
	local reasonLabel = scene:getElementById("ReasonLabel")

	reasonLabel.UiLabel.Text = string.format("%d: %s: %s", disconnect.code, codes[disconnect.code], disconnect.reason)
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
