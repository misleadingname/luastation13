--
-- Adapted from
-- Tweener's easing functions (Penner's Easing Equations)
-- and http://code.google.com/p/tweener/ (jstweener javascript version)
--

--[[
Disclaimer for Robert Penner's Easing Equations license:

TERMS OF USE - EASING EQUATIONS

Open source under the BSD License.

Copyright © 2001 Robert Penner
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- For all easing functions:
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration (total time)

local easings = {}

local sin     = math.sin
local cos     = math.cos
local pi      = math.pi
local sqrt    = math.sqrt
local abs     = math.abs
local asin    = math.asin

function easings.linear(t, b, c, d)
	return c * t / d + b
end

function easings.inQuad(t, b, c, d)
	t = t / d
	return c * t * t + b
end

function easings.outQuad(t, b, c, d)
	t = t / d
	return -c * t * (t - 2) + b
end

function easings.inOutQuad(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * t * t + b
	else
		return -c / 2 * ((t - 1) * (t - 3) - 1) + b
	end
end

function easings.outInQuad(t, b, c, d)
	if t < d / 2 then
		return easings.outQuad(t * 2, b, c / 2, d)
	else
		return easings.inQuad(t * 2 - d, b + c / 2, c / 2, d)
	end
end

function easings.inCubic(t, b, c, d)
	t = t / d
	return c * t * t * t + b
end

function easings.outCubic(t, b, c, d)
	t = t / d - 1
	return c * (t * t * t + 1) + b
end

function easings.inOutCubic(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * t * t * t + b
	else
		t = t - 2
		return c / 2 * (t * t * t + 2) + b
	end
end

function easings.outInCubic(t, b, c, d)
	if t < d / 2 then
		return easings.outCubic(t * 2, b, c / 2, d)
	else
		return easings.inCubic(t * 2 - d, b + c / 2, c / 2, d)
	end
end

function easings.inQuart(t, b, c, d)
	t = t / d
	return c * t ^ 4 + b
end

function easings.outQuart(t, b, c, d)
	t = t / d - 1
	return -c * (t ^ 4 - 1) + b
end

function easings.inOutQuart(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * t ^ 4 + b
	else
		t = t - 2
		return -c / 2 * (t ^ 4 - 2) + b
	end
end

function easings.outInQuart(t, b, c, d)
	if t < d / 2 then
		return easings.outQuart(t * 2, b, c / 2, d)
	else
		return easings.inQuart(t * 2 - d, b + c / 2, c / 2, d)
	end
end

function easings.inQuint(t, b, c, d)
	t = t / d
	return c * t ^ 5 + b
end

function easings.outQuint(t, b, c, d)
	t = t / d - 1
	return c * (t ^ 5 + 1) + b
end

function easings.inOutQuint(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * t ^ 5 + b
	else
		t = t - 2
		return c / 2 * (t ^ 5 + 2) + b
	end
end

function easings.outInQuint(t, b, c, d)
	if t < d / 2 then
		return easings.outQuint(t * 2, b, c / 2, d)
	else
		return easings.inQuint(t * 2 - d, b + c / 2, c / 2, d)
	end
end

function easings.inSine(t, b, c, d)
	return -c * cos(t / d * (pi / 2)) + c + b
end

function easings.outSine(t, b, c, d)
	return c * sin(t / d * (pi / 2)) + b
end

function easings.inOutSine(t, b, c, d)
	return -c / 2 * (cos(pi * t / d) - 1) + b
end

function easings.outInSine(t, b, c, d)
	if t < d / 2 then
		return easings.outSine(t * 2, b, c / 2, d)
	else
		return easings.inSine(t * 2 - d, b + c / 2, c / 2, d)
	end
end

function easings.inExpo(t, b, c, d)
	if t == 0 then
		return b
	else
		return c * 2 ^ (10 * (t / d - 1)) + b - c * 0.001
	end
end

function easings.outExpo(t, b, c, d)
	if t == d then
		return b + c
	else
		return c * 1.001 * (1 - 2 ^ (-10 * t / d)) + b
	end
end

function easings.inOutExpo(t, b, c, d)
	if t == 0 then return b end
	if t == d then return b + c end
	t = t / d * 2
	if t < 1 then
		return c / 2 * 2 ^ (10 * (t - 1)) + b - c * 0.0005
	else
		t = t - 1
		return c / 2 * 1.0005 * (2 - 2 ^ (-10 * t)) + b
	end
end

function easings.outInExpo(t, b, c, d)
	if t < d / 2 then
		return easings.outExpo(t * 2, b, c / 2, d)
	else
		return easings.inExpo(t * 2 - d, b + c / 2, c / 2, d)
	end
end

function easings.inCirc(t, b, c, d)
	t = t / d
	return -c * (sqrt(1 - t ^ 2) - 1) + b
end

function easings.outCirc(t, b, c, d)
	t = t / d - 1
	return c * sqrt(1 - t ^ 2) + b
end

function easings.inOutCirc(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return -c / 2 * (sqrt(1 - t * t) - 1) + b
	else
		t = t - 2
		return c / 2 * (sqrt(1 - t * t) + 1) + b
	end
end

function easings.outInCirc(t, b, c, d)
	if t < d / 2 then
		return easings.outCirc(t * 2, b, c / 2, d)
	else
		return easings.inCirc((t * 2) - d, b + c / 2, c / 2, d)
	end
end

function easings.inElastic(t, b, c, d, a, p)
	if t == 0 then return b end

	t = t / d

	if t == 1 then return b + c end

	if not p then p = d * 0.3 end

	local s

	if not a or a < abs(c) then
		a = c
		s = p / 4
	else
		s = p / (2 * pi) * asin(c / a)
	end

	t = t - 1

	return -(a * 2 ^ (10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end

-- a: amplitud
-- p: period
function easings.outElastic(t, b, c, d, a, p)
	if t == 0 then return b end

	t = t / d

	if t == 1 then return b + c end

	if not p then p = d * 0.3 end

	local s

	if not a or a < abs(c) then
		a = c
		s = p / 4
	else
		s = p / (2 * pi) * asin(c / a)
	end

	return a * 2 ^ (-10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end

-- p = period
-- a = amplitud
function easings.inOutElastic(t, b, c, d, a, p)
	if t == 0 then return b end

	t = t / d * 2

	if t == 2 then return b + c end

	if not p then p = d * (0.3 * 1.5) end
	if not a then a = 0 end

	local s

	if not a or a < abs(c) then
		a = c
		s = p / 4
	else
		s = p / (2 * pi) * asin(c / a)
	end

	if t < 1 then
		t = t - 1
		return -0.5 * (a * 2 ^ (10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
	else
		t = t - 1
		return a * 2 ^ (-10 * t) * sin((t * d - s) * (2 * pi) / p) * 0.5 + c + b
	end
end

-- a: amplitud
-- p: period
function easings.outInElastic(t, b, c, d, a, p)
	if t < d / 2 then
		return easings.outElastic(t * 2, b, c / 2, d, a, p)
	else
		return easings.inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
	end
end

function easings.inBack(t, b, c, d, s)
	if not s then s = 1.70158 end
	t = t / d
	return c * t * t * ((s + 1) * t - s) + b
end

function easings.outBack(t, b, c, d, s)
	if not s then s = 1.70158 end
	t = t / d - 1
	return c * (t * t * ((s + 1) * t + s) + 1) + b
end

function easings.inOutBack(t, b, c, d, s)
	if not s then s = 1.70158 end
	s = s * 1.525
	t = t / d * 2
	if t < 1 then
		return c / 2 * (t * t * ((s + 1) * t - s)) + b
	else
		t = t - 2
		return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
	end
end

function easings.outInBack(t, b, c, d, s)
	if t < d / 2 then
		return easings.outBack(t * 2, b, c / 2, d, s)
	else
		return easings.inBack((t * 2) - d, b + c / 2, c / 2, d, s)
	end
end

function easings.outBounce(t, b, c, d)
	t = t / d
	if t < 1 / 2.75 then
		return c * (7.5625 * t * t) + b
	elseif t < 2 / 2.75 then
		t = t - (1.5 / 2.75)
		return c * (7.5625 * t * t + 0.75) + b
	elseif t < 2.5 / 2.75 then
		t = t - (2.25 / 2.75)
		return c * (7.5625 * t * t + 0.9375) + b
	else
		t = t - (2.625 / 2.75)
		return c * (7.5625 * t * t + 0.984375) + b
	end
end

function easings.inBounce(t, b, c, d)
	return c - easings.outBounce(d - t, 0, c, d) + b
end

function easings.inOutBounce(t, b, c, d)
	if t < d / 2 then
		return easings.inBounce(t * 2, 0, c, d) * 0.5 + b
	else
		return easings.outBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
	end
end

function easings.outInBounce(t, b, c, d)
	if t < d / 2 then
		return easings.outBounce(t * 2, b, c / 2, d)
	else
		return easings.inBounce((t * 2) - d, b + c / 2, c / 2, d)
	end
end

return easings
