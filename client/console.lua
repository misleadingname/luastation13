local console = {}

local initialized = false
local console_font

-- local open_time = 1.0
-- local open = false
-- local openness = 0.0

function console.init()
    console_font = LS13.AssetManager.Get("Font.Default")

    initialized = true
end

function console.update(dt)
    -- if open then
    --     openness = math.min(openness + dt / open_time, 1.0)
    -- else
    --     openness = math.max(openness - dt / open_time, 0.0)
    -- end
end

function console.draw()
    if not initialized then
        return
    end

    -- if openness > 0 then -- a bit of optimization i guess
    --     love.graphics.setFont(console_font)
    -- end

    love.graphics.setFont(console_font.font)
    love.graphics.setColor(1, 1, 1)

    local textY = 200

    local i = 0
    while textY > 0 do
        local logThingy = LS13.Logging.Logs[i]

        if logThingy == nil then
            break
        end

        local _, numLines = string.gsub(logThingy[0], "\n", "\n")
        numLines = numLines + 1

        local logHeight = console_font.size * (numLines)

        love.graphics.print(logThingy[0], 5, textY - logHeight)

        textY = textY - logHeight

        i = i + 1
    end
end

return console
