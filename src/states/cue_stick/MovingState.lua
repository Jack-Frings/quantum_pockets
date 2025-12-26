MovingState = Class{__includes = BaseState} 

function MovingState:init(cue_stick) 
    self.cue_stick = cue_stick
    self.cue_ball = self.cue_stick.cue_ball
    
    self.min_velocity = 4
end

function MovingState:update(dt) 
    if love.keyboard.wasPressed('r') and self.cue_stick.stops > 0 then 
        self.cue_stick.stops = self.cue_stick.stops - 1 
        self.cue_ball.body:setLinearVelocity(0, 0)
        self.cue_stick:changeState('waiting')
    end

    local vx, vy = self.cue_ball.body:getLinearVelocity()
    if (math.abs(vx) < self.min_velocity and math.abs(vy) < self.min_velocity) then
        self.cue_ball.body:setLinearVelocity(0, 0)
        self.cue_stick:changeState('waiting')
    end
end
