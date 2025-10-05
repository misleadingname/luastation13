local layoutSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTransform" } })

function layoutSystem:update()
	for _, parent in ipairs(self.pool) do
		if parent.UiLayout then
			local layout = parent.UiLayout
			local parentTrans = parent.UiTransform
			local children = parent.UiElement.children
			if #children == 0 then
				goto continue
			end

			local parentPos = parentTrans.cpos
			local parentSize = parentTrans.csize

			-- total size of children in layout direction
			local totalSize = 0
			for _, child in ipairs(children) do
				local ctrans = child.UiTransform
				if layout.type == "vertical" then
					totalSize = totalSize + ctrans.size.y
				else
					totalSize = totalSize + ctrans.size.x
				end
			end
			if #children > 1 then
				totalSize = totalSize + layout.spacing * (#children - 1)
			end

			-- compute initial offset based on justify
			local offset
			if layout.type == "vertical" then
				if layout.justify == "begin" then
					offset = layout.padding.y
				elseif layout.justify == "center" then
					offset = (parentSize.y - totalSize) / 2
				elseif layout.justify == "end" then
					offset = parentSize.y - totalSize - layout.padding.y
				else -- stretch (distribute later)
					offset = layout.padding.y
				end
			else
				if layout.justify == "begin" then
					offset = layout.padding.x
				elseif layout.justify == "center" then
					offset = (parentSize.x - totalSize) / 2
				elseif layout.justify == "end" then
					offset = parentSize.x - totalSize - layout.padding.x
				else -- stretch
					offset = layout.padding.x
				end
			end

			-- position children
			for _, child in ipairs(children) do
				local ctrans = child.UiTransform

				if layout.type == "vertical" then
					-- horizontal align (cross axis)
					if layout.align == "begin" then
						ctrans.cpos.x = parentPos.x + layout.padding.x
					elseif layout.align == "center" then
						ctrans.cpos.x = parentPos.x + (parentSize.x - ctrans.size.x) / 2
					elseif layout.align == "end" then
						ctrans.cpos.x = parentPos.x + parentSize.x - ctrans.size.x - layout.padding.x
					end

					-- vertical position
					ctrans.cpos.y = parentPos.y + offset
					ctrans.csize = ctrans.size

					offset = offset + ctrans.size.y + layout.spacing
				else
					-- vertical align (cross axis)
					if layout.align == "begin" then
						ctrans.cpos.y = parentPos.y + layout.padding.y
					elseif layout.align == "center" then
						ctrans.cpos.y = parentPos.y + (parentSize.y - ctrans.size.y) / 2
					elseif layout.align == "end" then
						ctrans.cpos.y = parentPos.y + parentSize.y - ctrans.size.y - layout.padding.y
					end

					-- horizontal position
					ctrans.cpos.x = parentPos.x + offset
					ctrans.csize = ctrans.size

					offset = offset + ctrans.size.x + layout.spacing
				end
			end
		end

		::continue::
	end

	for _, ent in ipairs(self.pool) do
		local elem = ent.UiElement
		if elem.parent and not elem.parent.UiLayout then
			local parentTrans = elem.parent.UiTransform
			local trans = ent.UiTransform
			trans.cpos = parentTrans.cpos + trans.position
			trans.csize = trans.size
		elseif not elem.parent then
			local trans = ent.UiTransform
			trans.cpos = trans.position
			trans.csize = trans.size
		end
	end
end

LS13.ECS.Systems.UiLayoutSystem = layoutSystem
