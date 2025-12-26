ShopState = Class{__includes = BaseState}

function ShopState:init() 
    self.dist_from_walls = 40
    self.radius = 30
    self.background = Background(self.dist_from_walls)

    -- Holes
    self.holes = {}
    table.insert(self.holes, {self.dist_from_walls, self.dist_from_walls})
    table.insert(self.holes, {self.dist_from_walls, VIRTUAL_HEIGHT - self.dist_from_walls})
    table.insert(self.holes, {VIRTUAL_WIDTH - self.dist_from_walls, self.dist_from_walls})
    table.insert(self.holes, {VIRTUAL_WIDTH - self.dist_from_walls, VIRTUAL_HEIGHT - self.dist_from_walls})
    table.insert(self.holes, {VIRTUAL_WIDTH / 2, self.radius})
    table.insert(self.holes, {VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT - self.radius})

    self.hovering = 1

    -- Upgrade descriptions
    self.upgrades = {
        "+30 seconds",
        "-1 second spawn",
        "+10 radius",
        "+1 force",
        "+1 stop",
        "+$1 per ball",
        "+1 score per ball",
        "Next Round"
    }
end

function ShopState:enter(params) 
    self.cur_level = params.cur_level + 1
    self.cash = params.cash + self.cur_level
    self.start_time = params.start_time 
    self.spawn_interval = params.spawn_interval 
    self.cue_ball_radius = params.cue_ball_radius 
    self.cue_stick_force_scalar = params.cue_stick_force_scalar
    self.stops = params.stops 
    self.cash_bonus = params.cash_bonus
    self.score_multiplier = params.score_multiplier
    self.costs = params.costs
end

function ShopState:update(dt) 
    if love.keyboard.wasPressed('escape') then 
        love.event.quit() 
    end
    
    if love.keyboard.wasPressed('right') then 
        self.hovering = self.hovering + 1 
        if self.hovering > 8 then 
            self.hovering = 1 
        end 
    elseif love.keyboard.wasPressed('left') then
        self.hovering = self.hovering - 1 
        if self.hovering < 1 then 
            self.hovering = 8 
        end
    elseif love.keyboard.wasPressed('down') then
        self.hovering = self.hovering + 4
        if self.hovering > 8 then
            self.hovering = self.hovering - 8
        end
    elseif love.keyboard.wasPressed('up') then
        self.hovering = self.hovering - 4
        if self.hovering < 1 then
            self.hovering = self.hovering + 8
        end
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then 
        if self.hovering == 8 then 
            gStateMachine:change('play', {cur_level=self.cur_level, cash=self.cash, start_time=self.start_time, spawn_interval=self.spawn_interval, 
                                          cue_ball_radius=self.cue_ball_radius, cue_stick_force_scalar=self.cue_stick_force_scalar, stops=self.stops,
                                          cash_bonus=self.cash_bonus, score_multiplier=self.score_multiplier, costs=self.costs})
        elseif self.cash >= self.costs[self.hovering] then
            if self.hovering == 1 then 
                self.cash = self.cash - self.costs[1]
                self.costs[1] = 3*self.costs[1]
                self.start_time = self.start_time + 30

            elseif self.hovering == 2 and self.spawn_interval > 1 then 
                self.cash = self.cash - self.costs[2]
                self.costs[2] = 3*self.costs[2]
                self.spawn_interval = self.spawn_interval - 1

            elseif self.hovering == 3 and self.cue_ball_radius < 50 then 
                self.cash = self.cash - self.costs[3]
                self.costs[3] = 3*self.costs[3]
                self.cue_ball_radius = self.cue_ball_radius + 10 

            elseif self.hovering == 4 and self.cue_stick_force_scalar < 5 then 
                self.cash = self.cash - self.costs[4]
                self.costs[4] = 3*self.costs[4]
                self.cue_stick_force_scalar = self.cue_stick_force_scalar + 1

            elseif self.hovering == 5 then 
                self.cash = self.cash - self.costs[5]
                self.costs[5] = 3*self.costs[5]
                self.stops = self.stops + 1

            elseif self.hovering == 6 then 
                self.cash = self.cash - self.costs[6]
                self.costs[6] = 3*self.costs[6]
                self.cash_bonus = self.cash_bonus + 1

            elseif self.hovering == 7 then 
                self.cash = self.cash - self.costs[7]
                self.costs[7] = 3*self.costs[7]
                self.score_multiplier = self.score_multiplier + 1
            end
        end
    end
end

function ShopState:canAfford(index)
    return self.cash >= self.costs[index]
end

function ShopState:isMaxed(index)
    if index == 2 then return self.spawn_interval <= 1 end
    if index == 3 then return self.cue_ball_radius >= 50 end
    if index == 4 then return self.cue_stick_force_scalar >= 5 end
    return false
end

function ShopState:render() 
    self.background:render()

    love.graphics.setColor(0, 0, 0)
    for _, pos in ipairs(self.holes) do 
        local x = pos[1]
        local y = pos[2]
        love.graphics.circle('fill', x, y, self.radius)
    end

    -- HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf("SHOP", 0, 50, VIRTUAL_WIDTH, 'center')

    love.graphics.printf("Round " .. self.cur_level .. "     Cash: $" .. self.cash, 0, 75, VIRTUAL_WIDTH, 'center')

    local playableWidth = VIRTUAL_WIDTH - (2 * self.dist_from_walls)
    local playableHeight = VIRTUAL_HEIGHT - 120 - self.dist_from_walls
    
    local cols = 4
    local rows = 2
    local spacing = 10
    
    local cardWidth = (playableWidth - (cols + 1) * spacing) / cols
    local cardHeight = (playableHeight - (rows + 1) * spacing) / rows
    
    local startX = self.dist_from_walls + spacing
    local startY = 110

    for i = 1, 8 do
        local col = (i - 1) % 4
        local row = math.floor((i - 1) / 4)
        local x = startX + col * (cardWidth + spacing)
        local y = startY + row * (cardHeight + spacing)

        -- background
        if self.hovering == i then
            love.graphics.setColor(1, 1, 1, 0.3)
        else
            love.graphics.setColor(0, 0, 0, 0.5)
        end
        love.graphics.rectangle('fill', x, y, cardWidth, cardHeight, 8, 8)

        -- highlight card we're currently on
        if self.hovering == i then
            love.graphics.setColor(1, 1, 0)
            love.graphics.setLineWidth(3)
        else
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.setLineWidth(2)
        end
        love.graphics.rectangle('line', x, y, cardWidth, cardHeight, 8, 8)

        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(gFonts['medium'])
        
        -- Scale font (idk if neccesary)
        local scale = math.min(1, cardWidth / 160)
        love.graphics.push()
        love.graphics.translate(x + cardWidth/2, y + 15)
        love.graphics.scale(scale, scale)
        love.graphics.printf(self.upgrades[i], -cardWidth/2/scale, 0, cardWidth/scale, 'center')
        love.graphics.pop()

        -- Tell user the cost or that they can't buy it
        love.graphics.push()
        love.graphics.translate(x + cardWidth/2, y + cardHeight - 25)
        love.graphics.scale(scale, scale)
        if i == 8 then  
        elseif self:isMaxed(i) then
            love.graphics.setColor(1, 0.5, 0)
            love.graphics.printf("MAXED", -cardWidth/2/scale, 0, cardWidth/scale, 'center')
        elseif self:canAfford(i) then
            love.graphics.setColor(0, 1, 0)
            love.graphics.printf("$" .. self.costs[i], -cardWidth/2/scale, 0, cardWidth/scale, 'center')
        else
            love.graphics.setColor(1, 0, 0)
            love.graphics.printf("$" .. self.costs[i], -cardWidth/2/scale, 0, cardWidth/scale, 'center')
        end
        love.graphics.pop()
    end
end
