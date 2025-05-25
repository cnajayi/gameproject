local Globals = require "src.Globals"
local Push = require "libs.push"
local Sounds = require "src.game.Sounds"
local Player = require "src.game.Player"
local Dungeon = require "src.game.Dungeon"

local startBackground
local startFont

function love.load()
    love.window.setTitle("Heart of the Dungeon")
    Push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false, resizable = true})
    math.randomseed(os.time())

    gameState = "start"

    dungeon = Dungeon()
    dungeon:load()

    player = Player(100, 100)

    -- Load background image and start screen font
    startBackground = love.graphics.newImage("graphics/background/set.jpg")
    startFont = love.graphics.newFont("fonts/DragonHunter.otf", 20)
end

function love.resize(w, h)
    Push:resize(w, h)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "return" or key == "space" then
        if gameState == "start" then
            gameState = "play"
        elseif gameState == "over" then
            love.event.quit()
        end
    end
end

function love.update(dt)
    if gameState == "start" then
        -- Maybe animate start screen later
    elseif gameState == "play" then
        player:update(dt, dungeon)
        dungeon:update(dt, player)

        if player.hp <= 0 then
            gameState = "over"
        end
    elseif gameState == "over" then
        -- Game over logic
    end
end

function love.draw()
    Push:start()

    if gameState == "start" then
        drawStartScreen()
    elseif gameState == "play" then
        dungeon:draw()
        player:draw()
    elseif gameState == "over" then
        drawGameOverScreen()
    end

    Push:finish()
end

function drawStartScreen()
    -- Draw background
    local scaleX = gameWidth / startBackground:getWidth()
    local scaleY = gameHeight / startBackground:getHeight()
    love.graphics.draw(startBackground, 0, 0, 0, scaleX, scaleY)

    -- Draw title
    love.graphics.setFont(startFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Heart of the Dungeon", 0, 100, gameWidth, "center")

    -- Draw instruction
    love.graphics.setColor(1, 1, 0)
    love.graphics.printf("Press Enter to Start", 0, 250, gameWidth, "center")

    love.graphics.setColor(1, 1, 1) -- reset color
end

function drawGameOverScreen()
    love.graphics.setColor(1, 0, 0)
    love.graphics.printf("Game Over", 0, 100, gameWidth, "center")
    love.graphics.printf("Press Enter to Quit", 0, 180, gameWidth, "center")
end
