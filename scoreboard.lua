scoreboard = {}


function scoreboard:init()
	

end

function scoreboard:enter()
	pnScoreboard = GUI:newPanel(100, 50, love.graphics.getWidth()-200, love.graphics.getHeight()-100, {layout = "boxV", childHalign = "center", childValign = "center", padding = 6})
	pnScoreboard:addChild(GUI:newLabel("Placar",0,0,300))
    for i, score, name in highscore() do
    	if(name~="")then
			pnScoreboard:addChild(GUI:newLabel(i.."º "..name..": "..score, 0, 0, 500))
		end
	end
	pnScoreboard:addChild(GUI:newButton("Voltar",0,0,120,40,function() Gamestate.switch(menu) end, {halign = "left", panelType = "textBox"}))
end


function scoreboard:draw()
	GUI:draw(pnScoreboard)
end

function scoreboard:mousepressed(x, y, b)
	GUI:mousepressed(pnScoreboard, x, y, b)
end