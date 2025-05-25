local Class = require "libs.hump.class"
local Tile = require "src.game.Tile"

local Tileset = Class{}

function Tileset:init(img, tileSize)
    self.tileSize = tileSize
    self.tileImage = img
    
    -- Calculate how many rows and columns of tiles there are in the image
    self.rowCount = math.floor(self.tileImage:getHeight() / self.tileSize)
    self.colCount = math.floor(self.tileImage:getWidth() / self.tileSize)
    
    self.tiles = {}
    self:createTiles()
end

function Tileset:createTiles()
    local index = 1
    for row = 1, self.rowCount do
        for col = 1, self.colCount do
            self.tiles[index] = self:newTile(row, col, index)
            index = index + 1
        end
    end
end

function Tileset:newTile(row, col, index)
    -- Create a new tile from the sprite sheet
    local quad = love.graphics.newQuad(
        (col - 1) * self.tileSize,
        (row - 1) * self.tileSize,
        self.tileSize,
        self.tileSize,
        self.tileImage:getWidth(),
        self.tileImage:getHeight()
    )
    return Tile(index, quad)
end

function Tileset:get(index)
    return self.tiles[index]
end

function Tileset:getImage()
    return self.tileImage
end

return Tileset
