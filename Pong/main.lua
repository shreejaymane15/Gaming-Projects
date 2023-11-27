push = require 'push-master.push'

Class = require 'class'

require 'Paddle'

require 'Ball'


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



    love.window.setTitle('Pong')

    --"seed" the RNG so that calls to random are always random
    -- use the current time, since that will vary on startup every time
    math.randomseed(os.time())

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
    -- player1Y = 30
    -- player2Y = VIRTUAL_HEIGHT - 50


    -- initialize our player paddles; make them global so that they can be
    -- detected by other functions and ,modules
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5 ,20)

    --velocity and position variables for our ball when play starts
    -- ballX = VIRTUAL_WIDTH / 2 - 2
    -- ballY = VIRTUAL_HEIGHT / 2 - 2


    --Place a ball in the middle of the screen
    ball = Ball(VIRTUAL_WIDTH / 2 - 2 , VIRTUAL_HEIGHT / 2 - 2, 4, 4)


    --math.random returns a random value between the left and right number
    -- ballDX = math.random(2) == 1 and 100 or -100
    -- ballDY = math.random(-50, 50)

    --game state variable used to transition between different parts of the game
    --(used for beginning, menus, main game, high score list etc.)
    --we will use this to determine behaviour during render and update
    gamestate  = 'start'
end

--[[Runs every frame, with "dt" passed in, our delta in seconds since the last frame,
    Which LOVE2D supplies us
  ]]

function love.update(dt)
    -- player 1 movement
    -- if love.keyboard.isDown('w') then
        --add negative paddle speed to current Y scaled by deltaTime
        --now, we clamp our position between the bounds of the screen
        -- math.max returns the greater of two values; 0 and player Y
        -- will ensure we don't go above it
        -- player1Y = math.max(0, player1Y + -PADDLE_SPEED * dt)

    -- elseif love.keyboard.isDown('s')then
        --add positive paddle speed to current Y scaled by deltaTime
        -- math.min returns the lesser of two values; bottom of edge minus 
        -- and player Y will ensure we don't go below it
        -- player1Y = math.max(VIRTUAL_HEIGHT - 20, player1Y + PADDLE_SPEED * dt)
    -- end


    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end
    

    -- player 2 movement
    -- if love.keyboard.isDown('up')then
    
        --add negative paddle speed to current Y scaled by deltatime
        -- player2Y = math.max(0, player2Y + -PADDLE_SPEED * dt)
    
    -- elseif love.keyboard.isDown("down")then
    
        --add positive paddle speed to current Y scaled by deltatime
        -- player2Y = math.max(VIRTUAL_HEIGHT-20, player2Y + PADDLE_SPEED * dt)
    
    -- end

    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end


    -- update our ball state based on its DX and DY only if we are in play state
    -- scale the velocity by dt so movement is framerate-independant

    if gamestate == 'play' then
        -- ballX = ballX + ballDX * dt
        -- ballY = ballY + ballDY * dt
        ball:update(dt)
    end 

    player1:update(dt)
    player2:update(dt)
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
    -- if we press enter during the start state of the game, we'll go into play state
    -- during play mode, the ball will move in a random direction
    elseif key == 'enter' or  key == 'return' then
        if gamestate == 'start' then
            gamestate = 'play'
        else
            gamestate = 'start'
            
            --paddle positions on the Y axis (they can only move up or down)
            -- player1Y = 30
            -- player2Y = VIRTUAL_HEIGHT - 50

            -- start ball's position in the middle of the screen
            -- ballX = VIRTUAL_WIDTH / 2 - 2
            -- ballY = VIRTUAL_HEIGHT / 2 - 2

            --given ball's X and y velocity a random starting value
            --the and/or pattern here is Lua's way of accomplishing a ternary
            -- in other programming languages like C
            -- ballDX = math.random(2) == 1 and 100 or -100
            -- ballDY = math.random(-50, 50) * 1.5

            ball:reset()
        end
    end
end


-- Called after update by LOVE2D, used to draw anything on screen, update

function love.draw()

    --begin rendering at virtual resolution
    push:apply('start')
    
    --clear the screen with specific color; in this case, a color similar
    --to some versions of the original Pong
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)


    -- love.graphics.printf(
    --     'Hello Pong!',                  -- text to render
    --     0,                              -- starting X (0 since we're going to center)
    --     VIRTUAL_HEIGHT / 2 - 6,          -- starting Y (halfway down the screen)
    --     VIRTUAL_WIDTH,                   -- number of pixels
    --     'center')                       -- alignment mode
    
    love.graphics.setFont(smallFont)
    -- love.graphics.printf(
    --     'Hello Pong!',                  -- text to render
    --     0,                              -- starting X (0 since we're going to center)
    --     20,          -- starting Y (halfway down the screen)
    --     VIRTUAL_WIDTH,                   -- number of pixels
    --     'center')                       -- alignment mode
    
    if gamestate == 'start' then
        love.graphics.printf('Hello Start State!', 0, 20, VIRTUAL_WIDTH, 'center')
    else
        love.graphics.printf('Hello Play State!', 0, 20, VIRTUAL_WIDTH, 'center')
    end
    
    -- love.graphics.setFont(scoreFont)
    -- love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    -- love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    --render first paddle (left paddle)
    -- love.graphics.rectangle('fill', 10, player1Y, 5, 20)
    player1:render()

    --render second paddle (right side)
    -- love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, player2Y, 5, 20)
    player2:render()

    -- render ball (center)
    -- love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- love.graphics.rectangle('fill', ballX, ballY, 4, 4)

    ball:render()


    -- new function just to demonstrate how to see FPS in LOVE2D
    displayFPS()

    -- end rendering at virtual resolution
    push:apply('end')
end



--[[
    Renders the current FPS.
]]

function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)    -- `..` to concanate string with number
end