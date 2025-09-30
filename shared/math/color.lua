local color = {}
color.__index = color
color.__metatable = "Color"

function color.new(r, g, b, a)
	local self = setmetatable({}, color)

	self.r = r or 0
	self.g = g or 0
	self.b = b or 0
	self.a = a or 1

	return self
end

function color:__index(key)
	if key == 1 or key == "R" then
		return rawget(self, "r")
	elseif key == 2 or key == "G" then
		return rawget(self, "g")
	elseif key == 3 or key == "B" then
		return rawget(self, "b")
	elseif key == 4 or key == "A" then
		return rawget(self, "a")
	else
		return rawget(color, key)
	end
end

function color:__tostring()
	return ("RGBA(%s, %s, %s, %s)"):format(self.r, self.g, self.b, self.a)
end

function color.__add(a, b) return color.new(a.r + b.r, a.g + b.g, a.b + b.b, a.a + b.a) end

function color.__sub(a, b) return color.new(a.r - b.r, a.g - b.g, a.b - b.b, a.a - b.a) end

function color.__mul(a, b)
	if type(b) == "number" then
		return color.new(a.r * b, a.g * b, a.b * b, a.a * b)
	elseif type(a) == "number" then
		return color.new(b.r * a, b.g * a, b.b * a, b.a * a)
	else
		return color.new(a.r * b.r, a.g * b.g, a.b * b.b, a.a * b.a)
	end
end

function color.__div(a, b)
	if type(b) == "number" then
		return color.new(a.r / b, a.g / b, a.b / b, a.a / b)
	else
		return color.new(a.r / b.r, a.g / b.g, a.b / b.b, a.a / b.a)
	end
end

function color:clamp()
	self.r = math.max(0, math.min(1, self.r))
	self.g = math.max(0, math.min(1, self.g))
	self.b = math.max(0, math.min(1, self.b))
	self.a = math.max(0, math.min(1, self.a))
	return self
end

function color:lerp(other, t)
	t = math.max(0, math.min(1, t or 0))
	return color.new(
		self.r + (other.r - self.r) * t,
		self.g + (other.g - self.g) * t,
		self.b + (other.b - self.b) * t,
		self.a + (other.a - self.a) * t
	)
end

function color:normalize()
	return Color.new(self.r / 255, self.g / 255, self.b / 255, self.a / 255)
end

function color:toNumbers()
	return self.r, self.g, self.b, self.a
end

color.white = color.new(1, 1, 1, 1)
color.black = color.new(0, 0, 0, 1)
color.red   = color.new(1, 0, 0, 1)
color.green = color.new(0, 1, 0, 1)
color.blue  = color.new(0, 0, 1, 1)

return color
