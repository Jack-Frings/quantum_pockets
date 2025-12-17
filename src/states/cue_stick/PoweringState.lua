PoweringState = Class{__includes = BaseState} 

function PoweringState:init(cue_stick) 
    self.cue_stick = cue_stick
    self.cue_ball = self.cue_stick.cue_ball

    self.slider = Slider(self.cue_stick.magnitude)
end

function PoweringState:update(dt) 
    self.slider:update(dt)
    if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('space') then 
        socket.sleep(0.4)
        self.cue_stick:changeState('animation', {target=self.slider:getStrength()})
    end
end

function PoweringState:render()
    ball_x, ball_y = self.cue_ball:get_position()
    stick_x = ball_x + math.cos(self.cue_stick.angle) * self.cue_stick.magnitude 
    stick_y = ball_y + math.sin(self.cue_stick.angle) * self.cue_stick.magnitude  
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

    self.slider:render()
end
