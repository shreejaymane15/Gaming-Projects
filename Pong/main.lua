push = require 'push-master.push'



WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243




-- Runs When the game first starts up, only once; used to initialize the game

function love.load()
    -- initialize resolution of winow to WINDOW_WIDTH and WINDOW_HEIGHT

    -- love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT,{
    --     fullscreen = false,
    --     resizable = false,
    --     vsync = true
    -- })


    love.graphics.setDefaultFilter('nearest', 'nearest')
    -- initialize virtual resolution, which will be rendered within our actual window no matter its dimensions
    -- replace our love.window.setMode from last example

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
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
    
    love.graphics.printf(
        'Hello Pong!',                  -- text to render
        0,                              -- starting X (0 since we're going to center)
        VIRTUAL_HEIGHT / 2 - 6,          -- starting Y (halfway down the screen)
        VIRTUAL_WIDTH,                   -- number of pixels
        'center')                       -- alignment mode
    
    -- end rendering at virtual resolution
    push:apply('end')
end
