push = require 'push-master.push'



WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- Speed 
PADDLE_SPEED = 200

-- Runs When the game first starts up, only once; used to initialize the game

function love.load()
    -- initialize resolution of winow to WINDOW_WIDTH and WINDOW_HEIGHT

    -- love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT,{
    --     fullscreen = false,
    --     resizable = false,
    --     vsync = true
    -- })


    love.graphics.setDefaultFilter('nearest', 'nearest')


    -- more "retro-looking" font object we can use for any text
    smallFont = love.graphics.newFont('font.ttf', 8)


    scoreFont = love.graphics.newFont('font.ttf', 32)

    -- set Love2D active font to small font object
    love.graphics.setFont(smallFont)
    
    -- initialize virtual resolution, which will be rendered within our actual window no matter its dimensions
    -- replace our love.window.setMode from last example

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    --initialize score variables, used for rendering on the screen and keeping track of winner
    player1Score = 0
    player2Score = 0
    
    --paddle positions on the Y axis (they can only move up or down)
    player1Y = 30
    player2Y = VIRTUAL_HEIGHT - 50
end

--[[Runs every frame, with "dt" passed in, our delta in seconds since the last frame,
    Which LOVE2D supplies us
  ]]

function love.update(dt)
    --player 1 movement
    if love.keyboard.isDown('w') then
        --add negative paddle speed to current Y scaled by deltaTime
        player1Y = player1Y + -PADDLE_SPEED * dt
    elseif love.keyboard.isDown('s')then
        --add positive paddle speed to current Y scaled by deltaTime
        player1Y = player1Y + PADDLE_SPEED * dt
    end

    -- player 2 movement
    if love.keyboard.isDown('up')then
        --add negative paddle speed to current Y scaled by deltatime
        player2Y = player2Y + -PADDLE_SPEED * dt
    elseif love.keyboard.isDown("down")then
        --add positive paddle speed to current Y scaled by deltatime
        player2Y = player2Y + PADDLE_SPEED * dt
    end

end


--[[
    Keyboard handling, called by Love2d each frame;
    passes in the key we pressed so we can access
]]

function love.keypressed(key)
    -- Keys can accessed by string name
    if key == 'escape' then    
        --function LOVE gives us to terminate application
        love.event.quit()
    end
end


-- Called after update by LOVE2D, used to draw anything on screen, update

function love.draw()

    --begin rendering at virtual resolution
    push:apply('start')
    
    --clear the screen with specific color; in this case, a color similar
    --to some versions of the original Pong
    -- love.graphics.clear(40, 45, 52, 255)


    -- love.graphics.printf(
    --     'Hello Pong!',                  -- text to render
    --     0,                              -- starting X (0 since we're going to center)
    --     VIRTUAL_HEIGHT / 2 - 6,          -- starting Y (halfway down the screen)
    --     VIRTUAL_WIDTH,                   -- number of pixels
    --     'center')                       -- alignment mode
    
    love.graphics.setFont(smallFont)
    love.graphics.printf(
        'Hello Pong!',                  -- text to render
        0,                              -- starting X (0 since we're going to center)
        20,          -- starting Y (halfway down the screen)
        VIRTUAL_WIDTH,                   -- number of pixels
        'center')                       -- alignment mode
    

    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    --render first paddle (left paddle)
    love.graphics.rectangle('fill', 10, player1Y, 5, 20)

    --render second paddle (right side)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, player2Y, 5, 20)

    --render ball (center)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- end rendering at virtual resolution
    push:apply('end')
end
