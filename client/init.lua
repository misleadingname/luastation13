local client = {}

function client.load()
	print("ey shared im the client")

	love.window.setTitle(LS13.Info.Name)

	LS13.SoundManager = require("client.soundManager")
	LS13.UI = require("client.ui")
	LS13.Console = require("client.console")
	LS13.Networking = require("client.networking")

	require("client.states")
	LS13.UI.init()

	love.window.setIcon(love.image.newImageData(_G.iconPath))
	if DEBUG then
		LS13.DebugOverlay = require("client.debugOverlay")
	end
	LS13.StateManager.switchState("Loading")
end

function client.preframe() end

function client.update(dt)
	xpcall(function()
		LS13.Networking.process()

		LS13.StateManager.update(dt)
		LS13.Console.update(dt)
		LS13.UI.update(dt)

		if DEBUG and LS13.DebugOverlay then
			LS13.DebugOverlay.update(dt)
		end
	end, HandleError)
end

function love.draw()
	xpcall(function()
		LS13.StateManager.draw()

		LS13.UI.draw()
		LS13.Console.draw()

		if DEBUG and LS13.DebugOverlay then
			LS13.DebugOverlay.draw()
		end
	end, HandleError)
end

function love.mousepressed(x, y, button)
	xpcall(function()
		LS13.UI.mousePressed(x, y, button)
	end, HandleError)
end

function love.mousereleased(x, y, button)
	xpcall(function()
		LS13.UI.mouseReleased(x, y, button)
	end, HandleError)
end

function love.quit()
	LS13.Networking.shutdown()
end

return client
