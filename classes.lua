
Piece = Class{}
function Piece:init(tiles, color)
	self.tiles = tiles
	self.color = color

	self.isInstance = false
end

function Piece:instance(pos)
	newTiles = {}
	for i = 1, #self.tiles do
		newTiles[i] = self.tiles[i]:clone()
	end
	pieceIns = Piece(newTiles,self.color)
	pieceIns.pos = pos
	pieceIns.iPos = pos
	pieceIns.isInstance = true
	return pieceIns
end

function Piece:move(dir)
	if(not self.isInstance) then
		return
	end
	return self.iPos + dir
end

Color = Class{}
function Color:init(r,g,b,a)
	self.red = r
	self.green = g or r
	self.blue = b or r
	self.alpha = a or 255
end

function Color:value()
	return self.red, self.green, self.blue, self.alpha
end

function round(num) return math.floor(num+.5) end