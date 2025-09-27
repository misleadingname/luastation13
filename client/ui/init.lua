local Inky = require("lib/Inky")
local managers = require("client/ui/manager")

local ui = {}
ui.Inky = Inky

ui.managers = {}

function ui.Manager(name)
	return managers.new(name)
end

function ui.PopManager(manager)
	ui.managers[manager.name] = nil
end

function ui.PushManager(manager)
	ui.managers[manager.name] = manager
end

function ui.Update(dt)
	for _, manager in pairs(ui.managers) do
		manager:Update(dt)
	end
end

function ui.Draw()
	for name, manager in pairs(ui.managers) do
		local ok, error = pcall(function() manager:Draw() end)
		if not ok then
			LS13.Logging.PrintError(string.format("Failed to draw scene (%s): %s", name, error))
		end
	end
end

function ui.MousePressed(x, y, button)
	for name, manager in pairs(ui.managers) do manager:MousePressed(x, y, button) end
end

function ui.MouseReleased(x, y, button)
	for name, manager in pairs(ui.managers) do manager:MouseReleased(x, y, button) end
end

return ui
