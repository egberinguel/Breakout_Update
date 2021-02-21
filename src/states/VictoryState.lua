VictoryState = Class{__includes = BaseState}

function VictoryState:enter(params)
    self.level = params.level
    self.score = params.score
    self.highScores = params.highScores
    self.paddle = params.paddle
    self.health = params.health
    self.ball = params.ball
    self.recoverPoints = params.recoverPoints
    self.paddlePoints = params.paddlePoints
    self.keys = params.keys
    self.paddle.size = math.max(self.paddle.size, 2)
    self.paddle.width = self.paddle.size * 32
end

function VictoryState:update(dt)
    self.paddle:update(dt)

    for k, bol in pairs(self.ball) do
        table.remove(self.ball,k)
    end
    table.insert(self.ball,Ball(math.random(7)))
    self.ball[1].x = self.paddle.x + (self.paddle.width / 2) - 4
    self.ball[1].y = self.paddle.y - 8

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('serve', {
            level = self.level + 1,
            bricks = LevelMaker.createMap(self.level + 1),
            paddle = self.paddle,
            health = self.health,
            score = self.score,
            highScores = self.highScores,
            recoverPoints = self.recoverPoints,
            paddlePoints = self.paddlePoints,
            keys = self.keys
        })
    end
end

function VictoryState:render()
    self.paddle:render()
    for k, bol in pairs(self.ball) do
    bol:render()
    end
    renderHealth(self.health)
    renderScore(self.score)
    renderKeys(self.keys)

    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("Level " .. tostring(self.level) .. " complete!",
        0, VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter to serve!', 0, VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH, 'center')
end