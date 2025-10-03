-- Thank you LOKAAAAAAAAAAAA for allowing me to BOOOOOORROW this!!!
-- https://github.com/lokachop/zvox/blob/main/gamemodes/zvox_classicbuild/gamemode/zvox/sh/sh_printing.lua

local Logging = {}

local logs = {}

local LOGGER_TYPE_DEBUG = 1
local LOGGER_TYPE_INFO = 2
local LOGGER_TYPE_WARN = 3
local LOGGER_TYPE_ERROR = 4
local LOGGER_TYPE_FATAL = 5

local loggerTypeStrLUT = {
	[LOGGER_TYPE_DEBUG] = "[DEBUG]",
	[LOGGER_TYPE_INFO]  = "[INFO ]",
	[LOGGER_TYPE_WARN]  = "[WARN ]",
	[LOGGER_TYPE_ERROR] = "[ERROR]",
	[LOGGER_TYPE_FATAL] = "[FATAL]",
}

-- for some fuckass reason using Color here causes init to hang
local loggerTypeColLUT = {
	-- [LOGGER_TYPE_DEBUG] = Color.new(32, 32, 32),
	-- [LOGGER_TYPE_INFO] = Color.new(135, 135, 230),
	-- [LOGGER_TYPE_ERROR] = Color.new(220, 96, 96),
	-- [LOGGER_TYPE_FATAL] = Color.new(255, 32, 32),
	[LOGGER_TYPE_DEBUG] = { r = 90 / 255, g = 90 / 255, b = 90 / 255 },
	[LOGGER_TYPE_INFO] = { r = 135 / 255, g = 135 / 255, b = 230 / 255 },
	[LOGGER_TYPE_WARN] = { r = 255 / 255, g = 200 / 255, b = 0 / 255 },
	[LOGGER_TYPE_ERROR] = { r = 220 / 255, g = 96 / 255, b = 96 / 255 },
	[LOGGER_TYPE_FATAL] = { r = 255 / 255, g = 32 / 255, b = 32 / 255 },
}

local loggerLevelTresholdLUT = {
	[LOGGER_TYPE_DEBUG] = 0,
	[LOGGER_TYPE_INFO] = 1,
	[LOGGER_TYPE_WARN] = 2,
	[LOGGER_TYPE_ERROR] = 3,
	[LOGGER_TYPE_FATAL] = 4,
}

local function makeLogger(loggerType)
	local typeStr = loggerTypeStrLUT[loggerType]
	local typeCol = loggerTypeColLUT[loggerType]
	local typeTreshold = loggerLevelTresholdLUT[loggerType]

	return function(format, ...)
		if Logging.PrintLevel > typeTreshold then
			return
		end

		local logOrigin = ""
		local infoStruct = debug.getinfo(2, "lS")
		local source = infoStruct.source
		source = string.sub(source, 2)
		logOrigin = source .. "::" .. tostring(infoStruct.currentline)

		local message = string.format(format, ...)

		local logText
		if DEBUG then
			logText = string.format("[%s] [%s] %s %s: %s",
				os.date("%d/%m/%Y %H:%M:%S"),
				CLIENT and "CLIENT" or "SERVER",
				typeStr,
				logOrigin,
				message
			)
		else
			logText = string.format("[%s] [%s] %s: %s",
				os.date("%d/%m/%Y %H:%M:%S"),
				CLIENT and "CLIENT" or "SERVER",
				typeStr,
				message
			)
		end
		io.write(logText .. "\n")

		if CLIENT and LS13.Console then LS13.Console.Push(logText, typeCol) end
		table.insert(logs, {
			logText,
		})
	end
end

Logging.Logs = logs
Logging.PrintLevel = 0

Logging.LogDebug = makeLogger(LOGGER_TYPE_DEBUG)
Logging.LogInfo = makeLogger(LOGGER_TYPE_INFO)
Logging.LogWarn = makeLogger(LOGGER_TYPE_WARN)
Logging.LogError = makeLogger(LOGGER_TYPE_ERROR)
Logging.LogFatal = makeLogger(LOGGER_TYPE_FATAL)

return Logging
