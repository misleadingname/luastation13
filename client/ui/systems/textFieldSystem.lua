local textFieldSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTextField", "UiTarget" } })

local escHeld = false
local escRepeated = false
local escDelay = 0.5
local escRate = 0.015
local escTimer = 0

local keyRepeatStates = {}
local keyRepeatDelay = 0.5
local keyRepeatRate = 0.03

local function clearSelection(field)
	field.selectionStart = nil
	field.selectionEnd = nil
end

local function getSelectionRange(field)
	if not field.selectionStart or not field.selectionEnd then
		return nil, nil
	end
	local start = math.min(field.selectionStart, field.selectionEnd)
	local endPos = math.max(field.selectionStart, field.selectionEnd)
	return start, endPos
end

local function deleteSelection(field)
	local start, endPos = getSelectionRange(field)
	if start and endPos and start ~= endPos then
		local beforeSelection = field.value:sub(1, start)
		local afterSelection = field.value:sub(endPos + 1)
		field.value = beforeSelection .. afterSelection
		field.cursorPosition = start
		clearSelection(field)
		return true
	end
	return false
end

function textFieldSystem:initalize()
	for i = #self.pool, 1, -1 do
		local ent = self.pool[i]
		local field = ent.UiTextField
		if field.cursorPosition == nil then
			field.cursorPosition = utf8.len(field.value)
		end
		if field.selectionStart == nil then
			field.selectionStart = nil
			field.selectionEnd = nil
		end
	end
end

function textFieldSystem:textInput(text)
	for i = #self.pool, 1, -1 do
		local ent = self.pool[i]
		local field = ent.UiTextField
		local target = ent.UiTarget

		if target.focused then
			deleteSelection(field)

			local beforeCursor = field.value:sub(1, field.cursorPosition)
			local afterCursor = field.value:sub(field.cursorPosition + 1)
			field.value = beforeCursor .. text .. afterCursor
			field.cursorPosition = field.cursorPosition + utf8.len(text)
		end
	end
end

function textFieldSystem:update(dt)
	for key, state in pairs(keyRepeatStates) do
		if state.held then
			state.timer = state.timer - dt
			if state.timer <= 0 then
				self:handleKeyAction(key, true, state.shiftHeld)
				state.timer = state.repeated and keyRepeatRate or keyRepeatDelay
				state.repeated = true
			end
		end
	end

	for i = #self.pool, 1, -1 do
		local ent = self.pool[i]
		local field = ent.UiTextField
		local target = ent.UiTarget
		local label = ent.UiLabel

		if field.cursorPosition == nil then
			field.cursorPosition = utf8.len(field.value)
		else
			field.cursorPosition = math.max(0, math.min(utf8.len(field.value), field.cursorPosition))
		end

		if field.selectionStart then
			field.selectionStart = math.max(0, math.min(utf8.len(field.value), field.selectionStart))
		end
		if field.selectionEnd then
			field.selectionEnd = math.max(0, math.min(utf8.len(field.value), field.selectionEnd))
		end

		if escHeld and target.focused then
			escTimer = escTimer - dt
			if escTimer <= 0 then
				if not deleteSelection(field) and field.cursorPosition > 0 then
					local beforeCursor = field.value:sub(1, field.cursorPosition - 1)
					local afterCursor = field.value:sub(field.cursorPosition + 1)
					field.value = beforeCursor .. afterCursor
					field.cursorPosition = field.cursorPosition - 1
				end

				escTimer = escRepeated and escRate or escDelay
				escRepeated = true
			end
		end

		if label then
			local text = field.placeholder
			if field.value ~= "" then
				text = field.value
			end

			label.text = text
		end
	end
end

function textFieldSystem:handleKeyAction(key, isRepeat, shiftHeld)
	for i = #self.pool, 1, -1 do
		local ent = self.pool[i]
		local field = ent.UiTextField
		local target = ent.UiTarget

		if target.focused then
			local oldCursorPos = field.cursorPosition

			if key == "left" then
				field.cursorPosition = math.max(0, field.cursorPosition - 1)
			elseif key == "right" then
				field.cursorPosition = math.min(utf8.len(field.value), field.cursorPosition + 1)
			elseif key == "home" then
				field.cursorPosition = 0
			elseif key == "end" then
				field.cursorPosition = utf8.len(field.value)
			elseif key == "delete" then
				if not deleteSelection(field) and field.cursorPosition < utf8.len(field.value) then
					local beforeCursor = field.value:sub(1, field.cursorPosition)
					local afterCursor = field.value:sub(field.cursorPosition + 2)
					field.value = beforeCursor .. afterCursor
				end
			end

			if key == "left" or key == "right" or key == "home" or key == "end" then
				if shiftHeld then
					if not field.selectionStart then
						field.selectionStart = oldCursorPos
					end
					field.selectionEnd = field.cursorPosition
				else
					clearSelection(field)
				end
			end
		end
	end
end

function textFieldSystem:keyPressed(key, scancode, isrepeat)
	local shiftHeld = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
	local ctrlHeld = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")

	if ctrlHeld then
		for i = #self.pool, 1, -1 do
			local ent = self.pool[i]
			local field = ent.UiTextField
			local target = ent.UiTarget

			if target.focused then
				if key == "a" then
					field.selectionStart = 0
					field.selectionEnd = utf8.len(field.value)
					field.cursorPosition = utf8.len(field.value)
				elseif key == "c" then
					local start, endPos = getSelectionRange(field)
					if start and endPos and start ~= endPos then
						local selectedText = field.value:sub(start + 1, endPos)
						love.system.setClipboardText(selectedText)
					end
				elseif key == "x" then
					local start, endPos = getSelectionRange(field)
					if start and endPos and start ~= endPos then
						local selectedText = field.value:sub(start + 1, endPos)
						love.system.setClipboardText(selectedText)
						deleteSelection(field)
					end
				elseif key == "v" then
					local clipboardText = love.system.getClipboardText()
					if clipboardText and clipboardText ~= "" then
						deleteSelection(field)

						local beforeCursor = field.value:sub(1, field.cursorPosition)
						local afterCursor = field.value:sub(field.cursorPosition + 1)
						field.value = beforeCursor .. clipboardText .. afterCursor
						field.cursorPosition = field.cursorPosition + utf8.len(clipboardText)
					end
				end
			end
		end
		return
	end

	if key == "backspace" then
		escRepeated = false
		escHeld = true
		escTimer = 0
	else
		self:handleKeyAction(key, false, shiftHeld)
	end

	if key == "left" or key == "right" or key == "home" or key == "end" or key == "delete" then
		keyRepeatStates[key] = {
			held = true,
			timer = keyRepeatDelay,
			repeated = false,
			shiftHeld = shiftHeld
		}
	end
end

function textFieldSystem:keyReleased(key, scancode)
	if key == "backspace" then
		escHeld = false
	end

	if keyRepeatStates[key] then
		keyRepeatStates[key] = nil
	end
end

LS13.ECS.Systems.UiTextFieldSystem = textFieldSystem
