local console = {}

local init = false
local font

local fadeTime = 5
local displayLogs = {}

function console.init()
	font = LS13.AssetManager.Get("Font.Monospace")
	init = true
end

function console.Push(text, color)
	table.insert(displayLogs, {
		text = text,
		color = color,
		time = love.timer.getTime(),
	})
end

function console.update(dt)
	local now = love.timer.getTime()

	for i = #displayLogs, 1, -1 do
		if now - displayLogs[i].time > fadeTime then
			table.remove(displayLogs, i)
		end
	end

	while #displayLogs > 64 do
		table.remove(displayLogs, 1)
	end
end

function console.draw()
	if not init then return end

	love.graphics.setFont(font.font)

	local y = 0
	local now = love.timer.getTime()

	for i = #displayLogs, 1, -1 do
		local entry = displayLogs[i]
		local age = now - entry.time

		local alpha = 1.0 - (age / fadeTime)
		if alpha < 0 then alpha = 0 end

		local _, numLines = string.gsub(entry.text, "\n", "\n")
		numLines = numLines + 1

		local logHeight = font.size * numLines

		love.graphics.setColor(0, 0, 0, 0.75 * alpha)
		love.graphics.print(entry.text, 6, y + logHeight + 1)

		love.graphics.setColor(entry.color.r, entry.color.g, entry.color.b, alpha)
		love.graphics.print(entry.text, 5, y + logHeight)
		y = y + logHeight
	end

	love.graphics.setColor(1, 1, 1, 1)
end

return console
