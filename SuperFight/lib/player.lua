local class = require 'lib/middleclass'
--windfield = require 'windfield'

Player = class('Player')

-- applies positive Y influence on anything affected
local GRAVITY = 1

local WALKING_SPEED = 140
local JUMP_VELOCITY = 200
local DROP_VELOCITY = 200

function Player:initialize(x, y)

    --initial position
    self.x = x
    self.y = y

    -- number of times player has jumped in sequence
    self.jumpCount = 0

    self.height = 20
    self.width = 16

    self.jumpVelocity = 1

    -- offset from top left to center to support sprite flipping
    self.xOffset = self.width/2
    self.yOffset = self.height/2

    self.health = 300
    self.resistance = 0

    self.alive = true

    self.texture = love.graphics.newImage('blue_alien.png')

    -- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'idle'

    -- determines sprite flipping
    self.direction = 'left'

    --x and y velocity
    self.dx = 0
    self.dy = 0

    --Physics Collider
    self.collider = world:newRectangleCollider(self.x, self.y, 16, 20)
    self.collider:setCollisionClass('Player')
    self.collider:setObject(self)

    -- initialize all player animations
    self.animations = {
        ['idle'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0, 0, 16, 20, self.texture:getDimensions())
            }
        }),
        ['walking'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(128, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(144, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(160, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(144, 0, 16, 20, self.texture:getDimensions()),
            },
            interval = 0.15
        }),
        ['jumping'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(32, 0, 16, 20, self.texture:getDimensions())
            }
        }),
        ['falling'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(80, 0, 16, 20, self.texture:getDimensions())
            }
        }),

        ['dropping'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(48, 0, 16, 20, self.texture:getDimensions())
            }
        })
    }

    -- initialize animation and current frame we should render
    self.animation = self.animations['idle']
    self.currentFrame = self.animation:getCurrentFrame()

    -- behavior map we can call based on player state
    self.behaviors = {
        ['idle'] = function(dt)
            
            -- add spacebar functionality to trigger jump state
            if love.keyboard.wasPressed('up') then

                self.dy = -JUMP_VELOCITY
                self.jumpCount = self.jumpCount + 1
                self.state = 'jumping'
                self.animation = self.animations['jumping']
                --self.sounds['jump']:play()

            elseif love.keyboard.wasPressed('down') then

                self.dy = DROP_VELOCITY
                self.state = 'dropping'
                self.animation = self.animations['dropping']
                --self.sounds['jump']:play()

            elseif love.keyboard.isDown('left') then

                self.direction = 'left'
                self.dx = -WALKING_SPEED
                self.state = 'walking'
                self.animations['walking']:restart()

            elseif love.keyboard.isDown('right') then

                self.direction = 'right'
                self.dx = WALKING_SPEED
                self.state = 'walking'
                self.animations['walking']:restart()
            
            else 
                self.dx = 0

            end

            self.animation = self.animations['idle']

            
            --movement
            --self.collider:setLinearVelocity(self.vectorX * WALKING_SPEED, self.vectorY * JUMP_VELOCITY)
            
        end,

        ['walking'] = function(dt)
            
            self.animation = self.animations['walking']

            if love.keyboard.wasPressed('up') then

                self.dy = -JUMP_VELOCITY
                self.jumpCount = self.jumpCount + 1
                self.state = 'jumping'
                self.animation = self.animations['jumping']
                --self.sounds['jump']:play()

            elseif love.keyboard.wasPressed('down') then

                self.dy = DROP_VELOCITY
                self.state = 'dropping'
                self.animation = self.animations['dropping']
                --self.sounds['jump']:play()

            elseif love.keyboard.isDown('left') then

                self.dx = -WALKING_SPEED
                self.direction = 'left'

            elseif love.keyboard.isDown('right') then

                self.dx = WALKING_SPEED
                self.direction = 'right'

            else
                self.dx = 0
                self.state = 'idle'
                self.animation = self.animations['idle']

            end

            -- check if there's no tile directly beneath us
            --if not self.map:collides(self.map:tileAt(self.x, self.y + self.height)) and
            --    not self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
            --    
            --    -- if so, reset velocity and position and change state
            --    self.state = 'jumping'
            --    self.animation = self.animations['jumping']
            --end

        end,
    
        ['jumping'] = function(dt)

            if love.keyboard.wasPressed('down') then

                self.dy = DROP_VELOCITY
                self.state = 'dropping'
                self.animation = self.animations['dropping']
                --self.sounds['jump']:play()

            elseif love.keyboard.isDown('left') then

                self.dx = -WALKING_SPEED/2
                self.direction = 'left'

            elseif love.keyboard.isDown('right') then

                self.dx = WALKING_SPEED/2
                self.direction = 'right'
            
            --elseif love.keyboard.isDown('up') then
                --self.vectorY = -1

            --else
                --self.vectorX = 0
                --self.vectorY = 0
                --self.state = 'idle'
                --self.animation = self.animations['idle']

            end

            -- apply map's gravity before y velocity
            --if self.collider:stay('Map') then
            --    love.graphics.print("COLLISION", 100, 100)
            --    self.jumpCount = 0
            --    self.dy = 0--
            --self.state = idle
            --else    
            --   -- self.dy = self.dy + GRAVITY
            --end


        end,

        ['falling'] = function(dt)

            if love.keyboard.isDown('left') then
                self.dx = -WALKING_SPEED/2
                self.direction = 'left'

            elseif love.keyboard.isDown('right') then

                self.dx = WALKING_SPEED/2
                self.direction = 'right'

            elseif love.keyboard.wasPressed('down') then
                self.dy = DROP_VELOCITY

            --elseif love.keyboard.isDown('up') then
                --self.vectorY = -1
                ----self.collider:setLinearVelocity(0, -JUMP_VELOCITY)
                --self.state = 'jumping'
                --self.animation = self.animations['jumping']

            --else
            --    self.state = 'idle'
            --    self.animation = self.animations['idle']
            end

            -- apply map's gravity before y velocity
            

        end,

        ['dropping'] = function(dt)
            -- break if we go below the surface
            --if self.y > 300 then
            --    return
            --end

            if love.keyboard.isDown('left') then
                self.dx = -WALKING_SPEED/2
               -- self.collider:setLinearVelocity(-WALKING_SPEED, 0)
                self.direction = 'left'

            elseif love.keyboard.isDown('right') then
                self.dx = WALKING_SPEED/2
                self.direction = 'right'

            --elseif love.keyboard.wasPressed('up') then
                --self.vectorY = 1
                --self.state = 'jumping'

            --elseif love.keyboard.isDown('up') then
                --self.vectorY = -1
                ----self.collider:setLinearVelocity(0, -JUMP_VELOCITY)
                --self.state = 'jumping'
                --self.animation = self.animations['jumping']

            --else
            --    self.vectorX = 0
            --    self.vectorY = 0
            --    self.state = 'idle'
            --    self.animation = self.animations['idle']
            end

            -- apply map's gravity before y velocity
            --if self.collider:stay('Map') then
            --    love.graphics.print('COLLISION', 100, 100)
            --    self.jumpCount = 0
            --    self.dy = 0
            --    self.state = idle
            --else    
            --    self.dy = self.dy + GRAVITY
            --end

        end
        
    }
end

function Player:update(dt)
    
    self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
    

    if self.y > 720 then
        self.alive = false
    end

    if self.collider:stay('platform') then
        love.graphics.printf('COLLISION', 100, 100, 20 ,'center')
        self.jumpCount = 0
        self.dy = 0
        self.state = 'idle'

    else    
        self.dy = self.dy + GRAVITY
        --self.y = self.y + self.dy * dt
    end


    self.x = self.x + self.dx * dt
    
    
    self.collider:setPosition(self.x, self.y)

end



function Player:draw()
    local scaleX

    -- set negative x scale factor if facing left, which will flip the sprite
    -- when applied
    if self.direction == 'right' then
        scaleX = 1
    else
        scaleX = -1
    end

    -- draw sprite with scale factor and offsets
    --love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + self.xOffset),
       -- math.floor(self.y + self.yOffset), 0, scaleX, 1, self.xOffset, self.yOffset)

    love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x),
        math.floor(self.y), 0, scaleX, 1, self.xOffset, self.yOffset)

    world:draw()
end
