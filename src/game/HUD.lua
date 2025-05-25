local Class = require "libs.hump.class"

-- Here we create a specific font in our HUD
local hudFont = love.graphics.newFont("fonts/Abaddon Bold.ttf",16)

local HUD = Class{}
function HUD:init(player)
    self.player = player
end

function HUD:update(dt)
end

function HUD:draw()
    --love.graphics.print( text, font, x, y )
    love.graphics.print("Health:"..self.player.health,hudFont,5,1)
    love.graphics.print("Keys:"..self.player.keys,hudFont,120,1)
    love.graphics.print("Score:"..self.player.score,hudFont,220,1)
end

return HUD
