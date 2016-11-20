

GameMap = Class{}

function GameMap:init(size, tileSize, pos)
	self.size = size
	self.layerCount = math.floor(size/2-1)
	self.tileSize = tileSize
	self.pos = pos or vector(0,0)


	self.centerPos = self.pos + vector((size/2*tileSize)-(tileSize/2),(size/2*tileSize)-(tileSize/2))
	self.localCenter = self:screenToLocal(self.centerPos)
end

--(Re)Inicializa as matrizes
function GameMap:resetMap()
	self.grid = {}
	self.colorGrid = {}
	self.isStatic = {}

	for i = 1, self.size do
		self.grid[i] = {}
		self.colorGrid[i] = {}
		self.isStatic[i] = {}
		for j = 1, self.size do
			if(i==self.localCenter.x and j==self.localCenter.y) then
				self.grid[i][j] = true
				self.colorGrid[i][j] = Color(240,240,240)
			else
				self.grid[i][j] = false
				self.colorGrid[i][j] = Color(255,255,255)
			end
			self.isStatic[i][j] = true
		end
	end
end

function GameMap:checkLayers()
	for i=self.layerCount,1, -1 do
		if(self:checkLayer(i)) then
			self:deleteLayer(i)
			self:collapseLayer(i+1)
			Signal.emit("layerComplete", i)
		end
	end
end

function GameMap:isMapClear()
	local clear = true
	for i=1,self.layerCount do
		if(not self:checkLayerClear(i))then
			clear = false
			break
		end
	end
	return clear
end

--Retorna verdadeiro se a camada l estiver completa
function GameMap:checkLayer(l)
	c = self.localCenter.x
	i = c-l
	j = c-l
	complete = true
	for i= c-l,c+l do
		if( not self.grid[i][j] or not self.grid[j][i]) then
			complete = false
			break
		end
	end
	i = c+l
	if (complete) then
		for j=c-l,c+l do

			if(not self.grid[i][j] or not self.grid[j][i]) then
				complete = false
				break
			end	
		end
	end
	return complete
end

--Retorna verdadeiro se a camada l está totalmente limpa
function GameMap:checkLayerClear(l)
	c = self.localCenter.x
	i = c-l
	j = c-l
	clear = true
	for i= c-l,c+l do
		if(self.grid[i][j] or self.grid[j][i]) then
			clear = false
			break
		end
	end
	i = c+l
	if (clear) then
		for j=c-l,c+l do
			if(self.grid[i][j] or self.grid[j][i]) then
				clear = false
				break
			end	
		end
	end
	return clear
end

function GameMap:deleteLayer(l)
	c = self.localCenter.x
	i = c-l
	j = c-l

	for i= c-l,c+l do
		self.grid[i][j] = false
		if(j~=i)then
			self.grid[j][i] = false
		end
	end

	i = c+l
	for j=c-l,c+l do
		self.grid[i][j] = false
		if(j~=i)then
			self.grid[j][i] = false
		end
	end
end

--Desaba a camada l e todas as camadas acima recursivamente
function GameMap:collapseLayer(l)
	if (l<=1) then
		return
	end
	c = self.localCenter.x

	if (self.grid[c][c-l]) then 	--Peca central de cima
		self:moveTile(c,c-l,c,c-l+1)
	end
	if (self.grid[c+l][c]) then 	--Peca central da direita
		self:moveTile(c+l,c,c+l-1,c)
	end
	if (self.grid[c][c+l]) then 	--Peca central de baixo
		self:moveTile(c,c+l,c,c+l-1)
	end
	if (self.grid[c-l][c]) then 	--Peca central da esquerda
		self:moveTile(c-l,c,c-l+1,c)
	end

	--Cantos
	if (self.grid[c-l][c-l] and not self.grid[c-l+1][c-l+1]) then 	--Sup. Esq.
		self:moveTile(c-l,c-l,c-l+1,c-l+1)
	end
	if (self.grid[c+l][c-l] and not self.grid[c+l-1][c-l+1]) then 	--Sup. Dir.
		self:moveTile(c+l,c-l,c+l-1,c-l+1)
	end
	if (self.grid[c+l][c+l] and not self.grid[c+l-1][c+l-1]) then 	--Inf. Dir.
		self:moveTile(c+l,c+l,c+l-1,c+l-1)
	end
	if (self.grid[c-l][c+l] and not self.grid[c-l+1][c+l-1]) then 	--Inf. Esq.
		self:moveTile(c-l,c+l,c-l+1,c+l-1)
	end

	--Lado de cima
	for i=c+1,c+l-1 do 	--Lado direito
		if(self.grid[i][c-l]) then
			if(not self.grid[i-1][c-l+1]) then
				self:moveTile(i,c-l,i-1,c-l+1)
			elseif(not self.grid[i][c-l+1]) then
				self:moveTile(i,c-l,i,c-l+1)
			end
		end
	end
	for i=c-1,c-l+1,-1 do 	--Lado esquerdo
		if(self.grid[i][c-l]) then
			if(not self.grid[i+1][c-l+1]) then
				self:moveTile(i,c-l,i+1,c-l+1)
			elseif(not self.grid[i][c-l+1]) then
				self:moveTile(i,c-l,i,c-l+1)
			end
		end
	end

	--Lado de baixo
	for i=c+1,c+l-1 do 	--Lado direito
		if(self.grid[i][c+l]) then
			if(not self.grid[i-1][c+l-1]) then
				self:moveTile(i,c+l,i-1,c+l-1)
			elseif(not self.grid[i][c+l-1]) then
				self:moveTile(i,c+l,i,c+l-1)
			end
		end
	end
	for i=c-1,c-l+1,-1 do 	--Lado esquerdo
		if(self.grid[i][c+l]) then
			if(not self.grid[i+1][c+l-1]) then
				self:moveTile(i,c+l,i+1,c+l-1)
			elseif(not self.grid[i][c+l-1]) then
				self:moveTile(i,c+l,i,c+l-1)
			end
		end
	end

	--Lado direito
	for i=c+1,c+l-1 do 	--Lado de baixo
		if(self.grid[c+l][i]) then
			if(not self.grid[c+l-1][i-1]) then
				self:moveTile(c+l,i,c+l-1,i-1)
			elseif(not self.grid[c+l-1][i]) then
				self:moveTile(c+l,i,c+l-1,i)
			end
		end
	end
	for i=c-1,c-l+1,-1 do 	--Lado de cima
		if(self.grid[c+l][i]) then
			if(not self.grid[c+l-1][i+1]) then
				self:moveTile(c+l,i,c+l-1,i+1)
			elseif(not self.grid[c+l-1][i]) then
				self:moveTile(c+l,i,c+l-1,i)
			end
		end
	end

	--Lado esquerdo
	for i=c+1,c+l-1 do 	--Lado de baixo
		if(self.grid[c-l][i]) then
			if(not self.grid[c-l+1][i-1]) then
				self:moveTile(c-l,i,c-l+1,i-1)
			elseif(not self.grid[c-l+1][i]) then
				self:moveTile(c-l,i,c-l+1,i)
			end
		end
	end
	for i=c-1,c-l+1,-1 do 	--Lado de cima
		if(self.grid[c-l][i]) then
			if(not self.grid[c-l+1][i+1]) then
				self:moveTile(c-l,i,c-l+1,i+1)
			elseif(not self.grid[c-l+1][i]) then
				self:moveTile(c-l,i,c-l+1,i)
			end
		end
	end

	


	if (l<self.layerCount) then 
		self:collapseLayer(l+1)
	end
end

function GameMap:moveTile(x1,y1,x2,y2)
	Signal.emit("moveTile",x1,y1,x2,y2)
	self.grid[x2][y2] = true
	self.grid[x1][y1] = false
	self.colorGrid[x2][y2] = self.colorGrid[x1][y1]
end

function GameMap:screenToLocal(v)
	return (v - self.pos) / self.tileSize
end

function GameMap:localToScreen(v)
	return self.pos + (v * self.tileSize)
end