StartState = Class{__includes = BaseState}

function StartState:init() 
    self.world = love.physics.newWorld(0, 0)

    self.dist_from_walls = 40
    self.radius = 25
    self.background = Background(self.dist_from_walls)

    self.timer = 0

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
end

function StartState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then 
        gStateMachine:change('play')
    end

    self.world:update(dt)

    for i, ball in ipairs(self.balls) do 
        if ball.dead then 
            table.remove(self.balls, i)    
        else
            ball:update(dt)
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

    self.timer = self.timer + dt 

    if #self.balls >= 50 then 
        for i, ball in ipairs(self.balls) do 
            ball.body:destroy()
            table.remove(self.balls, i)
        end
    end

    if self.timer > 1 then 
        self.timer = 0 
        r, g, b = self:randomColor()
        x, y = self:randomPosition()
        ball = Ball(self.world, x, y, r, g, b, 'dynamic', 'start_ball')
        
        x, y = self:getRandomVelocity()
        ball.body:setLinearVelocity(x, y)
        table.insert(self.balls, ball)
    end
end

function StartState:randomColor() 
    if math.random(0, 1) == 0 then 
        return 1, 0, 0 
    end

    return 0, 0, 1
end

function StartState:randomPosition()
    x = math.random(self.dist_from_walls, VIRTUAL_WIDTH-self.dist_from_walls)
    y = math.random(self.dist_from_walls+self.radius+1, VIRTUAL_HEIGHT-self.dist_from_walls-self.radius)
    return x, y
end

function StartState:getRandomVelocity()
    x = math.random(100, 400) * (math.random(0, 1) * 2 - 1)
    y = math.random(100, 400) * (math.random(0, 1) * 2 - 1)
    return x, y
end

function StartState:render()
    self.background:render()

    love.graphics.setColor(0, 0, 0)
    for _, pos in ipairs(self.holes) do 
        x = pos[1]
        y = pos[2]
        love.graphics.circle('fill', x, y, self.radius)
    end

    for _, ball in ipairs(self.balls) do 
        ball:render()
    end

    love.graphics.setColor(1, 1, 1) 
    love.graphics.setFont(gFonts['huge']) 
    love.graphics.printf('Deep Pockets', 0, VIRTUAL_HEIGHT / 2 - 40, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Press Enter', 0, VIRTUAL_HEIGHT / 2 + 16, VIRTUAL_WIDTH, 'center')

    -- Hitboxes
    -- love.graphics.setColor(1, 0, 0)
    -- for _, wall in ipairs(self.walls) do 
    --     love.graphics.polygon("fill", wall:getBody():getWorldPoints(wall:getShape():getPoints()))
    -- end
end
