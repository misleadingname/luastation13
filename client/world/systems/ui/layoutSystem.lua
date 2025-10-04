local layoutSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTransform" } })

function layoutSystem:update()
	for _, ent in ipairs(self.pool) do
		local trans = ent.UiTransform
		local parent = ent.UiElement.parent
		if parent then
			local parentTrans = ent.UiElement.parent.UiTransform
			if not parent.UiLayout then -- there's no layout moving for us
				trans.cpos.x = parentTrans.cpos.x + trans.position.x
				trans.cpos.y = parentTrans.cpos.y + trans.position.y
				trans.csize.x = trans.size.x
				trans.csize.y = trans.size.y
			end
		else
			trans.cpos.x = trans.position.x
			trans.cpos.y = trans.position.y
			trans.csize.x = trans.size.x
			trans.csize.y = trans.size.y
		end
	end
end

LS13.ECS.Systems.UiLayoutSystem = layoutSystem
