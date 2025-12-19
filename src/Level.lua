Level = Class{} 

function Level:init() 
    self.world = love.physics.newWorld(0, 0)
    self.world:setCallbacks(beginContact, nil, nil, nil)

    self.dist_from_walls = 40
    self.radius = 25
    self.background = Background(self.dist_from_walls)

    -- Params: world, x, y, r, g, b, bodyType, userData
    self.cue_ball = Ball(self.world, VIRTUAL_WIDTH / 4, VIRTUAL_HEIGHT / 2, 1, 1, 1, 'dynamic', 'cue_ball')

    self.cue_stick = CueStick(self.cue_ball)

    self.walls = {}
    self.holes = {}

    -- Generate hitboxes for table frame (spent too much time removing magic numbers from this)
    width = (VIRTUAL_WIDTH - 2*self.dist_from_walls - 4*self.radius) / 2
    height = self.dist_from_walls
    for _, x in ipairs({self.radius+self.dist_from_walls, VIRTUAL_WIDTH-width-self.radius-self.dist_from_walls}) do 
        for _, y in ipairs({0, VIRTUAL_HEIGHT - self.dist_from_walls}) do 
            body = love.physics.newBody(self.world, x + width/2, y + height/2, 'static') 
            shape = love.physics.newRectangleShape(width, height) 

            fixture = love.physics.newFixture(body, shape) 
            fixture:setRestitution(0.8)

            table.insert(self.walls, fixture) 
        end
    end

    y = self.dist_from_walls+self.radius
    width = self.dist_from_walls
    height = VIRTUAL_HEIGHT - 2*self.dist_from_walls - 2*self.radius
    for _, x in ipairs({0, VIRTUAL_WIDTH - self.dist_from_walls}) do 
        body = love.physics.newBody(self.world, x + width/2, y + height/2, 'static') 
        shape = love.physics.newRectangleShape(width, height) 

        fixture = love.physics.newFixture(body, shape)
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

    table.insert(self.balls, Ball(self.world, self.dist_from_walls, VIRTUAL_HEIGHT-self.dist_from_walls-self.radius, 1, 0, 0, 'dynamic', 'ball'))
    table.insert(self.balls, Ball(self.world, self.dist_from_walls, self.dist_from_walls+self.radius+1, 1, 0, 0, 'dynamic', 'ball'))
    table.insert(self.balls, Ball(self.world, VIRTUAL_WIDTH-self.dist_from_walls, self.dist_from_walls+self.radius+1, 1, 0, 0, 'dynamic', 'ball'))
end

function beginContact(a, b, coll)
    a_type = a:getUserData()
    b_type = b:getUserData()

    if (a_type == 'cue_ball' or a_type == 'ball') and (b_type == 'cue_ball' or b_type == 'ball') then 
        gSounds['ball']:play()
    end
end

function Level:createBallRack()
    rack_x = VIRTUAL_WIDTH * 0.7
    rack_y = VIRTUAL_HEIGHT / 2
    spacing = 25
    
    -- Red, Blue, and 8 Balls
    local ball_arrangement = {
        {'R'},
        {'B', 'R'},
        {'R', '8', 'B'},
        {'B', 'R', 'B', 'R'},
        {'R', 'B', 'R', 'B', 'R'}
    }
    
    for row_index, row in ipairs(ball_arrangement) do
        balls_in_row = #row
        row_x = rack_x + (row_index - 1) * spacing * 0.866 -- constant tuned to make it look like a triangle
        
        for col_index, ball_type in ipairs(row) do
            offset_y = (col_index - 1) * spacing - (balls_in_row - 1) * spacing / 2
            ball_y = rack_y + offset_y
            
            if ball_type == 'R' then
                r, g, b = 0.9, 0.1, 0.1
            elseif ball_type == 'B' then
                r, g, b = 0.1, 0.3, 0.9 
            else
                r, g, b = 0, 0, 0
            end
            
            local ball = Ball(self.world, row_x, ball_y, r, g, b, 'dynamic', ball_type)

            table.insert(self.balls, ball)
        end
    end
end

function Level:update(dt)
    self.cue_stick:update(dt)
    self.world:update(dt)
    
    -- Update ball animation
    self.cue_ball:update(dt)

    for i, ball in ipairs(self.balls) do 
        if ball.dead then 
            table.remove(self.balls, i)    
        else
            ball:update(dt)
        end
    end
    
    -- Only check for holes if ball isn't already falling
    if not self.cue_ball:isFalling() then
        ball_x, ball_y = self.cue_ball:getPosition()

        for _, pos in ipairs(self.holes) do 
            hole_x = pos[1]
            hole_y = pos[2]

            dx = ball_x - hole_x
            dy = ball_y - hole_y
            dist = math.sqrt(dx^2 + dy^2)
          
            if dist < self.radius then 
                -- Start the falling animation instead of instant reset
                self.cue_ball:startFalling(hole_x, hole_y)
                break
            end
        end
    end

    for _, ball in ipairs(self.balls) do 
        ball_x, ball_y = ball:getPosition()
        for _, pos in ipairs(self.holes) do 
            hole_x = pos[1] 
            hole_y = pos[2] 

            dx = ball_x - hole_x 
            dy = ball_y - hole_y 
            dist = math.sqrt(dx^2 + dy^2)

            if dist < self.radius then 
                ball:startFalling(hole_x, hole_y)
            end
        end
    end
end

function Level:render()
    self.background:render()

    love.graphics.setColor(0, 0, 0)
    for _, pos in ipairs(self.holes) do 
        x = pos[1]
        y = pos[2]
        love.graphics.circle('fill', x, y, self.radius)
    end


    self.cue_ball:render()

    for _, ball in ipairs(self.balls) do 
        ball:render()
    end
    self.cue_stick:render()

    -- Render Hitboxes
    -- love.graphics.setColor(1, 0, 0)
    -- for _, wall in ipairs(self.walls) do 
    --     love.graphics.polygon("fill", wall:getBody():getWorldPoints(wall:getShape():getPoints()))
    -- end
end
