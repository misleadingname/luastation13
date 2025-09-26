return function()
	local scene = LS13.Scene()

	local Label = require("client/ui/controls/label")
	local Button = require("client/ui/controls/button")

	local titleLabel = Label(scene)
	titleLabel.props.text = "LuaStation13"
	titleLabel.props.color = { 1, 1, 1, 1 }
	titleLabel.props.align = "center"
	titleLabel.props.shadow = true

	local playButton = Button(scene)
	playButton.props.text = "Play"
	playButton.props.onClick = function()
		print("Play button clicked!")
	end

	local optionsButton = Button(scene)
	optionsButton.props.text = "Options"
	optionsButton.props.onClick = function()
		print("Options button clicked!")
	end

	local exitButton = Button(scene)
	exitButton.props.text = "Exit"
	exitButton.props.backgroundColor = { 0.5, 0.2, 0.2, 1 }
	exitButton.props.hoverColor = { 0.6, 0.3, 0.3, 1 }
	exitButton.props.onClick = function()
		print("Exit button clicked!")
		love.event.quit()
	end

	return {
		scene = scene,
		elements = {
			titleLabel = titleLabel,
			playButton = playButton,
			optionsButton = optionsButton,
			exitButton = exitButton
		},

		setPointerPosition = function(self, x, y)
			self.pointer:setPosition(x, y)
		end,

		raisePointerEvent = function(self, eventName, ...)
			self.pointer:raise(eventName, ...)
		end,

		raiseSceneEvent = function(self, eventName, ...)
			self.scene:raise(eventName, ...)
		end,

		render = function(self, x, y, w, h, depth)
			self.scene:beginFrame()

			love.graphics.setColor(0.1, 0.1, 0.15, 1)
			love.graphics.rectangle("fill", x or 0, y or 0, w or love.graphics.getWidth(), h or love.graphics.getHeight())

			local centerX = (w or love.graphics.getWidth()) / 2
			local centerY = (h or love.graphics.getHeight()) / 2
			local buttonWidth = 200
			local buttonHeight = 40
			local spacing = 10

			self.elements.titleLabel:render(
				centerX - buttonWidth / 2,
				centerY - 120,
				buttonWidth,
				30,
				1
			)

			self.elements.playButton:render(
				centerX - buttonWidth / 2,
				centerY - 60,
				buttonWidth,
				buttonHeight,
				1
			)

			self.elements.optionsButton:render(
				centerX - buttonWidth / 2,
				centerY - 60 + buttonHeight + spacing,
				buttonWidth,
				buttonHeight,
				1
			)

			self.elements.exitButton:render(
				centerX - buttonWidth / 2,
				centerY - 60 + 2 * (buttonHeight + spacing),
				buttonWidth,
				buttonHeight,
				1
			)
		end
	}
end
