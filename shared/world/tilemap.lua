local tilemap = {}
tilemap.__index = tilemap
tilemap.__metatable = "Tilemap"

tilemap.CHUNK_SIZE = 8

local function get_chunk_coords(coords)
	local cx = math.floor(coords.x / tilemap.CHUNK_SIZE)
	local cy = math.floor(coords.y / tilemap.CHUNK_SIZE)

	return Vector2.new(cx, cy)
end

local function get_chunk_index(coords)
	local lx = (coords.x % tilemap.CHUNK_SIZE)
	if lx < 0 then
		lx += tilemap.CHUNK_SIZE
	end
	local ly = (coords.y % tilemap.CHUNK_SIZE)
	if ly < 0 then
		ly += tilemap.CHUNK_SIZE
	end

	return ly * tilemap.CHUNK_SIZE + lx + 1 -- gotta love lua tables starting at 1
end

function tilemap.newChunk()
	local chunk = {}
	for i = 1, tilemap.CHUNK_SIZE * tilemap.CHUNK_SIZE do
		table.insert(chunk, nil)
	end

	return chunk
end

function tilemap.new()
	local self = setmetatable({}, tilemap)
	self.chunks = {}
	self.dirtyChunks = {}

	return self
end

function tilemap:__index(key)
	return rawget(tilemap, key)
end

function tilemap:getTile(coords)
	local chunkCoord = get_chunk_coords(coords)
	local chunk = self.chunks[chunkCoord.x .. "," .. chunkCoord.y]
	if chunk then
		return chunk[get_chunk_index(coords)]
	else
		return nil
	end
end

function tilemap:setTile(coords, tile)
	local chunkCoord = get_chunk_coords(coords)
	local chunkKey = chunkCoord.x .. "," .. chunkCoord.y
	local chunk = self.chunks[chunkKey]

	if chunk then
		chunk[get_chunk_index(coords)] = tile
	else
		chunk = tilemap.newChunk()
		chunk[get_chunk_index(coords)] = tile
		self.chunks[chunkKey] = chunk -- Fix: Actually store the new chunk!
	end

	if SERVER then
		self:markChunkDirty(chunkKey)
	end
end

function tilemap:markChunkDirty(chunkKey)
	if not self.dirtyChunks then
		self.dirtyChunks = {}
	end
	self.dirtyChunks[chunkKey] = true
end

function tilemap:getDirtyChunks()
	local dirty = self.dirtyChunks or {}
	self.dirtyChunks = {}
	return dirty
end

function tilemap:serializeChunk(chunkKey)
	local chunk = self.chunks[chunkKey]
	if not chunk then
		return nil
	end

	-- send chunk data by only non-nil tiles
	local compressedChunk = {}
	for i = 1, self.CHUNK_SIZE * self.CHUNK_SIZE do
		if chunk[i] then
			compressedChunk[i] = chunk[i]
		end
	end

	return compressedChunk
end

function tilemap:deserializeChunk(chunkKey, compressedChunk)
	local chunk = tilemap.newChunk()
	for i, tile in pairs(compressedChunk) do
		chunk[i] = tile
	end
	self.chunks[chunkKey] = chunk
end

function tilemap:getChunkKey(coords)
	local chunkCoord = get_chunk_coords(coords)
	return chunkCoord.x .. "," .. chunkCoord.y
end

return tilemap
