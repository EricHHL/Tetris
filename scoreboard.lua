scoreboard = {}


function scoreboard:init()
	

end

function scoreboard:enter()
	pnScoreboard = GUI.Frame({x = 100, y = 50, w = love.graphics.getWidth()-200, h = love.graphics.getHeight()-100, layout = "boxV", childHalign = "center", childValign = "center", padding = 6})
	pnScoreboard:addChild(GUI.Label({text = "Placar"}))
    for i, score, name in highscore() do
    	if(name~="")then
			pnScoreboard:addChild(GUI.Label({text = i.."º "..name..": "..score, w = 500}))
		end
	end
	pnScoreboard:addChild(GUI.Button({text = "Voltar", callback = function() Gamestate.switch(menu) end, halign = "left", panelType = "textBox"}))
end


function scoreboard:draw()
	GUI:draw(pnScoreboard)
end

function scoreboard:mousepressed(x, y, b)
	GUI:mousepressed(pnScoreboard, x, y, b)
end