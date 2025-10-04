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
		lx = lx + tilemap.CHUNK_SIZE
	end
	local ly = (coords.y % tilemap.CHUNK_SIZE)
	if ly < 0 then
		ly = ly + tilemap.CHUNK_SIZE
	end

	return ly * tilemap.CHUNK_SIZE + lx + 1 -- gotta love lua tables starting at 1
end

function tilemap.new_chunk()
	local chunk = {}
	for i = 1, tilemap.CHUNK_SIZE * tilemap.CHUNK_SIZE do
		table.insert(chunk, nil)
	end

	return chunk
end

function tilemap.new()
	local self = setmetatable({}, tilemap)
	self.chunks = {}

	return self
end

function tilemap:__index(key)
	return rawget(tilemap, key)
end

function tilemap:get_tile(coords)
	local chunkCoord = get_chunk_coords(coords)
	local chunk = self.chunks[chunkCoord.x .. "," .. chunkCoord.y]
	if chunk then
		return chunk[get_chunk_index(coords)]
	else
		return nil
	end
end

function tilemap:set_tile(coords, tile)
	local chunkCoord = get_chunk_coords(coords)
	local chunk = self.chunks[chunkCoord.x .. "," .. chunkCoord.y]
	if chunk then
		chunk[get_chunk_index(coords)] = tile
	else
		chunk = tilemap.new_chunk()
		chunk[get_chunk_index(coords)] = tile
	end
end

return tilemap
