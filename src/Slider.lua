Slider = Class{} 

function Slider:init(max)
    self.max = max 
    self.cur = 0
    self.final = nil

    self.width = 300 
    self.height = 60

    self.slide_x = 0
    self.slide_width = 10
    self.slide_direction = 1

    self.speed = 600

    self.region_left = VIRTUAL_WIDTH/2 - self.width/2 
    self.region_top = VIRTUAL_HEIGHT/2 - self.height/2

    -- Shader for red-green-red gradient
    self.shader = love.graphics.newShader([[
        extern float rectLeft;
        extern float rectWidth;

        vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 screenCoord)
        {
            float t = (screenCoord.x - rectLeft) / rectWidth;

            float dist = abs(t - 0.5) * 2.0;

            float r = dist;
            float g = 1.0 - dist;
            float b = 0.0;

            return vec4(r, g, b, 0.6);
        }
    ]])
end

function Slider:update(dt)
    self.slide_x = self.slide_x + self.speed*self.slide_direction*dt

    if self.slide_x - self.slide_width < 0 then
        self.slide_direction = 1
    elseif self.slide_x > self.width - self.slide_width then 
        self.slide_direction = -1    
    end
end

function Slider:render()
    self.shader:send("rectLeft", self.region_left)
    self.shader:send("rectWidth", self.width)

    love.graphics.setShader(self.shader)
    love.graphics.rectangle('fill', self.region_left, self.region_top, self.width, self.height)
    love.graphics.setShader()

    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.rectangle('fill', self.region_left + self.slide_x, self.region_top, self.slide_width, self.height)
end

function Slider:getStrength()
    player = self.slide_x + self.slide_width/2 
    mid = self.width/2
    return (145 - math.abs(player - mid))
end
