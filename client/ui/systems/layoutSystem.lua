local layoutSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTransform" } })

local constraintMap = {}

function layoutSystem:buildConstraints()
	constraintMap = {}
	constraintMap["root"] = LS13.UI.nlay

	-- First pass: create all constraints and store in map
	for _, entity in ipairs(self.pool) do
		local trans = entity.UiTransform
		local elem = entity.UiElement

		-- Get parent constraint
		local parentConstraint = LS13.UI.nlay
		if elem.parent and elem.parent.UiTransform and elem.parent.UiTransform.constraint then
			parentConstraint = elem.parent.UiTransform.constraint
		end

		-- Create basic constraint attached to parent
		local constraint = LS13.UI.nlay.constraint(parentConstraint, nil, nil, nil, nil)
		trans.constraint = constraint

		-- Store in map by entity ID
		if entity:getId() then
			constraintMap[entity:getId()] = constraint
		end
	end

	-- Second pass: configure constraints with proper attachments
	for _, entity in ipairs(self.pool) do
		local trans = entity.UiTransform
		local constraint = trans.constraint

		if constraint then
			-- Get parent constraint for this element
			local parentConstraint = LS13.UI.nlay
			if entity.UiElement.parent and entity.UiElement.parent.UiTransform then
				parentConstraint = entity.UiElement.parent.UiTransform.constraint or LS13.UI.nlay
			end

			-- Get padding for constraint creation
			local paddingTable = nil
			if entity.UiPadding then
				local p = entity.UiPadding
				paddingTable = { p.top, p.left, p.bottom, p.right }
			end

			-- Apply UiConstraint component if present
			if entity.UiConstraint then
				local uc = entity.UiConstraint

				-- Resolve constraint references
				local topConstraint = uc.top and constraintMap[uc.top] or nil
				local leftConstraint = uc.left and constraintMap[uc.left] or nil
				local bottomConstraint = uc.bottom and constraintMap[uc.bottom] or nil
				local rightConstraint = uc.right and constraintMap[uc.right] or nil

				-- Wrap with LS13.UI.nlay.in_() if needed
				if uc.inTop and topConstraint then
					topConstraint = LS13.UI.nlay.in_(topConstraint)
				end
				if uc.inLeft and leftConstraint then
					leftConstraint = LS13.UI.nlay.in_(leftConstraint)
				end
				if uc.inBottom and bottomConstraint then
					bottomConstraint = LS13.UI.nlay.in_(bottomConstraint)
				end
				if uc.inRight and rightConstraint then
					rightConstraint = LS13.UI.nlay.in_(rightConstraint)
				end

				-- Recreate constraint with proper attachments and padding
				constraint = LS13.UI.nlay.constraint(
					parentConstraint,
					topConstraint,
					leftConstraint,
					bottomConstraint,
					rightConstraint,
					paddingTable
				)
				trans.constraint = constraint

				-- Update map
				if entity:getId() then
					constraintMap[entity:getId()] = constraint
				end
			end

			-- Apply UiSize component if present
			if entity.UiSize then
				local size = entity.UiSize
				constraint:size(size.width, size.height, size.widthMode, size.heightMode)
			end

			-- Apply UiMargin component if present
			if entity.UiMargin then
				local margin = entity.UiMargin
				constraint:margin({ margin.top, margin.left, margin.bottom, margin.right })
			end

			-- Apply UiBias component if present
			if entity.UiBias then
				local bias = entity.UiBias
				constraint:bias(bias.horizontal, bias.vertical)
			end
		end
	end
end

-- Update all transforms based on LS13.UI.nlay constraints
function layoutSystem:update(dt)
	-- Rebuild constraints if needed (e.g., on first frame or when structure changes)
	if not next(constraintMap) then
		self:buildConstraints()
	end

	-- Update all transforms
	for _, entity in ipairs(self.pool) do
		local trans = entity.UiTransform

		if trans.constraint then
			-- Get calculated position and size from LS13.UI.nlay
			local x, y, w, h = trans.constraint:get()
			trans.position.x = x
			trans.position.y = y
			trans.size.x = w
			trans.size.y = h
		end
	end
end

-- Force rebuild of constraints (call when UI structure changes)
function layoutSystem:rebuild()
	self:buildConstraints()
end

LS13.ECS.Systems.UiLayoutSystem = layoutSystem
