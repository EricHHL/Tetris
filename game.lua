require("gamemap")
require("classes")

game = { }

debugMode = false

background = Color(120)

anims = { }

baseUpdateFreq = 0.3

nextUpdateHandle = nil

inputEnable = true

score = 0

-- TODO: No final, mostrar maior combo e tempo jogado

function game:init()

	texSideMenu = love.graphics.newImage("textures/sideMenu.png")
    texBorder = love.graphics.newImage("textures/bg.png")
    borderSize = 20
    
    borderScale = (31*22)*(texBorder:getWidth()/(texBorder:getWidth()-borderSize)) / (texBorder:getWidth())
    gm = GameMap(31, 22,vector(10*borderScale,10*borderScale))
    windowSize = vector((texBorder:getWidth() + texSideMenu:getWidth())*borderScale,texBorder:getWidth()*borderScale)
    love.window.setMode(windowSize.x, windowSize.y, { resizable = false, vsync = false, borderless = false })
    scale = gm.tileSize / texTile:getWidth()

    bgBatch = love.graphics.newSpriteBatch(texTileBg, 31*31, "static")
    for i=0,gm.size-1 do
    	for j=0,gm.size-1 do
    		sPos = gm:localToScreen(vector(i,j))
    		bgBatch:add(sPos.x,sPos.y,0,scale,scale)
    	end
    end

    pieces = {
        Piece(-- T
        { vector(-1, 0), vector(0, 0), vector(1, 0), vector(0, - 1) },Color(50,200,200)),
        Piece(-- Z
        { vector(-1, 0), vector(0, 0), vector(0, - 1), vector(-1, 1) },Color(50,200,50)),
        Piece(-- S
        { vector(-1, 0), vector(0, 0), vector(0, 1), vector(-1, - 1) },Color(200,50,200)),
        Piece(-- I
        { vector(-1, 0), vector(0, 0), vector(1, 0), vector(2, 0) },Color(200,50,50)),
        Piece(-- O
        { vector(-1, 0), vector(0, 0), vector(0, - 1), vector(-1, - 1) },Color(200,200,50)),
        Piece(-- L
        { vector(0, - 1), vector(0, 0), vector(-1, 0), vector(-2, 0) },Color(200,120,50)),
        Piece(-- J
        { vector(0, - 1), vector(0, 0), vector(1, 0), vector(2, 0) },Color(50,50,200))
    }

    --Inicializa GUI
    frPause = GUI:Frame({x = gm.centerPos.x+gm.tileSize/2 - 150, y =gm.centerPos.y - 120, w = 300, h = 240, panelType = "textBox", color = Color(200), layout = "boxV", childHalign = "center"})
    frPause:addChild(GUI:Label({text = "Pausado", color = Color(0), valign = "center"}))
    frPause:addChild(GUI:Button({text = "Continuar", callback = function() pause = false end, valign = "bottom"}))
    frPause:addChild(GUI:Button({text = "Menu", callback = function() 
            Timer.cancel(nextUpdateHandle)
            Gamestate.switch(menu) 
        end, valign = "top"}))
    
    frGameOver = GUI:Frame({x = gm.centerPos.x+gm.tileSize/2 - 150, y =gm.centerPos.y - 200, w = 300, h =400, panelType = "textBox", color = Color(200), layout = "boxV", childHalign = "center"})
    
    frGameOver:addChild(GUI:Label({text = "Game Over", color = Color(0)}))
    lbPontuacao = GUI:Label({font = smallFont, color = Color(0)})
    frGameOver:addChild(lbPontuacao)

    frHighscore = GUI:Frame({w = 300, h = 250, layout = "boxV", childHalign = "center", weight = 3})

    lbRecord = GUI:Label({font = smallFont, color = Color(0)})
    tbName = GUI:TextBox({callback = function() btSalvarClick() end})
    btSalvar = GUI:Button({text = "Salvar", callback = function() btSalvarClick() end, weight = 1.5})
    frHighscore:addChild(lbRecord)
    frHighscore:addChild(tbName)
    frHighscore:addChild(btSalvar)

    frGameOver2 = GUI:Frame({w = 300, h = 250, layout = "boxV", childHalign = "center", weight = 3, text = "go2"})

    frGameOver2:addChild(GUI:Frame())
    frGameOver2:addChild(GUI:Button({text = "Novo jogo", callback = function() Gamestate.switch(game) end}))
    frGameOver2:addChild(GUI:Button({text = "Menu", callback = function() Gamestate.switch(menu) end}))

    frHighscore.active = false

    frGameOver:addChild(frGameOver2)
    frGameOver:addChild(frHighscore)


    math.randomseed(os.time())

    Signal.register("moveTile", function(x1, y1, x2, y2)
        gm.isStatic[x2][y2] = false
        local aTile = {
            type = "texture",
            texture = texTile,
            pos = gm:localToScreen(vector(x1,y1)),
            color = gm.colorGrid[x1][y1],
            texScale = scale,
            done = false
        }
        Timer.tween(updateFreq, aTile["pos"], gm:localToScreen(vector(x2,y2)), "in-bounce", function()
            gm.isStatic[x2][y2] = true
            aTile["done"] = true
        end )
        anims[aTile] = true
    end )

    Signal.register("layerComplete", function(l)
        if (love.timer.getTime() - lastScoreTime <= updateFreq * 1.2) then
            lastScore =(lastScore * 0.5) +(l * 8 * 10)
            comboCount = comboCount + 1
        else
            lastScore = l * 8 * 10
            comboCount = 1
            updateFreq = updateFreq * 0.99 ^(1 / 3)
        end
        lastScoreTime = love.timer.getTime()
        lastScore = round(lastScore)
        addScore(lastScore, comboCount)
        TEsound.play(sndLayerComplete, "sfx")
        TEsound.pitch("sfx", 0.9 + 0.1 * comboCount)

        if (gm:isMapClear()) then
            local aText = { type = "text", text = "Clear!", pos = vector(gm.centerPos.x, - 100), color = Color(255, 255, 255, 255), done = false }
            Timer.tween(updateFreq * 2, aText, { pos = vector(gm.centerPos.x, 100), color = Color(255, 255, 255, 0) }, "linear", function()
                aText["done"] = true
            end )
            anims[aText] = true
            addScore(score * 0.1, 0)
        end

    end )
end

function game:enter()
    love.graphics.setBackgroundColor(background:value())
    love.window.setMode(windowSize.x, windowSize.y, { resizable = false, vsync = false, borderless = false })

    gm:resetMap()

    updateFreq = baseUpdateFreq

    pause = false

    score = 0
    lastScore = 0
    lastScoreTime = 0
    comboCount = 0

    isGameOver = false
    tbName.text = ""
    isHighscore = false

    curPiece = newPiece()

    nextUpdateHandle = Timer.after(updateFreq, function() gameUpdate() end)
end

function game:draw()
    love.graphics.setFont(font)

    -- Desenha fundo
    love.graphics.setColor(10,10,10,200);
    love.graphics.draw(bgBatch)

    -- Desenha peca atual
    love.graphics.setColor(curPiece.color:value())
    for indT, tile in ipairs(curPiece.tiles) do
    	sPos = gm:localToScreen(curPiece.pos + tile)
        love.graphics.draw(texTile, sPos.x, sPos.y, 0, scale, scale)
    end

    -- Desenha pecas fixas
    for i = 1, gm.size do
        for j = 1, gm.size do
            if gm.grid[i][j] and gm.isStatic[i][j] then
                love.graphics.setColor(gm.colorGrid[i][j]:value())
                worldPos = gm:localToScreen(vector(i, j))
                love.graphics.draw(texTile, worldPos.x, worldPos.y, 0, scale, scale)
            end
        end
    end

    -- Desenha animacoes
    local toRemove = { }
    for anim in pairs(anims) do
        if (anim.type == "texture") then
            love.graphics.setColor(anim["color"]:value())
            love.graphics.draw(anim["texture"], anim["pos"].x, anim["pos"].y, 0, anim["texScale"], anim["texScale"])
            if (anim["done"]) then
                table.insert(toRemove, anim)
            end
        elseif (anim.type == "text") then
            love.graphics.setColor(anim["color"]:value())
            love.graphics.print(anim["text"], anim["pos"].x, anim["pos"].y)
            if (anim["done"]) then
                table.insert(toRemove, anim)
            end
        end
    end
    for i = 1, #toRemove do
        anims[toRemove[i]] = nil
    end

    -- Desenha UI
    -- TODO: substituir isso com a nova GUI 
	love.graphics.setColor(255,255,255)    
    love.graphics.draw(texBorder, 0, 0, 0, borderScale, borderScale)
    love.graphics.draw(texSideMenu, texBorder:getWidth()*borderScale, 0, 0, borderScale, borderScale)


    love.graphics.setColor(255, 255, 255)

    love.graphics.print("Pontos: " .. score, 10, 10)
    -- love.graphics.print("Ultima: "..lastScore, 10, 30)

    if (pause) then
        GUI:draw(frPause)
    end

    if (isGameOver) then
        GUI:draw(frGameOver)
    end
end

function game:keypressed(key)
    GUI:keypressed(key)
    if (pause or isGameOver) then
        return
    end
    if (pieceDirection.x == 0) then
        if key == 'right' and curPiece.iPos.x <(gm.size - 1) then
            newPos = curPiece:move(vector(1, 0))
            if (isPiecePosValid(newPos) == 0) then
                curPiece.iPos = newPos
                TEsound.play(sndPieceMove)
            end
        elseif key == 'left' and curPiece.iPos.x > 0 then
            newPos = curPiece:move(vector(-1, 0))
            if (isPiecePosValid(newPos) == 0) then
                curPiece.iPos = newPos
                TEsound.play(sndPieceMove)
            end
        end

        if (pieceDirection.y == 1 and key == 'down') or(pieceDirection.y == -1 and key == 'up') and inputEnable then
            dropPiece()
        end
    else
        if key == 'up' and curPiece.iPos.y > 0 then
            newPos = curPiece:move(vector(0, -1))
            if (isPiecePosValid(newPos) == 0) then
                curPiece.iPos = newPos
                TEsound.play(sndPieceMove)
            end
        elseif key == 'down' and curPiece.iPos.y <(gm.size - 1) then
            newPos = curPiece:move(vector(0, 1))
            if (isPiecePosValid(newPos) == 0) then
                curPiece.iPos = newPos
                TEsound.play(sndPieceMove)
            end
        end

        if (pieceDirection.x == 1 and key == 'right') or(pieceDirection.x == -1 and key == 'left') and inputEnable then
            dropPiece()
        end
    end

    if key == 'space' then
        rotatePiece()
    end

    -- problema: Isso vai resetar a animação toda vez que qualquer tecla for pressionada
    animatePiece()
    
    if (key == 'z') then
        gameOver()
    end
end

function game:textinput(t)
    GUI:textinput(t)
end

function game:focus(f)
    if (not f) then
        pause = true
    end
end

-- Funcao chamada a cada updateFreq
function gameUpdate()
    if (isGameOver) then
        return
    end
    inputEnable = true

    pathIsClear = true

    pieceNextPos = curPiece:move(pieceDirection)
    pathIsClear = isPiecePosValid(pieceNextPos)
    if (pathIsClear == 0) then
        curPiece.iPos = pieceNextPos
        animatePiece()
    elseif (pathIsClear == 1) then
        for indT, tile in ipairs(curPiece.tiles) do
            tilePos = tile + curPiece.iPos
            if (gm.grid[tilePos.x][tilePos.y]) then
                gameOver()
                return
            else
                gm.grid[tilePos.x][tilePos.y] = true
            end
            gm.colorGrid[tilePos.x][tilePos.y] = curPiece.color
        end
        TEsound.play(sndPieceTouchDown)
        curPiece = newPiece()
        animatePiece()
        shake = false
        inputEnable = false


    elseif (pathIsClear == 2) then
        curPiece = newPiece()
        animatePiece()
        shake = false
        addScore(-500, 1)
    end
    gm:checkLayers()

    nextUpdateHandle = Timer.after(updateFreq, function() gameUpdate() end)
end

-- Retorna 0 se livre, 1 se colide com outra peça, 2 se fora dos limites; testa todos os tiles da peça atual
function isPiecePosValid(pos)
    for indT, tile in ipairs(curPiece.tiles) do
        nextPos = pos + tile
        isValid = isPosValid(nextPos)
        if (isValid ~= 0) then
            return isValid
        end
    end
    return 0
end

-- Retorna 0 se livre, 1 se colide com outra peça, 2 se fora dos limites
function isPosValid(pos)
    if (pos.x < 1 or pos.x > gm.size or pos.y < 1 or pos.y > gm.size) then
        return 2
    end
    if (gm.grid[pos.x][pos.y]) then
        return 1
    end
    return 0
end

-- Usa tween para mover suavemente a peça da sua posicao atual(.pos) até a posição real(.iPos)
function animatePiece()
    if pieceHandle then
        Timer.cancel(pieceHandle)
    end
    dist =(curPiece.pos - curPiece.iPos):len()
    duration = math.min(updateFreq / 2, 0.1)
    if (dist > 3) then
        duration = updateFreq *(dist / 15)
        -- TEsound.play(sndPieceDrop,"drop")
        -- TEsound.pitch("drop",0.208/duration)	--É irritante
    end
    pieceHandle = Timer.tween(duration, curPiece.pos, curPiece.iPos, 'in-out-quad', function()  end)
end

-- Avança a peça ate colidir com alguma coisa
function dropPiece()
    newPos = curPiece.iPos
    while (isPiecePosValid(newPos) == 0) do
        newPos = newPos + pieceDirection
        if (newPos.x < 1 or newPos.x > gm.size or newPos.y < 1 or newPos.y > gm.size) then
            return
        end
    end
    if (isPiecePosValid(newPos) == 2) then
        return
    end
    newPos = newPos - pieceDirection
    curPiece.iPos = newPos
    animatePiece()

    -- Reseta o contador pro proximo gameUpdate, pra dar tempo pra terminar a animação de drop e dar tempo pro jogador mover a peça
    Timer.cancel(nextUpdateHandle)
    nextUpdateHandle = Timer.after(updateFreq, function() gameUpdate() end)
end

-- Retorna nova instancia de peça usando o vetor pieces
function newPiece()
    newStart = round(love.math.random(0, 3))

    if (newStart == 0) then
        pieceDirection = vector(0, 1)
        pieceIPos = vector(gm.localCenter.x, 2)
        piecePos = vector(gm.localCenter.x, -1)
    elseif (newStart == 1) then
        pieceDirection = vector(-1, 0)
        pieceIPos = vector(gm.size - 2, gm.localCenter.y)
        piecePos = vector(gm.size + 1, gm.localCenter.y)
    elseif (newStart == 2) then
        pieceDirection = vector(0, -1)
        pieceIPos = vector(gm.localCenter.x, gm.size - 2)
        piecePos = vector(gm.localCenter.x, gm.size + 1)
    elseif (newStart == 3) then
        pieceDirection = vector(1, 0)
        pieceIPos = vector(2, gm.localCenter.y)
        piecePos = vector(-1, gm.localCenter.y)
    end
    inst = pieces[round(math.random(1, #pieces))]:instance(pieceIPos)
    inst.pos = piecePos
    return inst
end

-- Gira a peça atual em 90 graus
function rotatePiece()
    origTiles = { }
    for i = 1, #curPiece.tiles do
        origTiles[i] = curPiece.tiles[i]
        curPiece.tiles[i] = curPiece.tiles[i]:perpendicular()
    end
    if (isPiecePosValid(curPiece.iPos) ~= 0) then
        curPiece.tiles = origTiles
        TEsound.play(sndPieceRotateFail)
    else
        TEsound.play(sndPieceRotate)
    end
end

function game:mousepressed(x, y, button)
    if debugMode then
        gm.grid[math.floor(x / gm.tileSize)][math.floor(y / gm.tileSize)] = not gm.grid[math.floor(x / gm.tileSize)][math.floor(y / gm.tileSize)]
    end
    if pause then
        GUI:mousepressed(frPause, x, y, button)
    end
    if isGameOver then
        GUI:mousepressed(frGameOver, x, y, button)
    end
end

function addScore(s, c)
    score = score + s

    local aText = { type = "text", text = "" .. s, pos = gm.centerPos + vector(0, (s / 4)), color = Color(255, 255, 255, 255), done = false }
    Timer.tween(updateFreq * 2, aText, { pos = gm.centerPos + vector(0, -(s / 4)), color = Color(255, 255, 255, 0) }, "linear", function()
        aText["done"] = true
    end )
    anims[aText] = true

    if (c > 1) then
        local aText = { type = "text", text = "Combo x" .. c .. "!", pos = gm.centerPos + vector(0, 40), color = Color(255, 255, 255, 255), done = false }
        Timer.tween(updateFreq * 2, aText, { pos = gm.centerPos + vector(0, - 80), color = Color(255, 255, 255, 0) }, "linear", function()
            aText["done"] = true
        end )
        anims[aText] = true
    end

end

function gameOver()
    print("Game over; Pontuacao: " .. score)
    isGameOver = true

    lbPontuacao:setText("Pontuação: "..score)
    for i, sc, name in highscore() do
        if (i <= 10) then
            if (score>sc) then
            	isHighscore = true
            	highscorePos = i
            	break
            end
        end
    end
    if isHighscore then
        lbRecord:setText(highscorePos.."º lugar")
        frHighscore.active = true
        frGameOver2.active = false
    else
        frHighscore.active = false
        frGameOver2.active = true
    end

    frGameOver:refresh()
end

function btSalvarClick()
    highscore.add(tbName.text, score)
    highscore.save()
    isHighscore = false
    frHighscore.active = false
    frGameOver2.active = true
    frGameOver:refresh()
end