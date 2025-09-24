local DebugState = {}

local W = love.graphics.getWidth
local H = love.graphics.getHeight

local lines = {
	{
		Text = function()
			return love.timer.getFPS() .. " FPS"
		end,
		Color = function()
			local g = love.timer.getFPS() / 60
			return { 1, g, g, 1 }
		end
	},

	{
		Text = function()
			return love.timer.getTime() .. " s"
		end,
		Color = function()
			return { 1, 1, 1, 1 }
		end
	}
}

local function shadowText(text, x, y, align, color, shadowColor)
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

function DebugState:enter()
end

function DebugState:update(dt)
end

function DebugState:draw()
	shadowText("!!! debug !!!", 16, 16, "center")
	for i, line in ipairs(lines) do
		shadowText(line.Text(), 16, 16 + i * 16, "right", line.Color())
	end
end

return DebugState
