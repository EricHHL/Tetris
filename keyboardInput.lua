function keyInput(key)
	if (pieceDirection.x == 0) then
        if key == 'right' and curPiece.iPos.x <(gm.size - 1) then
            movePiece(vector(1,0))
        elseif key == 'left' and curPiece.iPos.x > 0 then
            movePiece(vector(-1,0))
        end
        if (pieceDirection.y == 1 and key == 'down') or(pieceDirection.y == -1 and key == 'up') and inputEnable then
            dropPiece()
        end
    else
        if key == 'up' and curPiece.iPos.y > 0 then
            movePiece(vector(0,-1))
        elseif key == 'down' and curPiece.iPos.y <(gm.size - 1) then
            movePiece(vector(0,1))
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
end