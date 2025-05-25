local Class = require "libs.hump.class"
local Anim8 = require "libs.anim8"
local Timer = require "libs.hump.timer"
local Enemy = require "src.Enemy"
local Hbox = require "src.Hbox"
local Sounds = require "src.Sounds"

-- Idle Animation Resources
local idleSprite = love.graphics.newImage("graphics/mobs/minotaur/Idle-Sheet.png")
local idleGrid = Anim8.newGrid(128, 128, idleSprite:getWidth(), idleSprite:getHeight())
local idleAnim = Anim8.newAnimation(idleGrid('1-4',1),0.2)

-- Walk Animation Resources
local walkSprite = love.graphics.newImage("graphics/mobs/minotaur/Walk-Sheet.png")
local walkGrid = Anim8.newGrid(128, 128, walkSprite:getWidth(), walkSprite:getHeight())
local walkAnim = Anim8.newAnimation(walkGrid('1-6',1),0.2)

-- Run Animation Resources
local runSprite = love.graphics.newImage("graphics/mobs/minotaur/Run-Sheet.png")
local runGrid = Anim8.newGrid(128, 128, runSprite:getWidth(), runSprite:getHeight())
local runAnim = Anim8.newAnimation(runGrid('1-6',1),0.15)

-- Hit Animation Resources
local hitSprite = love.graphics.newImage("graphics/mobs/minotaur/Hit-Sheet.png")
local hitGrid = Anim8.newGrid(128, 128, hitSprite:getWidth(), hitSprite:getHeight())
local hitAnim = Anim8.newAnimation(hitGrid('1-4',1),0.2)

local Minotaur = Class{__includes = Enemy}
function Minotaur:init(type)
    Enemy.init(self)

    self.name = "minotaur"
    self.type = type
    if type == nil then self.type = "normal" end

    self.dir = "l"
    self.state = "idle"
    self.animations = {}
    self.sprites = {}
    self.hitboxes = {}
    self.hurtboxes = {}

    self.hp = 50
    self.score = 300
    self.damage = 15

    self:setAnimation("idle", idleSprite, idleAnim)
    self:setAnimation("walk", walkSprite, walkAnim)
    self:setAnimation("run", runSprite, runAnim)
    self:setAnimation("hit", hitSprite, hitAnim)

    self:setHurtbox("idle", 32, 32, 64, 64)
    self:setHurtbox("walk", 32, 32, 64, 64)
    self:setHurtbox("run", 32, 32, 64, 64)
    self:setHurtbox("hit", 28, 28, 72, 72)

    self:setHitbox("attack", 70, 30, 40, 60)

    self.visionRange = 200
    self.stateTimer = 0
    self.nextStateTime = math.random(2,5)
end

function Minotaur:changeState()
    local choices = {"idle", "walk", "run"}
    self.state = choices[math.random(#choices)]
end

function Minotaur:update(dt, dungeon, player)
    -- First check: can we see the player?
    local dx = player.x - self.x
    local dy = player.y - self.y
    if math.abs(dx) + math.abs(dy) < self.visionRange then
        -- Chase player
        self.state = "run"
        if math.abs(dx) > math.abs(dy) then
            if dx < 0 then
                self.dir = "l"
                if not dungeon:leftCollision(self, 0) then
                    self.x = self.x - 64 * dt
                else
                    self:changeDirection()
                end
            else
                self.dir = "r"
                if not dungeon:rightCollision(self, 0) then
                    self.x = self.x + 64 * dt
                else
                    self:changeDirection()
                end
            end
        else
            if dy < 0 then
                self.y = self.y - 64 * dt
            else
                self.y = self.y + 64 * dt
            end
        end
    else
        -- Not seeing player: random behavior
        self.stateTimer = self.stateTimer + dt
        if self.stateTimer >= self.nextStateTime then
            self:changeState()
            self.stateTimer = 0
            self.nextStateTime = math.random(2,5)
        end

        -- Move if walking or running
        if self.state == "walk" then
            if self.dir == "l" then
                if dungeon:leftCollision(self, 0) then
                    self:changeDirection()
                else
                    self.x = self.x - 32 * dt
                end
            else
                if dungeon:rightCollision(self, 0) then
                    self:changeDirection()
                else
                    self.x = self.x + 32 * dt
                end
            end
        elseif self.state == "run" then
            if self.dir == "l" then
                if dungeon:leftCollision(self, 0) then
                    self:changeDirection()
                else
                    self.x = self.x - 64 * dt
                end
            else
                if dungeon:rightCollision(self, 0) then
                    self:changeDirection()
                else
                    self.x = self.x + 64 * dt
                end
            end
        end
    end

    self.animations[self.state]:update(dt)
end

function Minotaur:hit(damage, direction)
    if self.invincible then return end

    self.invincible = true
    self.hp = self.hp - damage
    self.state = "hit"
    Sounds["mob_hurt"]:play()

    if self.hp <= 0 then
        self.died = true
    end

    Timer.after(1, function() self:endHit(direction) end)
    Timer.after(0.9, function() self.invincible = false end)
end

function Minotaur:endHit(direction)
    if self.dir == direction then
        self:changeDirection()
    end
    self.state = "walk"
end

return Minotaur
