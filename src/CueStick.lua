CueStick = Class{} 

function CueStick:init(cue_ball) 
    self.cue_ball = cue_ball 

    self.width = 8
    self.length = 120

    self.angle = 0
    self.magnitude = 20

    self.stateMachine = StateMachine {
        ['waiting'] = function() return WaitingState(self) end,
        ['powering'] = function() return PoweringState(self) end, 
        ['animation'] = function() return AnimationState(self) end,
        ['hitting'] = function() return HittingState(self) end
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
