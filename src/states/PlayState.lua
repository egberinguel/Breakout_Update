PlayState = Class{__includes = BaseState}

HIT_MAX = 40              
lockedBrick = false       

function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.ball = params.ball
    self.level = params.level
    self.keys = params.keys + 1

   self.recoverPoints = params.recoverPoints
   self.paddlePoints = params.paddlePoints

    self.ball[1].dy = math.random(-70, -80)

    self.powerup = { [1] = Powerup(-5, -5, 4)}

       hitcount =  math.floor(self.health/3 * HIT_MAX) 
end


function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    self.paddle:update(dt)

    for k, b in pairs(self.ball) do
    b:update(dt)
    end
    for k, pp in pairs(self.powerup) do
    pp:update(dt)
    end
    
   for k, bol in pairs(self.ball) do
    if bol:collides(self.paddle) then
        bol.y = self.paddle.y - 8
        bol.dy = -bol.dy

        if bol.x < self.paddle.x + (self.paddle.width / 2) 
        and self.paddle.dx < 0 then
            bol.dx = -50 + -(8 *(self.paddle.x + self.paddle.width/2 - bol.x) 
                                           * 2 / self.paddle.size)
        
        elseif bol.x > self.paddle.x + (self.paddle.width / 2) 
        and self.paddle.dx > 0 then
            bol.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width/2 - bol.x) 
                                            * 2 / self.paddle.size)
        end

        gSounds['paddle-hit']:play()
    end
    end
                      
     for k, pp in pairs(self.powerup) do                         
        if pp:collide(self.paddle) then             
            pp.y = self.paddle.y - 16
            table.remove(self.powerup,k)
            gSounds['paddle-hit']:play()
            gSounds['select']:play()
            gSounds['pause']:play()
            if pp.n == 4 then
            for i = 1, 4 do
            b = Ball()                                      
            b.skin = math.random(7)
            b.x = self.ball[1].x
            b.y = self.ball[1].y
            b.dy = self.ball[1].dy + math.random(-15,15)
            b.dx = self.ball[1].dx + math.random(-10,10)
            table.insert(self.ball,b)
            end
        elseif pp.n == 10 then
                self.keys = self.keys + 1
             end

        end
        if pp.y > VIRTUAL_HEIGHT then
            table.remove(self.powerup,k)
        end
    
    end


    for i, bol in pairs(self.ball) do
    for k, brick in pairs(self.bricks) do
        if brick.isLocked == true then
            lockedBrick = true
        end
 
        
        if brick.inPlay and bol:collides(brick) then

            if brick.isLocked == true and self.keys >= 1 then
                brick.inPlay = false
                self.keys = self.keys - 1
                gSounds['brick-hit-1']:play()
                self.score = self.score + 200
            end
            
            hitcount = hitcount - 1
            if math.random(hitcount) == hitcount then                      
                table.insert(self.powerup, Powerup(brick.x, brick.y, 4))
                hitcount =   math.floor(self.health/3 * HIT_MAX)                         
            elseif lockedBrick == true and math.random(math.floor(hitcount/2)) == math.floor(hitcount/2)  then
                table.insert(self.powerup, Powerup(brick.x, brick.y, 10))
                hitcount =   math.floor(self.health/3 * HIT_MAX) 
            end
            if brick.isLocked == false then
                
            self.score = self.score + (brick.tier * 200 + brick.color * 25)
            brick:hit()
            else
                hitcount = hitcount - 1
                gSounds['no-select']:play()
            end
            
            if self.score > self.recoverPoints then
                self.health = math.min(3, self.health + 1)

                self.recoverPoints = math.min(100000, self.recoverPoints * 2)

                gSounds['recover']:play()
            end

            if self.score > self.paddlePoints then
                if self.paddle.size < 4 then
                self.paddle.size = self.paddle.size + 1
                self.paddle.width = self.paddle.size * 32
                end
                self.paddlePoints = math.min(120000, self.paddlePoints + 7000)
                gSounds['recover']:play()
            end

            
            if self:checkVictory() then
                gSounds['victory']:play()

                gStateMachine:change('victory', {
                    level = self.level,
                    paddle = self.paddle,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    ball = self.ball,
                    recoverPoints = self.recoverPoints,
                    paddlePoints = self.paddlePoints,
                    keys = self.keys
                })
            end

            if bol.x + 2 < brick.x and bol.dx > 0 then
                
                bol.dx = -bol.dx
                bol.x = brick.x - 8
            
            elseif bol.x + 6 > brick.x + brick.width and bol.dx < 0 then
                
                bol.dx = -bol.dx
                bol.x = brick.x + 32
            
            elseif bol.y < brick.y then
                
                bol.dy = -bol.dy
                bol.y = brick.y - 8
            
            else
                
                bol.dy = -bol.dy
                bol.y = brick.y + 16
            end

            if math.abs(bol.dy) < 150 then
                bol.dy = bol.dy * 1.02
            end

            break
        end
    end
end

    for j, bol in pairs(self.ball) do
        if bol.y > VIRTUAL_HEIGHT then
            table.remove(self.ball,j)
        end
    end
    if #self.ball == 0 then
        self.health = self.health - 1
        if self.paddle.size > 1 then
        self.paddle.size = self.paddle.size - 1
        self.paddle.width = self.paddle.size * 32
        self.keys = math.max(0, self.keys - 3)
        end
        gSounds['hurt']:play()
    
        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints,
                paddlePoints = self.paddlePoints,
                keys = self.keys
            })
        end
    end

    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    for k, b in pairs(self.ball) do
    b:render()
    end
    
    for k, pp in pairs(self.powerup) do 
    pp:render()
    end

    renderScore(self.score)
    renderHealth(self.health)
    renderKeys(self.keys)

    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end