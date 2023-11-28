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
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)

    -- set Love2D active font to small font object
    love.graphics.setFont(smallFont)
    

    -- set up our sound effects; later, we can just index this table end call each entry's `play` method
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['win'] = love.audio.newSource('sounds/win.wav', 'static')
    }

    -- initialize virtual resolution, which will be rendered within our actual window no matter its dimensions
    -- replace our love.window.setMode from last example

    -- push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    --     fullscreen = false,
    --     resizable = false,
    --     vsync = true
    -- })

    -- set resize = true

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })



    --initialize score variables, used for rendering on the screen and keeping track of winner
    player1Score = 0
    player2Score = 0
    
    --paddle positions on the Y axis (they can only move up or down)
    -- player1Y = 30
    -- player2Y = VIRTUAL_HEIGHT - 50

    -- either going to be 1 or 2; whomever is scored on gets to serve the
    -- following turn
    servingPlayer = 1


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
    gameState  = 'start'
end



--[[
    Called by LOVE whenever we resize the screen; here, we just want to pass it's width and height 
    to push so our virtual resolution can be resized as needed
]]
function love.resize(w, h)
    push:resize(w, h)
end

--[[Runs every frame, with "dt" passed in, our delta in seconds since the last frame,
    Which LOVE2D supplies us
  ]]

function love.update(dt)
    if gameState == 'serve' then
    -- before switching to play, initialize ball's velocity based
    -- on player who last scored

        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140 , 200)
        else
            ball.dx = -math.random(140, 200)
        end

    elseif gameState == 'play' then
    -- detects ball collision with paddles, reversing dx if true and
    -- slightly increasing it, then altering the dy based on the position
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else    
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        -- detect upper and lower screen boundry collision and reverse if collision happened
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- -4 to account for ball size 
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = - ball.dy
            sounds['wall_hit']:play()
        end
        
        -- if we reach the left or right edge of the screen,
        -- go back to start and update the score
        
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()    
            -- if we've reached a score of 10, the game is over; set the state to done so we can show the victory message
            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
                sounds['win']:setLooping(true)
                sounds['win']:play()
            else
                gameState = 'serve'
                ball:reset()
            end
        end
        
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()    

            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
                sounds['win']:setLooping(true)
                sounds['win']:play()
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end
        
   
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

    if gameState == 'play' then
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
        -- if gameState == 'start' then
        --     gameState = 'play'
        -- else
        --     gameState = 'start'
            
        --     --paddle positions on the Y axis (they can only move up or down)
        --     -- player1Y = 30
        --     -- player2Y = VIRTUAL_HEIGHT - 50

        --     -- start ball's position in the middle of the screen
        --     -- ballX = VIRTUAL_WIDTH / 2 - 2
        --     -- ballY = VIRTUAL_HEIGHT / 2 - 2

        --     --given ball's X and y velocity a random starting value
        --     --the and/or pattern here is Lua's way of accomplishing a ternary
        --     -- in other programming languages like C
        --     -- ballDX = math.random(2) == 1 and 100 or -100
        --     -- ballDY = math.random(-50, 50) * 1.5

        --     ball:reset()
        -- end
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            -- game is simply in a restart phase here
            -- player to the opponent of whomever won 
            gameState = 'serve'
            ball:reset()
            player1Score = 0
            player2Score = 0
            sounds['win']:stop()
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
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
    
    -- if gameState == 'start' then
    --     love.graphics.printf('Hello Start State!', 0, 20, VIRTUAL_WIDTH, 'center')
    -- else
    --     love.graphics.printf('Hello Play State!', 0, 20, VIRTUAL_WIDTH, 'center')
    -- end
    
    -- love.graphics.setFont(scoreFont)
    -- love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    -- love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)


    displayScore()

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        -- no UI messages to display in play
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

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


--[[
    Simply draws the score to the screen.
]]
function displayScore()
    -- draw score on the left and right center of the screen
    -- need to switch font to draw before actually printing
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end
