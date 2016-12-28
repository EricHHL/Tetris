local startID = 0
local startX = 0
local startY = 0

local moved = false
local lastMove = love.timer.getTime()
local moveCount = 1
local asd = 25

function love.touchmoved(id, ax, ay, dx, dy)
    if isGameOver then
        return
    end
    if id ~= startID then return end
    
    --pprint("dx = "..dx, "dx")
    --pprint("dy = "..dy, "dy")
    ax = ax / love.window.getPixelScale()
    ay = ay / love.window.getPixelScale()
    dx = ax - startX--dx / love.window.getPixelScale()
    dy = ay - startY--dy / love.window.getPixelScale()


    if (pieceDirection.x == 0) then
        if dx > asd and curPiece.iPos.x <(gm.size - 1) then
            movePiece(vector(1,0))
            startX = startX + asd
            lastMove = love.timer.getTime()
            animatePiece()
            moved = true
        elseif dx < -asd and curPiece.iPos.x > 0 then
            movePiece(vector(-1,0))
            startX = startX - asd
            lastMove = love.timer.getTime()
            animatePiece()
            moved = true
        end
        if (pieceDirection.y == 1 and dy > asd*2) or(pieceDirection.y == -1 and dy < -asd*2) and inputEnable then
            dropPiece()
        end
    else
        if dy < -asd and curPiece.iPos.y > 0 then
            movePiece(vector(0,-1))
            startY = startY - asd
            lastMove = love.timer.getTime()
            animatePiece()
            moved = true
        elseif dy > asd and curPiece.iPos.y <(gm.size - 1) then
            movePiece(vector(0,1))
            startY = startY + asd
            lastMove = love.timer.getTime()
            animatePiece()
            moved = true
        end

        if (pieceDirection.x == 1 and dx > asd*2) or(pieceDirection.x == -1 and dx < -asd*2) and inputEnable then
            dropPiece()
            startID = -1
        end
    end

    if love.timer.getTime() - lastMove > 0.3 then
        moveCount = 1
    end

    -- problema: Isso vai resetar a animação toda vez que qualquer tecla for pressionada
end


function love.touchpressed(id, x, y)
     if isGameOver then
        return
    end

    startID = id
    startX = x / love.window.getPixelScale()
    startY = y / love.window.getPixelScale()
    moved = false
end

function love.touchreleased(id, x, y)
     if isGameOver then
        return
    end
    if id ~= startID then
        return
    end
    x = x / love.window.getPixelScale()
    y =y / love.window.getPixelScale()
    if math.abs(startX-x) < 10 and math.abs(startY-y) < 10 and not moved then
        rotatePiece()
    end     
end