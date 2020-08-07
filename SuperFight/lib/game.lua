local class = require 'lib/middleclass'
local stateful = require 'lib/stateful'

Game = class('Game')
Game:include(stateful)

function Game:initialize(state)
    self:gotoState(state)
end

Menu = Game:addState('Menu')
--Countdown = Game:addState('Countdown')
Play = Game:addState('Play')
GameOver = Game:addState('GameOver')


-- Menu

function Menu:enteredState()
    --music.menu:play()
end

function Menu:update(dt)
    -- start the game when the player presses space
    if love.keyboard.isDown('space', 'return') then
        self:gotoState('Play')
        return
    end
end

function Menu:draw()
    -- draw background
    --love.graphics.setColor(40, 40, 50)
    --love.graphics.rectangle('fill', 0, 0, nativeCanvasWidth, nativeCanvasHeight)

    -- draw title
    love.graphics.setFont(blackMoon)
    love.graphics.setColor(20/255, 20/255, 25/255)
    love.graphics.printf('Z0MBIE', 0, WINDOW_HEIGHT/2 - 145, WINDOW_WIDTH + 5, 'center')
    love.graphics.setColor(255/255, 255/255, 255/255)
    love.graphics.printf('Z0MBIE', 0, WINDOW_HEIGHT/2 - 140, WINDOW_WIDTH, 'center')

    -- press enter to play
    if math.cos(2*math.pi*love.timer.getTime()) > 0 then
        love.graphics.setFont(smallMoon)
        love.graphics.setColor(20/255, 20/255, 25/255)
        love.graphics.printf('press ENTER to play', 0, WINDOW_HEIGHT/2 - 12 + 5, WINDOW_WIDTH + 5, 'center')
        love.graphics.setColor(255/255, 255/255, 255/255)
        love.graphics.printf('press ENTER to play', 0, WINDOW_HEIGHT/2 - 12, WINDOW_WIDTH, 'center')
    end
end

function Menu:exitedState()
    --music.menu:stop()
end

-- Play

function Play:enteredState()
    --music.main:play()
    --self.playTime = love.timer.getTime()
    love.graphics.setColor(255/255, 255/255, 255/255)
    love.graphics.rectangle('fill', 200, WINDOW_HEIGHT/3, WINDOW_WIDTH - 400, 10)
    platform = world:newRectangleCollider(200, WINDOW_HEIGHT/3, WINDOW_WIDTH - 400, 10)
    platform:setType('static')
    platform:setCollisionClass('Map')
    --platform:setObject(platform)

    self.player = Player:new(300, 200)
end

function Play:update(dt)

    self.player:update(dt)
    
    if love.keyboard.isDown('escape') then
        self:gotoState('Menu')
    end

    if self.player.alive == false then
        self:gotoState('GameOver')
    end
end

function Play:draw()
    -- draw ground
    --love.graphics.clear(1,1,1)

    love.graphics.setColor(1, 1, 1)

    self.player:draw()
end

function Play:exitedState()
    --music.main:stop()
end


-- GameOver

function GameOver:enteredState()
    --self.gameOverTime = love.timer.getTime()
end

function GameOver:update(dt)

    if love.keyboard.isDown('escape') then
        self:gotoState('Menu')
    end
end

function GameOver:draw()
    -- draw ground
    love.graphics.setColor(255/255, 255/255, 255/255)
    love.graphics.clear (0, 0, 0)


    ---- overlay
    --local alpha = 0
    --local t = love.timer.getTime() - self.gameOverTime
    --if t > 1 then
    --    if t < 3 then
    --       alpha = 200 * (t-1)/(3-1)
    --   else
    --        alpha = 200
    --    end
    --end

    ---- score
    --if t > 3 then
    --    love.graphics.setColor(255, 255, 255) 
    --end

    --if t > 10 then
    --    self:gotoState('Menu')
    --end
end

function GameOver:exitedState()
end