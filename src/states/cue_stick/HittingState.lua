HittingState = Class{__includes = BaseState} 

function HittingState:init(cue_stick) 
    self.cue_stick = cue_stick
    self.cue_ball = self.cue_stick.cue_ball
    
    self.min_velocity = 2
end

function HittingState:update(dt) 
    vx, vy = self.cue_ball.body:getLinearVelocity()
    print(vx)
    print(vy)
    if math.abs(vx) < self.min_velocity and math.abs(vy) < self.min_velocity then
        self.cue_ball.body:setLinearVelocity(0, 0)
        self.cue_stick:changeState('waiting')
    end
end
