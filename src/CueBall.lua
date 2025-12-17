CueBall = Class{} 

function CueBall:init(world, x, y, userData) 
    self.world = world 

    self.body = love.physics.newBody(self.world, x, y, 'dynamic') 
    self.body:setLinearDamping(0.8)

    self.shape = love.physics.newCircleShape(10)

    self.fixture = love.physics.newFixture(self.body, self.shape)

    self.fixture:setUserData(userData)
end

function CueBall:render() 
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle('fill', self.body:getX(), self.body:getY(), 10)
end

function CueBall:get_position() 
    return self.body:getX(), self.body:getY()
end
