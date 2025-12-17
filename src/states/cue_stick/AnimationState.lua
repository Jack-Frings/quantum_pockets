AnimationState = Class{__includes = BaseState} 

function AnimationState:init(cue_stick)
    self.cue_stick = cue_stick

    self.cue_ball = self.cue_stick.cue_ball
    print(self.cue_ball:get_position())
    self.magnitude = self.cue_stick.magnitude

    self.cocking_speed = 50
    self.hitting_speed = 400
end

function AnimationState:enter(params)
    self.target = params.target
    if self.magnitude < self.target then 
        self.direction = 1
    else 
        self.direction = -1
    end
end

function AnimationState:update(dt) 
    if self.direction == 1 then 
        self.magnitude = self.magnitude + self.cocking_speed*dt
    elseif self.direction == -1 then 
        self.magnitude = self.magnitude - self.hitting_speed*dt
    end

    if self.magnitude > self.target then 
        self.direction = -1 
    end

    if self.magnitude < 0 then 
        self.cue_ball.body:applyLinearImpulse(self:getForce(self.target, self.cue_stick.angle))
        self.cue_stick:changeState('hitting')
    end
end

function AnimationState:getForce(magnitude, angle)
    strength_factor = 2
    return -strength_factor*magnitude*math.cos(angle),  -strength_factor*magnitude*math.sin(angle)
end

function AnimationState:render()
    ball_x, ball_y = self.cue_ball:get_position()
    stick_x = ball_x + math.cos(self.cue_stick.angle) * self.magnitude
    stick_y = ball_y + math.sin(self.cue_stick.angle) * self.magnitude
    rot = math.atan2(ball_y - stick_y, ball_x - stick_x)

    love.graphics.push()
    love.graphics.translate(stick_x, stick_y)
    love.graphics.rotate(rot) 
    
    total_length = 0 

    section_length = 0.3*self.cue_stick.length
    love.graphics.setColor(100/255, 40/255, 50/255)
    love.graphics.rectangle('fill', -self.cue_stick.length, -self.cue_stick.width/2, section_length, self.cue_stick.width)
    total_length = total_length + section_length

    section_length = 0.6*self.cue_stick.length
    love.graphics.setColor(230/255, 150/255, 95/255)
    love.graphics.rectangle('fill', -self.cue_stick.length+total_length, -self.cue_stick.width/2, section_length, self.cue_stick.width)
    total_length = total_length + section_length

    section_length=0.1*self.cue_stick.length
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', -self.cue_stick.length+total_length, -self.cue_stick.width/2, section_length, self.cue_stick.width)

    love.graphics.pop()
end
