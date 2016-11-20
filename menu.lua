
menu = {}


function menu:init()

    originalSize = vector(love.graphics.getWidth(),love.graphics.getHeight())

	love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setFont(font)


    numTilesX =  love.graphics.getWidth() / texTileBg:getWidth() * 2
    numTilesY =  love.graphics.getHeight() / texTileBg:getHeight() * 2
    menuBgBatch = love.graphics.newSpriteBatch(texTileBg, numTiles, "static")
    for i=0,numTilesX do
        for j=0,numTilesY do
            sPos = vector(i*texTileBg:getWidth()/2, j*texTileBg:getHeight()/2)
            menuBgBatch:add(sPos.x,sPos.y,0,0.5,0.5)
        end
    end

    pnMenu = GUI:newPanel(0  ,100,love.graphics.getWidth(),love.graphics.getHeight()-200, {layout = "boxV", childHalign = "center", childValign = "center"})

    pnMenu:addChild(GUI:newLabel("Tetris", 0,0,200))

    pnMenu:addChild(GUI:newButton("Jogar", 0, 0, 200, 60, function(b) btJogarClick(b) end, {color = Color(50, 50, 200), hoverColor = Color(80, 80, 250)}))
    pnMenu:addChild(GUI:newButton("Placar", 0, 0, 200, 60, function(b) btPlacarClick(b) end, {color = Color(50, 50, 200), hoverColor = Color(80, 80, 250)}))
    pnMenu:addChild(GUI:newButton("Sair", 0, 0, 200, 60, function(b) btSairClick(b) end, {color = Color(50, 50, 200), hoverColor = Color(80, 80, 250)}))

end

function menu:enter()
    love.graphics.setFont(font)
    love.window.setMode(originalSize.x, originalSize.y, {vsync = false})
end

function btJogarClick(b)
    Gamestate.switch(game)
end

function btPlacarClick(b)
    Gamestate.switch(scoreboard)
end

function btSairClick(b)
    love.event.quit()
end


function menu:draw()
    love.graphics.setColor(10,10,10,200)
    love.graphics.draw(menuBgBatch)
    
    GUI:draw(pnMenu)
end

function menu:mousepressed(x,y,b)
    GUI:mousepressed(pnMenu, x, y, b)
end

function menu:textinput(t)
    GUI:textinput(t)
end

function menu:keypressed(k)
	GUI:keypressed(k)
    if(k=="return") then
        --Gamestate.switch(game)
	end
end