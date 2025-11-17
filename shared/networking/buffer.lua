-- adapted from https://github.com/lokachop/zvox/blob/main/gamemodes/zvox_classicbuild/gamemode/zvox/sh/sh_filebuffer.lua

local buffer = {}
buffer.__index = buffer
buffer.__metatable = "Buffer"

local math = math
local math_floor = math.floor
local math_log = math.log
local math_abs = math.abs
local math_ceil = math.ceil
local math_pow = math.pow

local table = table
local table_concat = table.concat

local string = string
local string_char = string.char
local string_byte = string.byte
local string_sub = string.sub

local bit = bit
local bit_band = bit.band
local bit_rshift = bit.rshift

local f08 = math_pow(2, 8)
local f16 = math_pow(2, 16)
local f24 = math_pow(2, 24)
local f32 = math_pow(2, 32)
local f40 = math_pow(2, 40)
local f48 = math_pow(2, 48)

local _IDX_CONTENTS = 1
local _IDX_CURSOR = 2

-- Create a new empty buffer
function buffer.new()
	local self = setmetatable({}, buffer)
	self[_IDX_CONTENTS] = {}
	self[_IDX_CURSOR] = 1

	return self
end

-- Create from existing Lua string (binary)
function buffer.fromString(s)
	local buff = buffer.new()
	for i = 1, #s do
		buff[_IDX_CONTENTS][i] = string_sub(s, i, i)
	end
	return buff
end

-- Create from array-like table of bytes (numbers 0-255 or single-char strings)
function buffer.fromData(data)
	local buff = buffer.new()
	for i = 1, #data do
		local v = data[i]
		if type(v) == "number" then
			buff[_IDX_CONTENTS][i] = string_char(bit_band(0xFF, v))
		else
			buff[_IDX_CONTENTS][i] = tostring(v)
		end
	end
	return buff
end

-- Get Lua string of contents
function buffer:__tostring()
	return table_concat(self[_IDX_CONTENTS], "")
end

-- Resize/grow helper (ensures capacity for writes)
local function ensure_capacity(buff, pos)
	local contents = buff[_IDX_CONTENTS]
	-- if pos > #contents then we insert nils until pos - 1
	local cur_size = #contents
	if pos > cur_size then
		for i = cur_size + 1, pos do
			contents[i] = contents[i] or string_char(0)
		end
	end
end

-- Cursor operations
function buffer:seek(bytePos) self[_IDX_CURSOR] = bytePos end

function buffer:skip(bytes) self[_IDX_CURSOR] = self[_IDX_CURSOR] + bytes end

function buffer:tell() return self[_IDX_CURSOR] end

function buffer:reset() self[_IDX_CURSOR] = 1 end

function buffer:size() return #self[_IDX_CONTENTS] end

function buffer:endOfBuffer() return self[_IDX_CONTENTS][self[_IDX_CURSOR]] == nil end

function buffer.clear(buff)
	buff[_IDX_CONTENTS] = {}
	buff[_IDX_CURSOR] = 1
end

-- Low-level write of raw Lua string bytes
function buffer:writeRaw(data)
	local cursor = self[_IDX_CURSOR]
	ensure_capacity(self, cursor + #data - 1)
	for i = 1, #data do
		self[_IDX_CONTENTS][cursor + (i - 1)] = string_sub(data, i, i)
	end
	self[_IDX_CURSOR] = cursor + #data
end

-- Low-level read of raw bytes as Lua string
function buffer:readRaw(len)
	local cursor = self[_IDX_CURSOR]
	local size = buffer.size(self)
	len = len or (size - cursor + 1)
	if cursor + len - 1 > size then
		-- return partial if out-of-bounds, caller should check EndOfBuffer if needed
		len = math.max(0, size - cursor + 1)
	end

	local tmp = {}
	for i = 1, len do
		tmp[i] = self[_IDX_CONTENTS][cursor + (i - 1)]
	end
	self[_IDX_CURSOR] = cursor + len
	return table_concat(tmp, "")
end

--
-- BOOL
--
function buffer:writeBool(b)
	local cursor = self[_IDX_CURSOR]
	ensure_capacity(self, cursor)
	self[_IDX_CONTENTS][cursor] = string_char(b and 0x1 or 0x0)
	self[_IDX_CURSOR] = cursor + 1
end

function buffer:readBool()
	local cursor = self[_IDX_CURSOR]
	self[_IDX_CURSOR] = cursor + 1
	local v = self[_IDX_CONTENTS][cursor]
	if not v then return nil end
	return string_byte(v) == 0x1
end

--
-- BYTE (unsigned 8)
--
function buffer:writeByte(n)
	local cursor = self[_IDX_CURSOR]
	ensure_capacity(self, cursor)
	self[_IDX_CONTENTS][cursor] = string_char(bit_band(0xFF, n))
	self[_IDX_CURSOR] = cursor + 1
end

function buffer:readByte()
	local cursor = self[_IDX_CURSOR]
	self[_IDX_CURSOR] = cursor + 1
	local v = self[_IDX_CONTENTS][cursor]
	if not v then return nil end
	return string_byte(v)
end

--
-- UNSIGNED SHORT (16)
--
function buffer:writeUShort(n)
	local cursor = self[_IDX_CURSOR]
	ensure_capacity(self, cursor + 1)
	self[_IDX_CONTENTS][cursor]     = string_char(bit_band(n, 0xFF))
	self[_IDX_CONTENTS][cursor + 1] = string_char(bit_band(bit_rshift(n, 8), 0xFF))
	self[_IDX_CURSOR]               = cursor + 2
end

function buffer:readUShort()
	local cursor = self[_IDX_CURSOR]
	self[_IDX_CURSOR] = cursor + 2
	local a = self[_IDX_CONTENTS][cursor]
	local b = self[_IDX_CONTENTS][cursor + 1]
	if not a or not b then return nil end
	return string_byte(a) + string_byte(b) * f08
end

--
-- SIGNED SHORT (16)
--
local sign_invert_short = 65536
function buffer:writeShort(n)
	buffer.writeUShort(self, n % sign_invert_short)
end

function buffer:readShort(self)
	local raw = buffer.readUShort(self)
	if not raw then return nil end
	local sign = bit_band(bit_rshift(raw, 8), 0x80)
	if sign > 0 then
		return -(sign_invert_short - raw)
	else
		return raw
	end
end

--
-- UNSIGNED LONG (32)
--
function buffer:writeULong(n)
	local cursor = self[_IDX_CURSOR]
	ensure_capacity(self, cursor + 3)
	self[_IDX_CONTENTS][cursor]     = string_char(bit_band(n, 0xFF))
	self[_IDX_CONTENTS][cursor + 1] = string_char(bit_band(bit_rshift(n, 8), 0xFF))
	self[_IDX_CONTENTS][cursor + 2] = string_char(bit_band(bit_rshift(n, 16), 0xFF))
	self[_IDX_CONTENTS][cursor + 3] = string_char(bit_band(bit_rshift(n, 24), 0xFF))
	self[_IDX_CURSOR]               = cursor + 4
end

function buffer:readULong()
	local cursor = self[_IDX_CURSOR]
	self[_IDX_CURSOR] = cursor + 4
	local a = self[_IDX_CONTENTS][cursor]
	local b = self[_IDX_CONTENTS][cursor + 1]
	local c = self[_IDX_CONTENTS][cursor + 2]
	local d = self[_IDX_CONTENTS][cursor + 3]
	if not a or not b or not c or not d then return nil end
	return string_byte(a) + string_byte(b) * f08 + string_byte(c) * f16 + string_byte(d) * f24
end

--
-- SIGNED LONG (32)
--
local sign_invert_long = 4294967296
function buffer:writeLong(n)
	buffer.writeULong(self, n % sign_invert_long)
end

function buffer:readLong()
	local raw = buffer.readULong(self)
	if not raw then return nil end
	local f4 = bit_band(bit_rshift(raw, 24), 0xFF)
	local sign = bit_band(f4, 0x80)
	if sign > 0 then
		return -(sign_invert_long - raw)
	else
		return raw
	end
end

--
-- FLOAT / DOUBLE (IEEE-754)
-- Copied math approach from your filebuffer (same helpers)
--
local log2 = math_log(2)
local pow2to23 = math_pow(2, 23)
local pow2to52 = math_pow(2, 52)

function buffer:writeFloat(n)
	local cursor = self[_IDX_CURSOR]
	ensure_capacity(self, cursor + 3)

	local sign     = n < 0 and 1 or 0
	local exponent = math_ceil(math_log(math_abs(n)) / log2) - 1
	local fraction = math_abs(n) / math_pow(2, exponent) - 1

	if (exponent < -127) then
		exponent = -127
		fraction = math_abs(n) / math_pow(2, exponent)
	elseif (exponent > 128) then
		return
	end

	if (n == 0) then
		exponent = -127
		fraction = 0
	elseif (math_abs(n) == math.huge) then
		exponent = 128
		fraction = 0
	elseif (n ~= n) then
		exponent = 128
		fraction = (pow2to23 - 1) / pow2to23
	end

	local expOut = exponent + 127
	local fractionOut = fraction * pow2to23

	self[_IDX_CONTENTS][cursor] = string_char(math_floor(fractionOut % 256))
	self[_IDX_CONTENTS][cursor + 1] = string_char(math_floor(fractionOut / f08) % 256)
	self[_IDX_CONTENTS][cursor + 2] = string_char((expOut % 2) * 128 + math_floor(fractionOut / f16))
	self[_IDX_CONTENTS][cursor + 3] = string_char((128 * sign) + math_floor(expOut / 2))
	self[_IDX_CURSOR] = cursor + 4
end

function buffer:readFloat()
	local cursor = self[_IDX_CURSOR]
	self[_IDX_CURSOR] = cursor + 4

	local f1 = self[_IDX_CONTENTS][cursor]
	local f2 = self[_IDX_CONTENTS][cursor + 1]
	local f3 = self[_IDX_CONTENTS][cursor + 2]
	local f4 = self[_IDX_CONTENTS][cursor + 3]
	if not f1 or not f2 or not f3 or not f4 then return nil end

	f1, f2, f3, f4 = string_byte(f1), string_byte(f2), string_byte(f3), string_byte(f4)

	local sign = f4 >= 128 and 1 or 0
	local exponent = (f4 % 128) * 2 + math_floor(f3 / 128)
	local fraction = (f3 % 128) * f16 + f2 * f08 + f1

	if (exponent == 128) then
		if (fraction == 0) then return math_pow(-1, sign) * math.huge end
		if (fraction == pow2to23 - 1) then return 0 / 0 end
	end

	if (exponent == 0) then
		return math_pow(-1, sign) * math_pow(2, exponent - 127) * (fraction / pow2to23)
	else
		return math_pow(-1, sign) * math_pow(2, exponent - 127) * (fraction / pow2to23 + 1)
	end
end

function buffer:writeDouble(n)
	local cursor = self[_IDX_CURSOR]
	ensure_capacity(self, cursor + 7)

	local sign     = n < 0 and 1 or 0
	local exponent = math_ceil(math_log(math_abs(n)) / log2) - 1
	local fraction = math_abs(n) / math_pow(2, exponent) - 1

	if (exponent < -1023) then
		exponent = -1023
		fraction = math_abs(n) / math_pow(2, exponent)
	elseif (exponent > 1024) then
		return
	end

	if (n == 0) then
		exponent = -1023
		fraction = 0
	elseif (math_abs(n) == math.huge) then
		exponent = 1024
		fraction = 0
	elseif (n ~= n) then
		exponent = 1024
		fraction = (pow2to52 - 1) / pow2to52
	end

	local expOut = exponent + 1023
	local fractionOut = fraction * pow2to52

	self[_IDX_CONTENTS][cursor] = string_char(math_floor(fractionOut % 256))
	self[_IDX_CONTENTS][cursor + 1] = string_char(math_floor(fractionOut / f08) % 256)
	self[_IDX_CONTENTS][cursor + 2] = string_char(math_floor(fractionOut / f16) % 256)
	self[_IDX_CONTENTS][cursor + 3] = string_char(math_floor(fractionOut / f24) % 256)
	self[_IDX_CONTENTS][cursor + 4] = string_char(math_floor(fractionOut / f32) % 256)
	self[_IDX_CONTENTS][cursor + 5] = string_char(math_floor(fractionOut / f40) % 256)
	self[_IDX_CONTENTS][cursor + 6] = string_char((expOut % 16) * 16 + math_floor(fractionOut / f48))
	self[_IDX_CONTENTS][cursor + 7] = string_char(128 * sign + math_floor(expOut / 16))
	self[_IDX_CURSOR] = cursor + 8
end

function buffer:readDouble()
	local cursor = self[_IDX_CURSOR]
	self[_IDX_CURSOR] = cursor + 8

	local f1 = self[_IDX_CONTENTS][cursor]
	local f2 = self[_IDX_CONTENTS][cursor + 1]
	local f3 = self[_IDX_CONTENTS][cursor + 2]
	local f4 = self[_IDX_CONTENTS][cursor + 3]
	local f5 = self[_IDX_CONTENTS][cursor + 4]
	local f6 = self[_IDX_CONTENTS][cursor + 5]
	local f7 = self[_IDX_CONTENTS][cursor + 6]
	local f8 = self[_IDX_CONTENTS][cursor + 7]
	if not f1 or not f2 or not f3 or not f4 or not f5 or not f6 or not f7 or not f8 then return nil end

	f1, f2, f3, f4, f5, f6, f7, f8 =
		string_byte(f1), string_byte(f2), string_byte(f3), string_byte(f4),
		string_byte(f5), string_byte(f6), string_byte(f7), string_byte(f8)

	local sign = f8 >= 128 and 1 or 0
	local exponent = (f8 % 128) * 16 + math_floor(f7 / 16)
	local fraction = (f7 % 16) * f48 + f6 * f40 + f5 * f32 + f4 * f24 + f3 * f16 + f2 * f08 + f1

	if (exponent == 2047) then
		if (fraction == 0) then return math_pow(-1, sign) * math.huge end
		if (fraction == pow2to52 - 1) then return 0 / 0 end
	end

	if (exponent == 0) then
		return math_pow(-1, sign) * math_pow(2, exponent - 1023) * (fraction / pow2to52)
	else
		return math_pow(-1, sign) * math_pow(2, exponent - 1023) * (fraction / pow2to52 + 1)
	end
end

--
-- STRING helpers
-- Write as: 16-bit length prefix (unsigned short), then raw bytes
--
function buffer:writeString(s)
	s = tostring(s)
	local len = #s
	if len > 0xFFFF then
		error("String too large for NB_WriteString (max 65535)")
	end
	buffer.writeUShort(self, len)
	buffer.writeRaw(self, s)
end

function buffer:readString()
	local len = buffer.readUShort(self)
	if not len then return nil end
	return buffer.readRaw(self, len)
end

-- Append another buffer's contents
function buffer:appendBuffer(src)
	local s = tostring(src)
	buffer.writeRaw(self, s)
end

-- Vectors
function buffer:writeVector2(vec)
	buffer.writeFloat(self, vec.x)
	buffer.writeFloat(self, vec.y)
end

function buffer:readVector2()
	local x = buffer.readFloat(self)
	local y = buffer.readFloat(self)
	return Vector2.new(x, y)
end

function buffer:writeVector2i(vec)
	buffer.writeLong(self, vec.x)
	buffer.writeLong(self, vec.y)
end

function buffer:readVector2i()
	local x = buffer.readLong(self)
	local y = buffer.readLong(self)
	return Vector2.new(x, y)
end

-- Color
function buffer:writeColor(color)
	buffer.writeByte(self, color.r)
	buffer.writeByte(self, color.g)
	buffer.writeByte(self, color.b)
	buffer.writeByte(self, color.a)
end

function buffer:readColor()
	local r = buffer.readByte(self)
	local g = buffer.readByte(self)
	local b = buffer.readByte(self)
	local a = buffer.readByte(self)
	return Color.new(r, g, b, a)
end

_G.buffer = buffer
return buffer
