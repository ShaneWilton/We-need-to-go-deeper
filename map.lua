require "lib/essential"

Tile = class("Tile")

function Tile:initialize(obstructsMovement, obstructsSight)
	self.obstructsMovement = obstructsMovement
	self.explored = false
	self.obstructsSight = obstructsSight
end

Map = class("Map")

function Map:initialize(width, height)
	self.width = width
	self.height = height
	self.tileMap = {}
	self:generateCellularAutomata(0.45, 5)
end

function Map:generateCellularAutomata(fillProbability, iterations)
	for x = 1, self.width do
		self.tileMap[x] = {}
		for y = 1, self.height do
			self.tileMap[x][y] = Tile:new(true, true)
		end
	end
	for x = 2, self.width - 1 do
		for y = 2, self.height - 1 do
			if math.random() < fillProbability then
				self.tileMap[x][y] = Tile:new(true, true)
			else
				self.tileMap[x][y] = Tile:new(false, false)
			end
		end
	end
	for i = 1, iterations do
		local temp = {}
		for x = 1, self.width do
			temp[x] = {}
			for y = 1, self.height do
				temp[x][y] = self.tileMap[x][y]
			end
		end
		for x = 2, self.width - 1 do
			for y = 2, self.height - 1 do
				local numberOfWalls = self:countNeighbouringWalls(x, y)
				if temp[x][y].obstructsMovement == false then
					if numberOfWalls > 5 then
						temp[x][y].obstructsSight = true
						temp[x][y].obstructsMovement = true
					end
				elseif numberOfWalls < 4 then
					temp[x][y].obstructsSight = false
					temp[x][y].obstructsMovement = false
				end
			end
		end
		for x = 1, self.width do
			for y = 1, self.height do
				self.tileMap[x][y] = temp[x][y]
			end
		end
	end
end

function Map:countNeighbouringWalls(x, y)
	local sum = 0
	for i = -1, 1 do
		for j = -1, 1 do
			if self.tileMap[x + i][y + j].obstructsMovement then
				sum = sum + 1
			end
		end
	end
	return sum
end

function Map:draw(offset, tilenum)
	offset = offset or Vector2d:new(0,0)
	if not tilenum then
		tileSize = Vector2d:new(love.graphics.getWidth()/self.width, love.graphics.getHeight()/self.height)
	else
		tileSize = Vector2d:new(love.graphics.getWidth()/tilenum.x, love.graphics.getHeight()/tilenum.y)
	end
	local offX = tileSize.x*offset.x
	local offX2 = love.graphics.getWidth()--offX+love.graphics.getWidth()
	local offY = tileSize.y*offset.y
	local offY2 = love.graphics.getHeight()--offY+love.graphics.getHeight()
	for x = 1, self.width do
		local x2 = (x-1)*tileSize.x+offX
		for y = 1,self.height do
			local y2 = (y-1)*tileSize.y+offY
			
			if(x2 < offX2  and y2 < offY2  and x2+tileSize.x > 0 and y2+tileSize.y > 0) then
				if(x-5 == offset.x*-1 and y-4 == offset.y*-1) then --cursor
					love.graphics.setColor(0, 0, 150)
				else
					love.graphics.setColor(0, 0, 255)
					if self.tileMap[x][y].obstructsSight then
						love.graphics.setColor(0, 0, 100)
					end--+offX--+offY
				end
				love.graphics.rectangle("fill", x2, y2, tileSize.x, tileSize.y)--+(tileSize.x*offset.x)--+(tileSize.y*offset.y)
			end
		end
	end
end