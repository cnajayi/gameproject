local Class = require "libs.hump.class"
local Anim8 = require "libs.anim8"
local Tween = require "libs.tween"
local Hbox = require "src.game.Hbox"
local Sounds = require "src.game.Sounds"

local Player = Class{}

function Player:init(x,y)
    self.x = x
    self.y = y
    self.dir = "r" -- r = right, l = left
    self.speed = 0

    self.hp = 100
    self.state = "idle"

    self.name = "char"
    self.hitboxes = {}
    self.hurtboxes = {}
    
    self.animations = {}
    self.sprites = {}
    self:createAnimations()
end

local idleSprite = love.graphics.newImage("graphics/character/Idle.png")
local idleGrid = Anim8.newGrid(128, 128, idleSprite:getWidth(), idleSprite:getHeight())
local idleAnim = Anim8.newAnimation(idleGrid('1-4', 1), 0.2)

local walkSprite = love.graphics.newImage("graphics/character/Walk.png")
local walkGrid = Anim8.newGrid(128, 128, walkSprite:getWidth(), walkSprite:getHeight())
local walkAnim = Anim8.newAnimation(walkGrid('1-6', 1), 0.15)

local runSprite = love.graphics.newImage("graphics/character/Run.png")
local runGrid = Anim8.newGrid(128, 128, runSprite:getWidth(), runSprite:getHeight())
local runAnim = Anim8.newAnimation(runGrid('1-6', 1), 0.1)

local runAttackSprite = love.graphics.newImage("graphics/character/Run+Attack.png")
local runAttackGrid = Anim8.newGrid(128, 128, runAttackSprite:getWidth(), runAttackSprite:getHeight())
local runAttackAnim = Anim8.newAnimation(runAttackGrid('1-6', 1), 0.15)

local defendSprite = love.graphics.newImage("graphics/character/Defend.png")
local defendGrid = Anim8.newGrid(128, 128, defendSprite:getWidth(), defendSprite:getHeight())
local defendAnim = Anim8.newAnimation(defendGrid('1-4', 1), 0.2)

local deadSprite = love.graphics.newImage("graphics/character/Dead.png")
local deadGrid = Anim8.newGrid(128, 128, deadSprite:getWidth(), deadSprite:getHeight())
local deadAnim = Anim8.newAnimation(deadGrid('1-6', 1), 0.1)

local attackSprite = love.graphics.newImage("graphics/character/Attack 1.png")
local attackGrid = Anim8.newGrid(128, 128, attackSprite:getWidth(), attackSprite:getHeight())
local attackAnim = Anim8.newAnimation(attackGrid('1-4', 1), 0.15)

local hitSprite = love.graphics.newImage("graphics/character/Hurt.png")
local hitGrid = Anim8.newGrid(128, 128, hitSprite:getWidth(), hitSprite:getHeight())
local hitAnim = Anim8.newAnimation(hitGrid('1-2',1), 0.2)

function Player:createAnimations()
    self.animations["idle"] = idleAnim
    self.sprites["idle"] = idleSprite

    self.animations["walk"] = walkAnim
    self.sprites["walk"] = walkSprite

    self.animations["run"] = runAnim
    self.sprites["run"] = runSprite

    self.animations["attack"] = attackAnim
    self.animations["attack"].onLoop = function() self:finishAttack() end
    self.sprites["attack"] = attackSprite

    self.animations["runAttack"] = runAttackAnim
    self.animations["runAttack"].onLoop = function() self:finishAttack() end
    self.sprites["runAttack"] = runAttackSprite

    self.animations["defend"] = defendAnim
    self.animations["defend"].onLoop = function() self:finishDefend() end
    self.sprites["defend"] = defendSprite

    self.animations["hit"] = hitAnim
    self.animations["hit"].onLoop = function() self:finishHit() end
    self.sprites["hit"] = hitSprite

    self.animations["dead"] = deadAnim
    self.animations["dead"].onLoop = function() self:finishHit() end
    self.sprites["dead"] = deadSprite

    -- Ensure hurtboxes are initialized for all states
    self.hurtboxes["idle"] = Hbox(self,24,16,32,48)
    self.hurtboxes["walk"] = Hbox(self,24,16,32,48)
    self.hurtboxes["run"] = Hbox(self,24,16,32,48)
    self.hurtboxes["attack"] = Hbox(self,24,16,32,48)
    self.hitboxes["attack"] = Hbox(self, 60, 16, 34, 32)
    self.hurtboxes["runAttack"] = Hbox(self, 24, 16, 32, 48)
    self.hitboxes["runAttack"] = Hbox(self, 60, 16, 34, 32)
    self.hurtboxes["defend"] = Hbox(self, 24, 16, 32, 48)
end

-- Updated getHurtbox method to return a default value
function Player:getHurtbox()
    -- Ensure the hurtbox exists for the current state or fallback to "idle"
    if self.hurtboxes[self.state] then
        return self.hurtboxes[self.state]
    else
        return self.hurtboxes["idle"]  -- Default to idle if the current state doesn't have a hurtbox
    end
end

function Player:update(dt, dungeon)
    local dx, dy = 0, 0

    -- Move right
    if love.keyboard.isDown("d", "right") then
        self.dir = "r"  -- Set direction directly
        dx = 96 * dt
    -- Move left
    elseif love.keyboard.isDown("a", "left") then
        self.dir = "l"  -- Set direction directly
        dx = -96 * dt
    end

    -- Move up
    if love.keyboard.isDown("w", "up") then
        dy = -96 * dt
    -- Move down
    elseif love.keyboard.isDown("s", "down") then
        dy = 96 * dt
    end

    -- Move horizontally and check for wall collision
    local nextX = self.x + dx
    if not dungeon:checkWallCollision(self, nextX, self.y) then
        self.x = nextX
    end

    -- Move vertically and check for wall collision
    local nextY = self.y + dy
    if not dungeon:checkWallCollision(self, self.x, nextY) then
        self.y = nextY
    end

    -- Update state based on movement
    if dx ~= 0 or dy ~= 0 then
        if self.state ~= "attack" and self.state ~= "hurt" and self.state ~= "dead" then
            self.state = "run"
        end
    else
        if self.state ~= "attack" and self.state ~= "hurt" and self.state ~= "dead" then
            self.state = "idle"
        end
    end

    -- Update animations
    self.animations[self.state]:update(dt)
end


function Player:draw()
    local flip = (self.dir == "l")
    self.animations[self.state]:draw(
        self.sprites[self.state],
        math.floor(self.x), math.floor(self.y),
        0,
        flip and -1 or 1, 1,
        64, 64
    )

    if debugFlag then
        local w,h = self:getDimensions()
        love.graphics.rectangle("line",self.x-w/2,self.y-h/2,w,h) -- sprite boundary

        if self:getHurtbox() then
            love.graphics.setColor(0,0,1) -- blue
            self:getHurtbox():draw()
        end

        if self:getHitbox() then
            love.graphics.setColor(1,0,0) -- red
            self:getHitbox():draw()
        end
        love.graphics.setColor(1,1,1) 
    end
end

function Player:keypressed(key)
    if key == "f" then
        if love.keyboard.isDown("w","a","s","d","up","down","left","right") then
            self.state = "runAttack"
            self.animations["runAttack"]:gotoFrame(1)
            Sounds["attack"]:play()
        else
            self.state = "attack"
            self.animations["attack"]:gotoFrame(1)
            Sounds["attack"]:play()
        end
    elseif key == "g" then
        if self.state ~= "hurt" and self.state ~= "dead" then
            self.state = "defend"
            self.animations["defend"]:gotoFrame(1)
            Sounds["defend"]:play()
        end
    end
end

function Player:getDimensions()
    return self.animations[self.state]:getDimensions()
end

function Player:getHbox(boxtype)
    if boxtype == "hit" then
        return self.hitboxes[self.state]
    else
        return self.hurtboxes[self.state]
    end
end

function Player:getHitbox()
    return self:getHbox("hit")
end

function Player:getHurtbox()
    return self:getHbox("hurt")
end

function Player:deadd()
    self.state = "dead"
    self.hp = 0
    Sounds["dead"]:play()
end

function Player:finishHit()
    if self.state == "hurt" then
        self.state = "idle"
    end
end

return Player