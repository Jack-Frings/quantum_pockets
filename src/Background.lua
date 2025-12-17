Background = Class{}

function Background:init()
    -- blue, green, red backgrounds 
    self.colors = {{40/255, 110/255, 160/255}, {25/255, 110/255, 35/255}, {150/255, 0/255, 0/255}}

    -- shader to create background for pool table
    self.shader = love.graphics.newShader([[
        extern vec2 size;

        vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 screenCoord)
        {
            // screenCoord is in pixels
            vec2 centered = screenCoord / size;
            centered = centered * 2.0 - 1.0;

            // Correct aspect ratio
            centered.x *= size.x / size.y;

            float dist = length(centered);

            float t = smoothstep(1.0, 0.0, dist);

            float minBrightness = 0.85;
            float intensity = mix(minBrightness, 1.0, t);

            return vec4(color.rgb * intensity, color.a);
        }
    ]])
    self.shader:send('size', {VIRTUAL_WIDTH, VIRTUAL_HEIGHT})

    --- Choose a random color background between blue, green, and red
    self.r, self.g, self.b = self.colors[1]
end

function Background:update(dt)
end

function Background:render()
    -- First Background 
    love.graphics.setShader(self.shader)
    love.graphics.setColor(self.r, self.g, self.b)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    love.graphics.setShader()

    dist_from_walls = 30
    radius = 20

    -- Frame 
    frame_r = 60/255 
    frame_g = 60/255 
    frame_b = 60/255

    love.graphics.setColor(frame_r, frame_g, frame_b)
    love.graphics.rectangle('fill', 0, 0, dist_from_walls, VIRTUAL_HEIGHT)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, dist_from_walls)
    love.graphics.rectangle('fill', 0, VIRTUAL_HEIGHT - dist_from_walls, VIRTUAL_WIDTH, dist_from_walls)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH - dist_from_walls, 0, dist_from_walls, VIRTUAL_HEIGHT)


    -- Holes
    love.graphics.setColor(0, 0, 0)
    for _, x in ipairs({dist_from_walls, VIRTUAL_WIDTH - dist_from_walls}) do 
        for _, y in ipairs({dist_from_walls, VIRTUAL_HEIGHT - dist_from_walls}) do 
            love.graphics.circle('fill', x, y, radius)
        end
    end
    love.graphics.circle('fill', VIRTUAL_WIDTH / 2, radius, radius)
    love.graphics.circle('fill', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT-radius, radius)
end
