
menu = {}


function menu:init()

    originalSize = vector(love.graphics.getWidth(),love.graphics.getHeight())

	love.graphics.setBackgroundColor(Color(120):value())
    love.graphics.setFont(font)


    numTilesX = math.ceil(love.graphics.getWidth() / texTileBg:getWidth())*1.1
    numTilesY = math.ceil(love.graphics.getHeight() / texTileBg:getHeight())*1.1
    menuBgBatch = love.graphics.newSpriteBatch(texTileBg, numTilesX*numTilesY, "static")
    for i=0,numTilesX do
        for j=0,numTilesY do
            sPos = vector(i*texTileBg:getWidth(), j*texTileBg:getHeight())
            menuBgBatch:add(sPos.x,sPos.y,0)
        end
    end

    frMenu = GUI:Frame({childHAlign = "right", childVAlign = "center", layout = "gridH", padding = 20* love.window.getPixelScale()})
    frButtons = GUI:Frame({x = -250*love.window.getPixelScale(),
                            w =250*love.window.getPixelScale(), layout = "boxV",
                            panelType = "button", color = Color(20, 20, 100), padding = 10* love.window.getPixelScale()})


    frButtons:addChild(GUI:Label({text=""}))
    frButtons:addChild(GUI:Button({text = "Jogar", callback = btJogarClick, color = Color(200, 200, 200), hoverColor = Color(80, 80, 250)}))
    frButtons:addChild(GUI:Button({text = "Opções", callback = btSemSuporte, color = Color(200, 200, 200), hoverColor = Color(80, 80, 250)}))
    frButtons:addChild(GUI:Button({text = "Placar", callback = btSemSuporte, color = Color(200, 200, 200), hoverColor = Color(80, 80, 250)}))
    frButtons:addChild(GUI:Button({text = "Sair", callback = btSairClick, color = Color(200, 200, 200), hoverColor = Color(80, 80, 250)}))
    frButtons:addChild(GUI:Label({text=""}))
    lbVersion = GUI:Label({text="v0.2 beta", font = smallFont, x = -100*love.window.getPixelScale(), y = -30*love.window.getPixelScale()})

    frMenu:addChild(GUI:Label({text = "OmniBlocks", valign = "top", halign = "left", font = bigFont, color = Color(200, 200, 200)}))
    frMenu:addChild(frButtons)

end

function menu:enter()
    love.graphics.setFont(font)
    love.window.setMode(originalSize.x, originalSize.y, {vsync = false})
end

function btJogarClick(b)
    Gamestate.switch(game)
end

function btSairClick(b)
    love.event.quit()
end
local contASD = 0
function btSemSuporte(b)
    contASD = contASD + 1
    if contASD >= 10 then
        lbVersion:setText(love.window.getPixelScale())
    end
    if b.text == "Ainda não existe" then return end
    local textAnt = b.text
    b.text = ("Ainda não existe")
    b.font = smallFont
    Timer.after(1, function()
        b.text = textAnt
        b.font = font
        end)

end

function menu:draw()
    love.graphics.setColor(10,10,10,200)
    love.graphics.draw(menuBgBatch)

    GUI:draw(frMenu)
    GUI:draw(lbVersion)
end

function menu:mousepressed(x,y,b)
    GUI:mousepressed(frMenu, x, y, b)
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
