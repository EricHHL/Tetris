   
local gui = {}   
gui.__index = gui


debugLines = false

widgetType = {
	panel = 1,
	button = 2,
	label = 3,
	textBox = 4
}

panelTypes = {}

textBoxFocus = nil

lastClick = love.timer.getTime()
clickCooldown = 0.1

layoutFunctions = {
	boxV = function(wd)

		local totalWeight = 0
		for i,child in ipairs(wd.children) do
			if child.active then
				totalWeight = totalWeight + child.weight
			end
		end
		local baseHeight = wd.h / totalWeight
		local lastHeight = 0
		for i,child in ipairs(wd.children) do
			if child.active == true then
				local boxHeight = baseHeight * child.weight
				local halign = child.halign or wd.childHalign
				local valign = child.valign or wd.childValign
				
				child.h = math.min(child.h, boxHeight-wd.padding*2)
				child.w = math.min(child.w, wd.w-wd.padding*2)
				if(child.redraw)then
					child.redraw()
				end

				if (halign == "left") then
					child.x = wd.padding
				elseif(halign == "center") then
					child.x = wd.w/2 - child.w/2
				elseif(halign == "right") then
					child.x = wd.w - wd.padding - child.w
				end

				if (valign == "top") then
					child.y = lastHeight + wd.padding
				elseif (valign == "center") then
					child.y = lastHeight + boxHeight/2 - child.h/2
				elseif (valign == "bottom") then
					child.y = lastHeight + boxHeight - wd.padding - child.h
				end
				
				child.x = child.x + wd.x
				child.y = child.y + wd.y

				if (child.layout) then
					if (child.layout ~= "absolute") then
						layoutFunctions[child.layout](child)
					end
				end

				lastHeight = lastHeight + boxHeight
			end
		end

		if debugLines then
			wd.drawLines = function()
				love.graphics.setColor(255, 0, 255)
				love.graphics.rectangle("line", wd.x, wd.y, wd.w, wd.h)
				love.graphics.setColor(0,255,0)
				local totalWeight = 0
				for i,child in ipairs(wd.children) do
					totalWeight = totalWeight + child.weight
				end
				local baseHeight = wd.h / totalWeight
				local lastHeight = 0
				for i,child in ipairs(wd.children) do
					local boxHeight = baseHeight * child.weight
					love.graphics.rectangle("line", wd.x+wd.padding, wd.y+wd.padding+lastHeight, wd.w - wd.padding*2, boxHeight - wd.padding*2)
					lastHeight = lastHeight + boxHeight
				end
			end
		end

	end,
	boxH = function(wd)
		-- TODO
	end
}


local function init()

	return gui
end

function gui:newPanelType(name, tex, borderS, centerS)
	panelTypes[name] = {}
	panelTypes[name].texture = tex
	panelTypes[name].borderSize = borderS
	panelTypes[name].centerSize = centerS
	panelTypes[name].quads = {}
	panelTypes[name].quads[0] = love.graphics.newQuad(0, 0, panelTypes[name].borderSize, panelTypes[name].borderSize, panelTypes[name].texture:getDimensions())
	panelTypes[name].quads[1] = love.graphics.newQuad(panelTypes[name].borderSize, 0, panelTypes[name].centerSize, panelTypes[name].borderSize, panelTypes[name].texture:getDimensions())
	panelTypes[name].quads[2] = love.graphics.newQuad(panelTypes[name].borderSize+panelTypes[name].centerSize, 0, panelTypes[name].borderSize, panelTypes[name].borderSize, panelTypes[name].texture:getDimensions())
	panelTypes[name].quads[3] = love.graphics.newQuad(0, panelTypes[name].borderSize, panelTypes[name].borderSize, panelTypes[name].centerSize, panelTypes[name].texture:getDimensions())
	panelTypes[name].quads[4] = love.graphics.newQuad(panelTypes[name].borderSize, panelTypes[name].borderSize, panelTypes[name].centerSize, panelTypes[name].centerSize, panelTypes[name].texture:getDimensions())
	panelTypes[name].quads[5] = love.graphics.newQuad(panelTypes[name].borderSize+panelTypes[name].centerSize, panelTypes[name].borderSize, panelTypes[name].borderSize, panelTypes[name].centerSize, panelTypes[name].texture:getDimensions())
	panelTypes[name].quads[6] = love.graphics.newQuad(0, panelTypes[name].borderSize+panelTypes[name].centerSize, panelTypes[name].borderSize, panelTypes[name].borderSize, panelTypes[name].texture:getDimensions())
	panelTypes[name].quads[7] = love.graphics.newQuad(panelTypes[name].borderSize, panelTypes[name].borderSize+panelTypes[name].centerSize, panelTypes[name].centerSize, panelTypes[name].borderSize, panelTypes[name].texture:getDimensions())
	panelTypes[name].quads[8] = love.graphics.newQuad(panelTypes[name].borderSize+panelTypes[name].centerSize, panelTypes[name].borderSize+panelTypes[name].centerSize, panelTypes[name].borderSize, panelTypes[name].borderSize, panelTypes[name].texture:getDimensions())
end

function gui:newPanel(x, y, w, h, options)
	options = options or {}
	pType = options.panelType or "none"
	local panelBatch = nil
	if (pType ~= "none") then
		scaleX = (w - panelTypes[pType].borderSize - panelTypes[pType].borderSize) / (panelTypes[pType].texture:getWidth() - panelTypes[pType].borderSize - panelTypes[pType].borderSize)
		scaleY = (h - panelTypes[pType].borderSize - panelTypes[pType].borderSize) / (panelTypes[pType].texture:getHeight() - panelTypes[pType].borderSize - panelTypes[pType].borderSize)
		panelBatch = love.graphics.newSpriteBatch(panelTypes[pType].texture, 9, "static")
		panelBatch:add(panelTypes[pType].quads[0], 0, 0, 0, 1, 1)
		panelBatch:add(panelTypes[pType].quads[1], panelTypes[pType].borderSize, 0, 0, scaleX, 1)
		panelBatch:add(panelTypes[pType].quads[2], panelTypes[pType].borderSize + panelTypes[pType].centerSize * scaleX, 0, 0, 1, 1)
		
		panelBatch:add(panelTypes[pType].quads[3], 0, panelTypes[pType].borderSize, 0, 1, scaleY)
		panelBatch:add(panelTypes[pType].quads[4], panelTypes[pType].borderSize, panelTypes[pType].borderSize, 0, scaleX, scaleY)
		panelBatch:add(panelTypes[pType].quads[5], panelTypes[pType].borderSize + panelTypes[pType].centerSize * scaleX, panelTypes[pType].borderSize, 0, 1, scaleY)

		panelBatch:add(panelTypes[pType].quads[6], 0, panelTypes[pType].borderSize + panelTypes[pType].centerSize * scaleY, 0, 1, 1)
		panelBatch:add(panelTypes[pType].quads[7], panelTypes[pType].borderSize, panelTypes[pType].borderSize + panelTypes[pType].centerSize * scaleY, 0, scaleX, 1)
		panelBatch:add(panelTypes[pType].quads[8], panelTypes[pType].borderSize + panelTypes[pType].centerSize * scaleX, panelTypes[pType].borderSize + panelTypes[pType].centerSize * scaleY, 0, 1, 1)
	end
	if options.batchOnly then
		return panelBatch;
	else
		local pn = {}
		pn.batch = panelBatch
		pn.x = x
		pn.y = y
		pn.w = w
		pn.h = h
		pn.panelType = pType
		pn.color = options.color or Color(255,255,255,255)
		pn.layout = options.layout or "absolute"

		if(pn.layout ~= "absolute") then
			pn.childHalign = options.childHalign or "left"
			pn.childValign = options.childValign or "top"
			pn.padding = options.padding or 10
		end

		pn.halign = options.halign
		pn.valign = options.valign
		pn.weight = options.weight or 1

		pn.wType = widgetType.panel
		pn.children = {}
		function pn:addChild(wd)
			self.children[#self.children+1] = wd
			self:refresh()
		end

		function pn:refresh()
			if (self.layout ~= "absolute") then
				layoutFunctions[self.layout](self)
			end
		end

		pn.active = true
		return pn
	end
end

function gui:newButton(text, x, y, w, h, callback, options)
	options = options or {}
	local bt = {}
	bt.text = text
	bt.panelType = options.panelType or "button"
	bt.batch = self:newPanel(x, y, w, h, {panelType = bt.panelType, batchOnly = true})
	bt.redraw = function()
		bt.batch = self:newPanel(bt.x, bt.y, bt.w, bt.h, {panelType = bt.panelType, batchOnly = true})
		bt.fontY = (bt.h - panelTypes[bt.panelType].borderSize*2 - bt.font:getHeight()) / 2
	end
	bt.x = x
	bt.y = y
	bt.w = w
	bt.h = h
	bt.callback = callback
	bt.color = options.color or Color(255,255,255,255)
	bt.hoverColor = options.hoverColor or Color(200,200,200)
	bt.textColor = options.textColor or Color(0,0,0)
	bt.font = options.font or font
	bt.fontY = (h - panelTypes[bt.panelType].borderSize*2 - bt.font:getHeight()) / 2
	bt.textAlign = options.textAlign or "center"

	bt.halign = options.halign
	bt.valign = options.valign
	bt.weight = options.weight or 1

	bt.wType = widgetType.button
	bt.active = true
	return bt
end

function gui:newLabel(text, x, y, w, options)
	options = options or {}
	local lb = {}

	lb.text = text
	lb.x = x
	lb.y = y
	lb.w = w
	lb.color = options.color or Color(255,255,255,255)
	lb.textAlign = options.textAlign or "center"
	lb.font = options.font or font
	lb.h = lb.font:getHeight()

	lb.halign = options.halign
	lb.valign = options.valign
	lb.weight = options.weight or 1

	lb.wType = widgetType.label
	lb.active = true
	return lb
end

-- TODO: caret
function gui:newTextBox(x, y, w, h, options)
	options = options or {}
	local tb = {}
	tb.text = options.text or ""
	tb.panelType = options.panelType or "textBox"
	tb.batch = self:newPanel(x, y, w, h, {panelType = tb.panelType, batchOnly = true})
	tb.x = x
	tb.y = y
	tb.w = w
	tb.h = h
	tb.callback = options.callback
	tb.color = options.color or Color(220,220,220)
	tb.focusColor = options.focusColor or Color(220,220,255)
	tb.textColor = options.textColor or Color(0,0,0)
	tb.font = options.font or font
	tb.fontY = (h - panelTypes[tb.panelType].borderSize*2-tb.font:getHeight()) / 2
	tb.textAlign = options.textAlign or "left"

	tb.halign = options.halign
	tb.valign = options.valign
	tb.weight = options.weight or 1

	tb.wType = widgetType.textBox
	tb.active = true
	return tb
end

function gui:draw(wd)
	if not wd.active then
		return
	end
	if wd.drawLines then
		wd.drawLines()
	end
	local mx, my = love.mouse.getPosition()
		
	--Desenha widget
	if (wd.wType == widgetType.panel) then
		if (wd.panelType ~= "none") then
			love.graphics.setColor(wd.color:value())
			love.graphics.draw(wd.batch, wd.x, wd.y, 0, 1, 1)
		end
		
		for i,child in ipairs(wd.children) do
			self:draw(child)
		end
	

	elseif (wd.wType == widgetType.button) then
		if ((mx > wd.x) and (mx < wd.x + wd.w) and (my > wd.y) and (my < wd.y + wd.h)) then 	--Se o mouse estiver em cima do botao
			love.graphics.setColor(wd.hoverColor:value())
		else
			love.graphics.setColor(wd.color:value())
		end
		love.graphics.draw(wd.batch, wd.x, wd.y, 0, 1, 1)
		love.graphics.setColor(wd.textColor:value())
		love.graphics.setFont(wd.font)
		love.graphics.printf(wd.text, wd.x+panelTypes[wd.panelType].borderSize, wd.y + wd.fontY + panelTypes[wd.panelType].borderSize, wd.w-panelTypes[wd.panelType].borderSize*2, wd.textAlign)

	elseif (wd.wType == widgetType.label) then
		love.graphics.setColor(wd.color:value())
		love.graphics.setFont(wd.font)
		love.graphics.printf(wd.text, wd.x, wd.y, wd.w, wd.textAlign)

	elseif (wd.wType == widgetType.textBox) then
		if (wd == textBoxFocus) then
			love.graphics.setColor(wd.focusColor:value())
		else
			love.graphics.setColor(wd.color:value())
		end
		love.graphics.draw(wd.batch, wd.x, wd.y, 0, 1, 1)
		love.graphics.setColor(wd.textColor:value())
		love.graphics.setFont(wd.font)
		love.graphics.printf(wd.text, wd.x+panelTypes[wd.panelType].borderSize, wd.y + wd.fontY + panelTypes[wd.panelType].borderSize, wd.w-panelTypes[wd.panelType].borderSize*2, wd.textAlign)

	end	

end

function gui:mousepressed(wd, x, y, b)
	if (not wd.active) then
		return
	end
	
	if wd.x and wd.y and wd.w and wd.h then 	--Basicamente, se é um widget clicavel(label nao é)
		if ((x > wd.x) and (x < wd.x + wd.w) and (y > wd.y) and (y < wd.y + wd.h)) then 	--Verifica se clicou dentro do widget
			if (wd.wType == widgetType.button) then 	--Chama o callback se for botao
				if(love.timer.getTime()-lastClick>clickCooldown)then
					wd.callback(b)
					lastClick = love.timer.getTime()
				end
				
			elseif (wd.wType == widgetType.textBox) then 	--Transfere o foco se for textBox
				textBoxFocus = wd

			end
			if (wd.children) then 
				for i,child in ipairs(wd.children) do
					self:mousepressed(child, x, y, b)
				end
			end
		elseif (wd == textBoxFocus) then
			textBoxFocus = nil
		end

	end
	

end

function gui:textinput(t)
	if textBoxFocus then
		textBoxFocus.text = textBoxFocus.text..t
	end
end

function gui:keypressed(k)
	if textBoxFocus then
		if (k == "backspace") then
	        local byteoffset = utf8.offset(textBoxFocus.text, -1)
	 
	        if byteoffset then
	            textBoxFocus.text = string.sub(textBoxFocus.text, 1, byteoffset - 1)
	        end
		end
		if (k == "return") then
			if (textBoxFocus.callback) then
				textBoxFocus.callback()
			end
		end
	end
end

return setmetatable({new = init},
	{__call = function(_, ...) return init(...) end})