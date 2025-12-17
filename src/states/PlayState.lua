PlayState = Class{__includes = BaseState}

function PlayState:init() 
    self.level = Level() 
end

function PlayState:update(dt) 
    if love.keyboard.wasPressed('escape') then 
        love.event.quit() 
    end

    self.level:update(dt)
end


function PlayState:render() 
    self.level:render()
end
