Brick = Class{}

paletteColors = {
    [1] = {
        ['r'] = 99,
        ['g'] = 155,
        ['b'] = 255
    },
    [2] = {
        ['r'] = 106,
        ['g'] = 190,
        ['b'] = 47
    },
    [3] = {
        ['r'] = 217,
        ['g'] = 87,
        ['b'] = 99
    },
    [4] = {
        ['r'] = 215,
        ['g'] = 123,
        ['b'] = 186
    },
    [5] = {
        ['r'] = 251,
        ['g'] = 242,
        ['b'] = 54
    }
}

function Brick:init(x, y)
    self.tier = 0
    self.color = 1
    self.isLocked = false
    
    self.x = x
    self.y = y
    self.width = 32
    self.height = 16
    
    self.inPlay = true

    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)

    self.psystem:setParticleLifetime(0.5, 1)

    self.psystem:setLinearAcceleration(-15, 0, 15, 80)

    self.psystem:setEmissionArea('normal', 10, 10,0,true)
end

function Brick:hit()
      

    self.psystem:setColors(
        paletteColors[self.color].r/255,
        paletteColors[self.color].g/255,
        paletteColors[self.color].b/255,
        55 * (self.tier + 1),
        paletteColors[self.color].r/255,
        paletteColors[self.color].g/255,
        paletteColors[self.color].b/255,
        0
    )
    self.psystem:emit(64)

    gSounds['brick-hit-2']:stop()
    gSounds['brick-hit-2']:play()

    if self.tier > 0 then
        if self.color == 1 then
            self.tier = self.tier - 1
            self.color = 5
        else
            self.color = self.color - 1
        end
    else
        if self.color == 1 then
            self.inPlay = false
        else
            self.color = self.color - 1
        end
    end

    if not self.inPlay then
        gSounds['brick-hit-1']:stop()
        gSounds['brick-hit-1']:play()
    end
end

function Brick:update(dt)
    self.psystem:update(dt)
end

function Brick:render()
    if self.inPlay then
        if self.isLocked == false then
        love.graphics.draw(gTextures['main'], 
            gFrames['bricks'][1 + ((self.color - 1) * 4) + self.tier],
            self.x, self.y)
        
    else
        love.graphics.draw(gTextures['main'], gFrames['bricks'][22], self.x, self.y)
    end
    end
end

function Brick:renderParticles()
    love.graphics.draw(self.psystem, self.x + 16, self.y + 8)
end