Level = Class{} 

function Level:init() 
    self.world = love.physics.newWorld(0, 0)

    self.background = Background()

    self.cue_ball = CueBall(self.world, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 'cue_ball')
    self.cue_stick = CueStick(self.cue_ball)

    self.walls = {}

    -- Generate hitboxes for table frame
    width = 250 
    height = 20 
    for _, x in ipairs({50, 340}) do 
        for _, y in ipairs({10, VIRTUAL_HEIGHT - 30}) do 
            body = love.physics.newBody(self.world, x + width/2, y + height/2, 'static') 
            shape = love.physics.newRectangleShape(width, height) 

            fixture = love.physics.newFixture(body, shape) 
            fixture:setRestitution(0.8)

            table.insert(self.walls, fixture) 
        end
    end

    y = 50
    width = 20 
    height = 260     
    for _, x in ipairs({10, VIRTUAL_WIDTH - 30}) do 
        body = love.physics.newBody(self.world, x + width/2, y + height/2, 'static') 
        shape = love.physics.newRectangleShape(width, height) 

        fixture = love.physics.newFixture(body, shape)
        fixture:setRestitution(1)
        table.insert(self.walls, fixture)
    end
end

function Level:update(dt)
    self.cue_stick:update(dt)
    self.world:update(dt)
end

function Level:render()
    self.background:render()
    self.cue_ball:render()

    love.graphics.setColor(1, 0, 0)

    self.cue_stick:render()

    -- Render Hitboxes
    -- for _, wall in ipairs(self.walls) do 
    --     love.graphics.polygon("fill", wall:getBody():getWorldPoints(wall:getShape():getPoints()))
    -- end
end
