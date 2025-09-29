local vector2 = {}
vector2.__index = vector2
vector2.__metatable = "Vector2"

function vector2.new(x, y)
	local self = setmetatable({}, vector2)
	self.x = x or 0
	self.y = y or 0
	return self
end

function vector2:__index(key)
	if key == 1 or key == "X" then
		return rawget(self, "x")
	elseif key == 2 or key == "Y" then
		return rawget(self, "y")
	else
		return rawget(vector2, key)
	end
end

function vector2:__tostring()
	return ("[%s, %s]"):format(self.x, self.y)
end

function vector2.__add(a, b) return vector2.new(a.x + b.x, a.y + b.y) end

function vector2.__sub(a, b) return vector2.new(a.x - b.x, a.y - b.y) end

function vector2.__mul(a, b) return vector2.new(a.x * b.x, a.y * b.y) end

function vector2.__div(a, b) return vector2.new(a.x / b.x, a.y / b.y) end

function vector2:magnitude()
	return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

function vector2:unit()
	local d = self:magnitude()
	if d == 0 then return vector2.new(0, 0) end
	return vector2.new(self.x / d, self.y / d)
end

function vector2:lerp(other, frac)
	frac = math.max(0, math.min(1, frac or 0))
	return self + (other - self) * vector2.new(frac, frac)
end

function vector2:toAngle(other)
	return math.atan2(other.y - self.y, other.x - self.x)
end

function vector2.intersects(a, b, c, d)
	local x1, y1, w1, h1 = a.x, a.y, b.x, b.y
	local x2, y2, w2, h2 = c.x, c.y, d.x, d.y

	local collide = x1 < x2 + w2 + 1 and
		x1 + w1 > x2 - 1 and
		y1 < y2 + h2 + 1 and
		y1 + h1 > y2 - 1

	local surface = ""
	if collide then
		if y1 + h1 > y2 - 1 and y1 + h1 < y2 then
			surface = "top"
		elseif y1 > y2 + h2 and y1 < y2 + h2 + 1 then
			surface = "bottom"
		elseif x1 + w1 > x2 - 1 and x1 + w1 < x2 then
			surface = "left"
		elseif x1 > x2 + w2 and x1 < x2 + w2 + 1 then
			surface = "right"
		end

		-- Corner cases
		if y1 + h1 > y2 - 1 and y1 + h1 < y2 and
			x1 + w1 > x2 - 1 and x1 + w1 < x2 then
			surface = "topleft"
		elseif y1 + h1 > y2 - 1 and y1 + h1 < y2 and
			x1 > x2 + w2 and x1 < x2 + w2 + 1 then
			surface = "topright"
		elseif y1 > y2 + h2 and y1 < y2 + h2 + 1 and
			x1 + w1 > x2 - 1 and x1 + w1 < x2 then
			surface = "bottomleft"
		elseif y1 > y2 + h2 and y1 < y2 + h2 + 1 and
			x1 > x2 + w2 and x1 < x2 + w2 + 1 then
			surface = "bottomright"
		end
	end

	return collide, surface
end

return vector2
