return function(node)
	local data = {
		id = node._attr and node._attr.Id,
		type = "uimarkup",
		markupType = node._attr and node._attr.Type, -- Template or Scene
	}

	if data.markupType == "Template" then
		data.params = {}
		if node.Params and node.Params.Param then
			local paramList = node.Params.Param
			if paramList._attr and paramList._attr.Name then paramList = {paramList} end
			for _, param in ipairs(paramList) do
				if param._attr then data.params[param._attr.Name] = param._attr.Default end
			end
		end

		data.content = node.UIEntity
	elseif data.markupType == "Scene" then
		data.content = node.UIElement
	end

	if CLIENT and LS13.UI and LS13.UI.manager then
		if data.markupType == "Template" then
			LS13.UI.manager.registerTemplate(data.id, data)
		elseif data.markupType == "Scene" then
			LS13.UI.manager.registerScene(data.id, data)
		end
	end

	LS13.AssetManager.Push(data, data.id)
end