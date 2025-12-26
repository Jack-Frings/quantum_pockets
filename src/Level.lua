Level = Class{} 

function Level:init(round, cash, timer, spawn_interval, cue_ball_radius, force_scalar, stops, cash_bonus, score_multiplier)
    self.world = love.physics.newWorld(0, 0)
    self.world:setCallbacks(beginContact, nil, nil, nil)

    -- Constants (negligible difference from upgrades but wtv) 
    self.round = round
    self.balls_pocketed = 0 
    self.balls_needed = self.round ^ 2
    self.cash = cash

    -- Upgradeable attributes variables (not including self.cue_stick.stops)
    self.timer = timer 
    self.cue_ball_radius = cue_ball_radius 
    self.cash_bonus = cash_bonus
    self.score_multiplier = score_multiplier
   
    -- Rendering background
    self.dist_from_walls = 40
    self.radius = 30
    self.background = Background(self.dist_from_walls)

    -- Spawner (Every spawn_interval seconds, spawn a new ball to hit)
    self.spawner = spawn_interval
    self.spawn_interval = spawn_interval

    -- Params: world, x, y, radius, r, g, b, bodyType, userData
    self.cue_ball = Ball(self.world, VIRTUAL_WIDTH / 4, VIRTUAL_HEIGHT / 2, self.cue_ball_radius, 1, 1, 1, 'dynamic', 'cue_ball')
    self.cue_stick = CueStick(self.cue_ball, stops, force_scalar)

    -- Collision tables
    self.walls = {}
    self.holes = {}

    -- Generate hitboxes for table frame (spent too much time removing magic numbers from this)
    local width = (VIRTUAL_WIDTH - 2*self.dist_from_walls - 4*self.radius) / 2
    local height = self.dist_from_walls
    for _, x in ipairs({self.radius+self.dist_from_walls, VIRTUAL_WIDTH-width-self.radius-self.dist_from_walls}) do 
        for _, y in ipairs({0, VIRTUAL_HEIGHT - self.dist_from_walls}) do 
            local body = love.physics.newBody(self.world, x + width/2, y + height/2, 'static') 
            local shape = love.physics.newRectangleShape(width, height) 

            local fixture = love.physics.newFixture(body, shape) 
            fixture:setRestitution(0.8)

            table.insert(self.walls, fixture) 
        end
    end

    local y = self.dist_from_walls+self.radius
    local width = self.dist_from_walls
    local height = VIRTUAL_HEIGHT - 2*self.dist_from_walls - 2*self.radius
    for _, x in ipairs({0, VIRTUAL_WIDTH - self.dist_from_walls}) do 
        local body = love.physics.newBody(self.world, x + width/2, y + height/2, 'static') 
        local shape = love.physics.newRectangleShape(width, height) 

        local fixture = love.physics.newFixture(body, shape)
        fixture:setRestitution(0.8)
        table.insert(self.walls, fixture)
    end

    -- Holes
    table.insert(self.holes, {self.dist_from_walls, self.dist_from_walls})
    table.insert(self.holes, {self.dist_from_walls, VIRTUAL_HEIGHT - self.dist_from_walls})
    table.insert(self.holes, {VIRTUAL_WIDTH - self.dist_from_walls, self.dist_from_walls})
    table.insert(self.holes, {VIRTUAL_WIDTH - self.dist_from_walls, VIRTUAL_HEIGHT - self.dist_from_walls})
    table.insert(self.holes, {VIRTUAL_WIDTH / 2, self.radius})
    table.insert(self.holes, {VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT - self.radius})

    -- Balls
    self.balls = {}
end

-- Function to play a sound when balls collide
function beginContact(a, b, coll)
    local a_type = a:getUserData()
    local b_type = b:getUserData()

    if (a_type == 'cue_ball' or a_type == 'ball') and (b_type == 'cue_ball' or b_type == 'ball') then 
        gSounds['ball']:play()
    end
end

function Level:update(dt)
    self.timer = self.timer - dt 

    self.cue_stick:update(dt)
    self.world:update(dt)
    
    self.cue_ball:update(dt)

    -- Spawn a new ball if the time frame is ready
    self.spawner = self.spawner + dt 
    if self.spawner > self.spawn_interval then 
        self.spawner = 0 
        local r, g, b = self:getRandomColor()
        local x, y = self:getRandomPosition()
        local ball = Ball(self.world, x, y, 10, r, g, b, 'dynamic', 'ball')
        table.insert(self.balls, ball)
    end

    -- Remove balls that have been pocketed
    for i, ball in ipairs(self.balls) do 
        if ball.dead then 
            self.balls_pocketed = self.balls_pocketed + self.score_multiplier
            self.cash = self.cash + self.cash_bonus
            table.remove(self.balls, i)    
        else
            ball:update(dt)
        end
    end
    
    -- Only check for holes if ball isn't already falling
    if not self.cue_ball:isFalling() then
        local ball_x, ball_y = self.cue_ball:getPosition()

        for _, pos in ipairs(self.holes) do 
            local hole_x = pos[1]
            local hole_y = pos[2]

            local dx = ball_x - hole_x
            local dy = ball_y - hole_y
            local dist = math.sqrt(dx^2 + dy^2)
          
            if dist < self.radius then 
                -- Start the falling animation instead of instant reset
                self.cue_ball:startFalling(hole_x, hole_y)
                break
            end
        end
    end

    -- Start ball falling animation when the ball enters a pocket
    for _, ball in ipairs(self.balls) do 
        local ball_x, ball_y = ball:getPosition()
        for _, pos in ipairs(self.holes) do 
            local hole_x = pos[1] 
            local hole_y = pos[2] 

            local dx = ball_x - hole_x 
            local dy = ball_y - hole_y 
            local dist = math.sqrt(dx^2 + dy^2)

            if dist < self.radius then 
                ball:startFalling(hole_x, hole_y)
            end
        end
    end
end

function Level:getRandomColor() 
    if math.random(0, 1) == 0 then 
        return 1, 0, 0 
    end

    return 0, 0, 1
end

function Level:getRandomPosition()
    local x = math.random(self.dist_from_walls, VIRTUAL_WIDTH-self.dist_from_walls)
    local y = math.random(self.dist_from_walls+self.radius+1, VIRTUAL_HEIGHT-self.dist_from_walls-self.radius)
    return x, y
end

function Level:getRandomVelocity()
    local x = math.random(100, 400) * (math.random(0, 1) * 2 - 1)
    local y = math.random(100, 400) * (math.random(0, 1) * 2 - 1)
    return x, y
end

-- Displays the time that the player has left to finish the current round
function Level:displayHUD() 
    -- Quick time calculations
    local int_time = math.floor(self.timer + 0.5)
    local min = tostring(math.floor(self.timer / 60))

    local sec = int_time % 60 
    if sec < 10 then 
        sec = "0" .. sec
    end

    local time = min .. ":" .. sec 

    -- Display important info
    love.graphics.setFont(gFonts['medium']) 
    love.graphics.setColor(1, 1, 1)

    love.graphics.printf("Round: " .. self.round, 3*self.radius, 0, VIRTUAL_WIDTH, 'left')
    love.graphics.printf(time, -7*self.radius, VIRTUAL_HEIGHT - self.dist_from_walls, VIRTUAL_WIDTH, 'right')
    love.graphics.printf(self.balls_pocketed .. "/" .. self.balls_needed, -3*self.radius, 0, VIRTUAL_WIDTH, 'right')
    love.graphics.printf("Stops: " .. self.cue_stick.stops, 3*self.radius, VIRTUAL_HEIGHT - self.dist_from_walls, VIRTUAL_WIDTH, 'left')
    love.graphics.printf("$" .. self.cash, -3*self.radius, VIRTUAL_HEIGHT - self.dist_from_walls, VIRTUAL_WIDTH, 'right')
end

function Level:render()
    self.background:render()

    love.graphics.setColor(0, 0, 0)
    for _, pos in ipairs(self.holes) do 
        local x = pos[1]
        local y = pos[2]
        love.graphics.circle('fill', x, y, self.radius)
    end


    self.cue_ball:render()

    for _, ball in ipairs(self.balls) do 
        ball:render()
    end

    self.cue_stick:render()

    self:displayHUD()

    -- Render Hitboxes
    -- love.graphics.setColor(1, 0, 0)
    -- for _, wall in ipairs(self.walls) do 
    --     love.graphics.polygon("fill", wall:getBody():getWorldPoints(wall:getShape():getPoints()))
    -- end
end
