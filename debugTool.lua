
debugTool = {}

local enabled = false

local pprintList = {}


local function init()
	
end

local fieldList = {}

--Print para depurar valores contínuos
function pprint(text, name)
	text = tostring(text)
	if name then
		pprintList[name] = text
	else
		pprintList[#pprintList+1] = text
	end
end

local _draw = love.draw --Dá override no love.draw, mas guarda a funcao anterior para poder chamar ela
function love.draw()
	_draw()
	love.graphics.setColor(255,255,255)
	local j = 2
	for i,v in ipairs(pprintList) do
		love.graphics.print(v, 10, j*50)
		pprintList[i] = nil
		j = j + 1
	end
	for k,v in pairs(pprintList) do
		love.graphics.print(v, 10, j*50)
		j = j + 1
	end
end

return init()