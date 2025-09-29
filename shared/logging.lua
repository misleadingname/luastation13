-- Thank you LOKAAAAAAAAAAAA for allowing me to BOOOOOORROW this!!!
-- https://github.com/lokachop/zvox/blob/main/gamemodes/zvox_classicbuild/gamemode/zvox/sh/sh_printing.lua

local Logging = {}
local logs = {}

local PRINTER_TYPE_DEBUG = 1
local PRINTER_TYPE_INFO = 2
local PRINTER_TYPE_ERROR = 3
local PRINTER_TYPE_FATAL = 4

local printerTypeStrLUT = {
	[PRINTER_TYPE_DEBUG] = "[DEBUG]",
	[PRINTER_TYPE_INFO] = "[INFO ]",
	[PRINTER_TYPE_ERROR] = "[ERROR]",
	[PRINTER_TYPE_FATAL] = "[FATAL]",
}

local printerTypeColLUT = {
	[PRINTER_TYPE_DEBUG] = { 32, 32, 32 },
	[PRINTER_TYPE_INFO] = { 135, 135, 230 },
	[PRINTER_TYPE_ERROR] = { 220, 96, 96 },
	[PRINTER_TYPE_FATAL] = { 255, 32, 32 },
}

local printerLevelTresholdLUT = {
	[PRINTER_TYPE_DEBUG] = 0,
	[PRINTER_TYPE_INFO] = 1,
	[PRINTER_TYPE_ERROR] = 2,
	[PRINTER_TYPE_FATAL] = 3,
}


local function makePrinter(printerType)
	local typeStr = printerTypeStrLUT[printerType]
	local typeCol = printerTypeColLUT[printerType]
	local typeTreshold = printerLevelTresholdLUT[printerType]


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

		table.insert(logs, {
			logText,
			-- os.date("%d/%m/%Y %H:%M:%S"),
			-- CLIENT,
			-- typeStr,
			-- logOrigin,
			-- message
		})
	end
end

local dbg = makePrinter(PRINTER_TYPE_DEBUG)
local nfo = makePrinter(PRINTER_TYPE_INFO)
local err = makePrinter(PRINTER_TYPE_ERROR)
local ftl = makePrinter(PRINTER_TYPE_FATAL)

Logging.Logs = logs
Logging.PrintLevel = 0

Logging.LogDebug = dbg
Logging.LogInfo = nfo
Logging.LogError = err
Logging.LogFatal = ftl

return Logging
