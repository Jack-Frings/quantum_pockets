HittingState = Class{__includes = BaseState} 

function HittingState:init(cue_stick)
    self.cue_stick = cue_stick

    self.cue_ball = self.cue_stick.cue_ball
    self.magnitude = self.cue_stick.magnitude
end

function HittingState:enter(params)
    self.target = params.target
    if self.magnitude < self.target then 
        self.direction = 1
    else 
        self.direction = -1
    end

    self.cocking_speed = self.target
    self.hitting_speed = 8*self.target 
end

function HittingState:update(dt) 
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
        gSounds['cue_ball']:play()
        self.cue_stick:changeState('moving')
    end
end

function HittingState:getForce(magnitude, angle)
    local strength_factor = self.cue_stick.force_scalar
    return -strength_factor*magnitude*math.cos(angle),  -strength_factor*magnitude*math.sin(angle)
end

function HittingState:render()
    local ball_x, ball_y = self.cue_ball:getPosition()
    local stick_x = ball_x + math.cos(self.cue_stick.angle) * self.magnitude
    local stick_y = ball_y + math.sin(self.cue_stick.angle) * self.magnitude
    local rot = math.atan2(ball_y - stick_y, ball_x - stick_x)

    love.graphics.push()
    love.graphics.translate(stick_x, stick_y)
    love.graphics.rotate(rot) 
    
    local total_length = 0 

    local section_length = 0.3*self.cue_stick.length
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
