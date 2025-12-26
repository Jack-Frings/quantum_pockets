CueStick = Class{} 

function CueStick:init(cue_ball, stops, force_scalar)
    self.cue_ball = cue_ball 

    self.width = 8
    self.length = 120

    self.angle = math.pi
    self.magnitude = 20

    self.stops = stops
    self.force_scalar = force_scalar

    self.stateMachine = StateMachine {
        ['waiting'] = function() return WaitingState(self) end,
        ['powering'] = function() return PoweringState(self) end, 
        ['hitting'] = function() return HittingState(self) end,
        ['moving'] = function() return MovingState(self) end
    }
    self.stateMachine:change('waiting')
end

function CueStick:changeState(state, params)
    self.stateMachine:change(state, params)
end

function CueStick:update(dt)
    self.stateMachine:update(dt)
end

function CueStick:render() 
    self.stateMachine:render()
end


