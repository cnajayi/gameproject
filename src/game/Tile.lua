local Class = require "libs.hump.class"

local Tile = Class{}

function Tile:init(id, quad)
    self.id = id -- Tile ID
    self.quad = quad -- The tile's graphical representation (a quad)
    self.solid = true -- Whether the tile is solid (can block movement)
end

return Tile
