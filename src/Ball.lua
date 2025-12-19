Ball = Class{} 

function Ball:init(world, x, y, r, g, b, bodyType, userData) 
    self.world = world 

    self.body = love.physics.newBody(self.world, x, y, bodyType) 
    self.body:setLinearDamping(0.4)
    self.body:setAngularDamping(0.1)

    self.r = r 
    self.g = g 
    self.b = b

    self.shape = love.physics.newCircleShape(10)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData(userData)

    self.fixture:setFriction(0.05)
    self.fixture:setRestitution(0.95)
    
    self.radius = 10
    self.falling = false
    self.fall_timer = 0
    self.fall_duration = 0.8
    self.target_hole_x = 0
    self.target_hole_y = 0
    self.start_x = 0
    self.start_y = 0

    self.dead = false
    self.respawn_timer = 4
end

function Ball:startFalling(hole_x, hole_y)
    if not self.falling then
        self.falling = true
        self.fall_timer = 0
        self.target_hole_x = hole_x
        self.target_hole_y = hole_y
        self.start_x = self.body:getX()
        self.start_y = self.body:getY()
        
        -- Disable physics interactions
        self.body:setLinearVelocity(0, 0)
        self.body:setActive(false)
    end
end

function Ball:update(dt)
    self.respawn_timer = self.respawn_timer + dt 

    if self.falling then
        self.fall_timer = self.fall_timer + dt
        progress = math.min(self.fall_timer / self.fall_duration, 1)
       
       
        -- This is a cubic function so that the ball eases into and out of the flaling animation. 
        eased = 1 - (1 - progress)^3
       
        -- Update x and y based on the hole's center
        current_x = self.start_x + (self.target_hole_x - self.start_x) * eased
        current_y = self.start_y + (self.target_hole_y - self.start_y) * eased
        self.body:setPosition(current_x, current_y)
       
        -- Shrink ball
        self.radius = 10 * (1 - progress * 0.95)
        
        if progress >= 1 then
            if self.fixture:getUserData() == 'cue_ball' then 
                self:resetBall()
                self.respawning = true 
            else 
                self.dead = true
            end
        end
    end
end

function Ball:resetBall()
    self.falling = false
    self.radius = 10
    self.body:setActive(true)
    self.body:setPosition(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2)
    self.body:setLinearVelocity(0, 0)
end

function Ball:render() 
function Ball:render() 
    if self.destroyed or self.respawn_timer < 3 then return end
    
    -- Draw outline (slightly larger circle in black)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle('fill', self.body:getX(), self.body:getY(), self.radius + 2)
    
    -- Draw main ball
    love.graphics.setColor(self.r, self.g, self.b)
    love.graphics.circle('fill', self.body:getX(), self.body:getY(), self.radius)
end
end

function Ball:getPosition() 
    return self.body:getX(), self.body:getY()
end

function Ball:isFalling()
    return self.falling
end
