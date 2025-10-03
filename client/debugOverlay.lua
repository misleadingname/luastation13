local debugOverlay = {}

local W = love.graphics.getWidth
local H = love.graphics.getHeight

local init = false
local font

local lines = {
	{
		Text = function()
			return string.format("%s FPS", love.timer.getFPS())
		end,
		Color = function()
			local g = love.timer.getFPS() / 60
			return { 1, g, g, 1 }
		end
	},

	{
		Text = function()
			return string.format("%ss", love.timer.getTime())
		end,
		Color = function()
			return { 1, 1, 1, 1 }
		end
	},

	{
		Text = function()
			return string.format("state: %s", LS13.StateManager.currentState.name)
		end,
		Color = function()
			return { 1, 1, 1, 1 }
		end
	}
}

function debugOverlay.init()
	font = LS13.AssetManager.Get("Font.Monospace")
	init = true
end

local function shadowText(text, x, y, align, color, shadowColor)
	love.graphics.setFont(font.font)
	local textSize = love.graphics.getFont():getWidth(text)

	if align == "center" then
		x = (W() - textSize) / 2
	elseif align == "right" then
		x = W() - textSize - x
	end

	love.graphics.setColor(shadowColor or { 0, 0, 0, 0.5 })
	love.graphics.printf(text, x + 2, y + 2, textSize, align)
	love.graphics.setColor(color or { 1, 1, 1, 1 })
	love.graphics.printf(text, x, y, textSize, align)
	love.graphics.setColor(1, 1, 1, 1)
end

function debugOverlay.update(dt)
	if not init then return end
end

function debugOverlay.draw()
	if not init then return end
	shadowText("!!! debug !!!", 16, 16, "center")
	for i, line in ipairs(lines) do
		shadowText(line.Text(), 16, 16 + i * 16, "right", line.Color())
	end
end

return debugOverlay
