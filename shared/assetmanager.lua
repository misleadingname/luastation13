-- assetloader.lua
local AssetLoader = {}

local queue = {}
local assets = {}
local errors = {}
local total = 0
local loaded = 0
local isLoading = false

local assetTypes = {
	[".png"]  = "image",
	[".jpg"]  = "image",
	[".jpeg"] = "image",
	[".wav"]  = "audio",
	[".ogg"]  = "audio",
	[".mp3"]  = "audio",
	[".mod"]  = "audio",
	[".xm"]   = "audio",
	[".it"]   = "audio",
	[".s3m"]  = "audio"
}

local function getAssetType(path)
	local ext = path:match("%.([^%.]+)$")
	return ext and assetTypes["." .. ext:lower()]
end

local function scanDirectory(dir, results)
	results = results or {}
	local items = love.filesystem.getDirectoryItems(dir)

	for _, item in ipairs(items) do
		local fullPath = dir .. "/" .. item
		local info = love.filesystem.getInfo(fullPath)

		if info and info.type == "directory" then
			scanDirectory(fullPath, results)
		elseif info and info.type == "file" and getAssetType(item) then
			table.insert(results, fullPath)
		end
	end

	return results
end

local function createAssetFromFile(path, assetType)
	local fileData = love.filesystem.newFileData(path)

	-- TODO: Implement <LS13> xml parsing so file attributes can work!

	if CLIENT then
		if assetType == "image" then
			return love.graphics.newImage(fileData)
		elseif assetType == "audio" then
			return love.audio.newSource(fileData, "stream")
		end
	end
end

function AssetLoader.LoadAssets(directory)
	queue = scanDirectory(directory)
	total = #queue
	loaded = 0
	assets = {}
	errors = {}
	isLoading = true
end

function AssetLoader.Update(dt, maxPerFrame)
	if not isLoading then return end
	maxPerFrame = maxPerFrame or 4

	for i = 1, maxPerFrame do
		local path = table.remove(queue, 1)
		if not path then break end
		path = path:gsub("\\", "/"):gsub("^/", "")


		local assetType = getAssetType(path)
		io.write("[AssetLoader] Loading " .. assetType .. ": " .. path .. "... ")
		local ok, assetOrErr = pcall(createAssetFromFile, path, assetType)
		if ok and assetOrErr then
			assets[path] = assetOrErr
			print("OK!")
		else
			errors[path] = tostring(assetOrErr)
			print("BAIL! : " .. tostring(assetOrErr))
		end

		loaded = loaded + 1
	end

	if loaded >= total then
		isLoading = false
	end
end

function AssetLoader.Get(path) return assets[path] end
function AssetLoader.GetLoaded() return loaded end
function AssetLoader.GetTotal() return total end
function AssetLoader.GetErrors() return errors end
function AssetLoader.IsLoading() return isLoading end

return AssetLoader
