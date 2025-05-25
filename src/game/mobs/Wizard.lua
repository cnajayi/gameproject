local Class = require "libs.hump.class"
local Anim8 = require "libs.anim8"
local Timer = require "libs.hump.timer"
local Enemy = require "src.Enemy"
local Hbox = require "src.Hbox"
local Sounds = require "src.Sounds"

-- Animation Resources
local idleSprite = love.graphics.newImage("graphics/mobs/wizard/Idle.png")
local idleGrid = Anim8.newGrid(128, 128, idleSprite:getWidth(), idleSprite:getHeight())
local idleAnim = Anim8.newAnimation(idleGrid('1-4',1), 0.2)

local walkSprite = love.graphics.newImage("graphics/mobs/wizard/Walk.png")
local walkGrid = Anim8.newGrid(128, 128, walkSprite:getWidth(), walkSprite:getHeight())
local walkAnim = Anim8.newAnimation(walkGrid('1-6',1), 0.2)

local runSprite = love.graphics.newImage("graphics/mobs/wizard/Run.png")
local runGrid = Anim8.newGrid(128, 128, runSprite:getWidth(), runSprite:getHeight())
local runAnim = Anim8.newAnimation(runGrid('1-6',1), 0.15)

local hurtSprite = love.graphics.newImage("graphics/mobs/wizard/Hurt.png")
local hurtGrid = Anim8.newGrid(128, 128, hurtSprite:getWidth(), hurtSprite:getHeight())
local hurtAnim = Anim8.newAnimation(hurtGrid('1-2',1), 0.2)

local deadSprite = love.graphics.newImage("graphics/mobs/wizard/Dead.png")
local deadGrid = Anim8.newGrid(128, 128, deadSprite:getWidth(), deadSprite:getHeight())
local deadAnim = Anim8.newAnimation(deadGrid('1-6',1), 0.2)

local chargeSprite = love.graphics.newImage("graphics/mobs/wizard/Charge.png")
local chargeGrid = Anim8.newGrid(128, 128, chargeSprite:getWidth(), chargeSprite:getHeight())
local chargeAnim = Anim8.newAnimation(chargeGrid('1-4',1), 0.2)

local attack1Sprite = love.graphics.newImage("graphics/mobs/wizard/Attack_1.png")
local attack1Grid = Anim8.newGrid(128, 128, attack1Sprite:getWidth(), attack1Sprite:getHeight())
local attack1Anim = Anim8.newAnimation(attack1Grid('1-6',1), 0.15)

local attack2Sprite = love.graphics.newImage("graphics/mobs/wizard/Attack_2.png")
local attack2Grid = Anim8.newGrid(128, 128, attack2Sprite:getWidth(), attack2Sprite:getHeight())
local attack2Anim = Anim8.newAnimation(attack2Grid('1-6',1), 0.15)

local Wizard = Class{__includes = Enemy}
function Wizard:init(type)
    Enemy.init(self)

    self.name = "wizard"
    self.type = type
    if type == nil then self.type = "normal" end

    self.dir = "l"
    self.state = "idle"
    self.animations = {}
    self.sprites = {}
    self.hitboxes = {}
    self.hurtboxes = {}

    self.hp = 30
    self.score = 400
    self.damage = 10

    self:setAnimation("idle", idleSprite, idleAnim)
    self:setAnimation("walk", walkSprite, walkAnim)
    self:setAnimation("run", runSprite, runAnim)
    self:setAnimation("hurt", hurtSprite, hurtAnim)
    self:setAnimation("die", deadSprite, deadAnim)
    self:setAnimation("charge", chargeSprite, chargeAnim)
    self:setAnimation("attack1", attack1Sprite, attack1Anim)
    self:setAnimation("attack2", attack2Sprite, attack2Anim)

    self:setHurtbox("idle", 32, 32, 64, 64)
    self:setHurtbox("walk", 32, 32, 64, 64)
    self:setHurtbox("run", 32, 32, 64, 64)
    self:setHurtbox("hurt", 28, 28, 72, 72)
    self:setHurtbox("charge", 32, 32, 64, 64)
    self:setHurtbox("attack1", 32, 32, 64, 64)
    self:setHurtbox("attack2", 32, 32, 64, 64)

    self:setHitbox("attack1", 70, 30, 40, 60)
    self:setHitbox("attack2", 70, 30, 40, 60)

    self.visionRange = 250
    self.stateTimer = 0
    self.nextStateTime = math.random(2,5)
    self.attackCooldown = 0
end

function Wizard:changeState()
    local choices = {"idle", "walk", "run"}
    self.state = choices[math.random(#choices)]
end

function Wizard:update(dt, dungeon, player)
    -- Attack cooldown update
    if self.attackCooldown > 0 then
        self.attackCooldown = self.attackCooldown - dt
    end

    -- Check for player
    local dx = player.x - self.x
    local dy = player.y - self.y
    if math.abs(dx) + math.abs(dy) < self.visionRange then
        -- Close enough to attack
        if self.attackCooldown <= 0 then
            self.state = "charge"
            self.attackCooldown = 4 -- wait 4 seconds before attacking again
        else
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
        end
    else
        -- Wandering randomly
        self.stateTimer = self.stateTimer + dt
        if self.stateTimer >= self.nextStateTime then
            self:changeState()
            self.stateTimer = 0
            self.nextStateTime = math.random(2,5)
        end

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

function Wizard:hit(damage, direction)
    if self.invincible then return end

    self.invincible = true
    self.hp = self.hp - damage
    self.state = "hurt"
    Sounds["mob_hurt"]:play()

    if self.hp <= 0 then
        self.died = true
        self.state = "die"
    end

    Timer.after(0.5, function() self:endHit(direction) end)
    Timer.after(0.4, function() self.invincible = false end)
end

function Wizard:endHit(direction)
    if self.dir == direction then
        self:changeDirection()
    end
    self.state = "walk"
end

return Wizard
