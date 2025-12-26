PlayState = Class{__includes = BaseState}

function PlayState:init() 
    -- Fundementals
    self.cur_level = 1
    self.cash = 0

    -- Upgradeable player atrributes
    self.start_time = 60
    self.spawn_interval = 5
    self.cue_ball_radius = 10 
    self.cue_stick_force_scalar = 2
    self.stops = 3
    self.cash_bonus = 1
    self.score_multiplier = 1

    self.costs = {3, 3, 3, 3, 3, 3, 3}
end

function PlayState:enter(params) 
    if params ~= nil then  
        self.cur_level = params.cur_level
        self.cash = params.cash
        self.start_time = params.start_time 
        self.spawn_interval = params.spawn_interval 
        self.cue_ball_radius = params.cue_ball_radius 
        self.cue_stick_force_scalar = params.cue_stick_force_scalar
        self.stops = params.stops 
        self.cash_bonus = params.cash_bonus
        self.score_multiplier = params.score_multiplier
        self.costs = params.costs
    end

    self.level = Level(self.cur_level, self.cash, self.start_time, self.spawn_interval, self.cue_ball_radius, 
                       self.cue_stick_force_scalar, self.stops, self.cash_bonus, self.score_multiplier)
end

function PlayState:update(dt) 
    if love.keyboard.wasPressed('escape') then 
        love.event.quit() 
    end

    self.level:update(dt)

    if self.level.timer < 0 then 
        if self.level.balls_pocketed < self.level.balls_needed then
            gStateMachine:change('start', {msg="Game Over"})
        else 
            self.cash = self.level.cash
            gStateMachine:change('shop', {cur_level=self.cur_level, cash=self.cash, start_time=self.start_time, 
                                          spawn_interval=self.spawn_interval, cue_ball_radius=self.cue_ball_radius, 
                                          cue_stick_force_scalar=self.cue_stick_force_scalar, stops=self.stops, 
                                          cash_bonus=self.cash_bonus, score_multiplier=self.score_multiplier, costs=self.costs})
        end
    end
end


function PlayState:render() 
    self.level:render()
end
