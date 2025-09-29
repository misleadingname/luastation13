-- Thank you LOKAAAAAAAAAAAA for allowing me to BOOOOOORROW this!!!
-- https://github.com/lokachop/zvox/blob/main/gamemodes/zvox_classicbuild/gamemode/zvox/sh/sh_printing.lua

local Logging = {}
local log = {}

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
	[PRINTER_TYPE_ERROR] = 1,
	[PRINTER_TYPE_FATAL] = 1,
}


local function makePrinter(printerType)
	local typeStr = printerTypeStrLUT[printerType]
	local typeCol = printerTypeColLUT[printerType]
	local typeTreshold = printerLevelTresholdLUT[printerType]


	return function(...)
		if Logging.PrintLevel > typeTreshold then
			return
		end

		local appInfo = ""
		if DEBUG then
			local infoStruct = debug.getinfo(2, "lS")

			local source = infoStruct.source
			source = string.sub(source, 2)

			appInfo = " " .. source .. "::" .. tostring(infoStruct.currentline)
		end

		local message = string.format("[%s] [%s] %s: %s%s",
			os.date("%d/%m/%Y %H:%M:%S"),
			CLIENT and "CLIENT" or "SERVER",
			typeStr,
			table.concat({ ... }, " "),
			appInfo
		)
		io.write(message .. "\n")
	end
end

local dbg = makePrinter(PRINTER_TYPE_DEBUG)
local nfo = makePrinter(PRINTER_TYPE_INFO)
local err = makePrinter(PRINTER_TYPE_ERROR)
local ftl = makePrinter(PRINTER_TYPE_FATAL)

Logging.Log = log
Logging.PrintLevel = 0

Logging.PrintDebug = dbg
Logging.PrintInfo = nfo
Logging.PrintError = err
Logging.PrintFatal = ftl

return Logging
