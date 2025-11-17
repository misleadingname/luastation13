local interpolationSystem = LS13.ECSManager.system({})

-- active[entity] = { [compName] = { [fieldName] = tween } }
local active = setmetatable({}, { __mode = "k" }) -- weak keys to avoid leaks

local function isVector2(v)
	return type(v) == "table" and getmetatable(v) and getmetatable(v).__metatable == "Vector2"
end

local function isColor(v)
	return type(v) == "table" and getmetatable(v) and getmetatable(v).__metatable == "Color"
end

local function hasLerp(v)
	return type(v) == "table" and type(v.lerp) == "function"
end

local function lerpNumber(a, b, t)
	return a + (b - a) * t
end

local function lerpVector2(a, b, t)
	return a:lerp(b, t)
end

local function lerpColor(a, b, t)
	return a:lerp(b, t)
end

local function approxEqual(a, b)
	if isVector2(a) and isVector2(b) then
		return a.x == b.x and a.y == b.y
	end
	if isColor(a) and isColor(b) then
		return a.r == b.r and a.g == b.g and a.b == b.b and a.a == b.a
	end
	if type(a) == "number" and type(b) == "number" then
		return a == b
	end
	return a == b
end

function interpolationSystem.queueLerp(entity, compName, fieldName, from, to, networkType)
	if from == nil or to == nil then
		if entity[compName] then
			entity[compName][fieldName] = to
		end
		return
	end

	if approxEqual(from, to) then
		if entity[compName] then
			entity[compName][fieldName] = to
		end

		return
	end

	local eEntry = active[entity]
	if not eEntry then
		eEntry = {}
		active[entity] = eEntry
	end
	local cEntry = eEntry[compName]
	if not cEntry then
		cEntry = {}
		eEntry[compName] = cEntry
	end

	cEntry[fieldName] = {
		from = from,
		to = to,
		t = 0,
		dur = NETWORK_TICK_RATE,
		networkType = networkType,
	}
end

function interpolationSystem.cancelComponent(entity, compName)
	local eEntry = active[entity]
	if eEntry then
		eEntry[compName] = nil
		if next(eEntry) == nil then
			active[entity] = nil
		end
	end
end

function interpolationSystem:update(dt)
	for entity, comps in pairs(active) do
		for compName, fields in pairs(comps) do
			local comp = entity[compName]
			if not comp then
				comps[compName] = nil
			else
				for fieldName, tw in pairs(fields) do
					local dur = tw.dur > 0 and tw.dur or 0.00001
					tw.t = tw.t + dt
					local alpha = tw.t / dur
					if alpha >= 1 then
						comp[fieldName] = tw.to
						fields[fieldName] = nil
					else
						local fromV, toV = tw.from, tw.to
						if type(fromV) == "number" and type(toV) == "number" then
							comp[fieldName] = lerpNumber(fromV, toV, alpha)
						elseif isVector2(fromV) and isVector2(toV) then
							comp[fieldName] = lerpVector2(fromV, toV, alpha)
						elseif isColor(fromV) and isColor(toV) then
							comp[fieldName] = lerpColor(fromV, toV, alpha)
						elseif hasLerp(fromV) and hasLerp(toV) then
							comp[fieldName] = fromV:lerp(toV, alpha)
						end
					end
				end

				if next(fields) == nil then
					comps[compName] = nil
				end
			end
		end
		if next(comps) == nil then
			active[entity] = nil
		end
	end
end

LS13.ECS.Systems.InterpolationSystem = interpolationSystem

return interpolationSystem
