local Class = require "libs.hump.class"
local Tileset = require "src.game.Tileset"

local Dungeon = Class{}

function Dungeon:init()
    self.tileSize = 32  -- Tile size (assuming the tiles are 32x32)
    self.tileset = nil
    self.map = {}
end

function Dungeon:load()
    -- Load the new tileset image
    local img = love.graphics.newImage("/graphics/stage/Tilemap Dungeon original size.png")
    self.tileset = Tileset(img, self.tileSize)
    
    -- Generate a new map layout (you can customize this)
    self:generateMap()
end

function Dungeon:generateMap()
    -- A sample dungeon map layout with different tiles
    -- We'll use a 2D array with tile IDs: 1 for walls, 0 for floors, etc.
    self.map = {
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 1, 1, 1, 1, 1, 0, 0, 1},
        {1, 0, 1, 0, 0, 0, 1, 0, 1, 1},
        {1, 0, 1, 0, 1, 1, 1, 0, 0, 1},
        {1, 0, 0, 0, 1, 0, 1, 1, 0, 1},
        {1, 0, 1, 1, 0, 1, 1, 0, 0, 1},
        {1, 0, 0, 0, 1, 0, 0, 0, 0, 1},
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    }
    -- You can change the map and fill it with more complex dungeon designs
end

function Dungeon:update(dt)
    -- Future improvements: Add traps, doors, water interactions, etc.
end

function Dungeon:draw()
    -- Iterate through the map and draw the corresponding tile at each position
    for y = 1, #self.map do
        for x = 1, #self.map[y] do
            local tileID = self.map[y][x]
            if tileID and tileID ~= 0 then
                local tile = self.tileset:get(tileID)
                if tile then
                    love.graphics.draw(self.tileset:getImage(), tile.quad, (x - 1) * self.tileSize, (y - 1) * self.tileSize)
                end
            end
        end
    end
end

function Dungeon:tileAt(x, y)
    -- Get the tile at a specific map position (x, y)
    local col = math.floor(x / self.tileSize) + 1
    local row = math.floor(y / self.tileSize) + 1

    if self.map[row] and self.map[row][col] then
        return self.map[row][col]
    else
        return 1 -- Treat out-of-bounds as wall
    end
end

function Dungeon:isSolid(x, y)
    -- Check if the tile at (x, y) is solid (i.e., a wall)
    return self:tileAt(x, y) ~= 0
end

function Dungeon:checkWallCollision(entity, nextX, nextY)
    -- Check if the entity's hurtbox collides with any walls in the dungeon
    local box = entity:getHurtbox()

    -- Calculate the position of the entity's hurtbox in the next movement
    local left = box:left() + (nextX - entity.x)
    local right = box:right() + (nextX - entity.x)
    local top = box:top() + (nextY - entity.y)
    local bottom = box:bottom() + (nextY - entity.y)

    -- Check if any corner of the hurtbox collides with a wall
    return
        self:isSolid(left, top) or
        self:isSolid(right - 1, top) or
        self:isSolid(left, bottom - 1) or
        self:isSolid(right - 1, bottom - 1)
end

function Dungeon:getWidth()
    return #self.map[1] * self.tileSize
end

function Dungeon:getHeight()
    return #self.map * self.tileSize
end

return Dungeon
