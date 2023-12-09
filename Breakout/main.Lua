require 'src/Dependancies'

--[[
    Called just once the beginning of the game; used to set up game objects, variables etc.
    and Prepare the game world
]]

function love.load()
    -- set love's default filter to "nearest-neighbour", while essentially
    -- means there will be no filtering of pixels (blurriness), which is
    -- improvement for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- seed the RNG so that calls to random are always random
    math.randomseed(os.time())

    -- set the application title bar
    love.window.setTitle('Breakout')

    -- initailize our fonts
    gFonts = {
        ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
        ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
        ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
    }
    love.graphics.setFont(gFonts['small'])


    -- load up the graphics we'll using throughout oue game
    gTexture = {
        ['background'] = love.graphics.newImage('graphics/background.png'),
        ['main'] = love.graphics.newImage('graphics/breakout.png'),
        ['arrows'] = love.graphics.newImage('graphics/arrows.png'),
        ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
        ['particle'] = love.graphics.newImage('graphics/particle.png')
    }

    -- initialize our virtual resoultion, which will be rendered in our
    -- actual window no matter its dimensions

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,{
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    -- set up our sound effects; later, we can just insert them
    -- call each entry's play method
    gSounds = {
        ['paddle-hit'] = love.audio.newSource('sounds/paddle-hit.wav'),
        ['score'] = love.audio.newSource('sounds/score.wav'),
        ['wall-hit'] = love.audio.newSource('sounds/wall-hit.wav'),
        ['confirm'] = love.audio.newSource('sounds/confirm.wav'),
        ['select'] = love.audio.newSource('sounds/select.wav'),
        ['no-select'] = love.audio.newSource('sounds/no-select.wav'),
        ['brick-hit-1'] = love.audio.newSource('sounds/brick-hit-1.wav'),
        ['brick-hit-2'] = love.audio.newSource('sounds/brick-hit-2.wav'),
        ['hurt'] = love.audio.newSource('sounds/hurt.wav'),
        ['victory'] = love.audio.newSource('sounds/victory.wav'),
        ['recover'] = love.audio.newSource('sounds/recover.wav'),
        ['high-score'] = love.audio.newSource('sounds/high-score.wav'),
        ['pause'] = love.audio.newSource('sounds/pause.wav'),
        ['music'] = love.audio.newSource('sounds/mucic.wav')
    }


    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end
    }
    gStateMachine:change('start')

    -- a table we'll use to keep track of which keys have been pressed this 
    -- frame, to get around the fact that LOVE's default callback won't let us
    -- test for input from within other functions
    love.keyboard.keysPressed = {}
end

--[[
    Called whenever we change the dimension of the window, as by dragging out its bottom corner
    For Example -> In this case, we only need to worry about calling out to 'push' to handle
    resizing. Takes in a 'w' and 'h' variable resp.
]]

function love.resize(w, h)
    push:resize(w, h)
end

--[[
    called every frame, passing in 'dt' since the last frame, 'dt'
    is short for 'deltatime' and is measured in seconds. Multiplying
    this by any changes we wish to make in our game will allow our game to perform
    consistently across all hardware; otherwise, any changes we make will be applied
    as fast as possible and vary across system hardware
]]

function love.update(dt)
    -- this time, we pass in dt to the state object we're currently using
    gStateMachine:update(dt)

    -- reset keys presssed
    love.keyboard.keysPressed = {}

end

--[[
    A callback that processes key strokes as they happen, just the once.
    Does not account for keys that are held down, which is handled by a seperate function
    ('love.keyboard.isDown'). Useful for when we want things happen right away, just once,
    like when we want to quit
]]

function love.keyPressed(key)
    -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true
end


--[[
    A custom fuction that will let us test for individual keystrokes outside of the default 'love.keypressed' callback,
    since we can't call that logic elsewhere by default
]]

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

--[[
    called each frame after update; is responsible simply for drawing all of our objects and more to the screen
]]

function love.draw()
    -- begin drawing with push, in our virtual resoultion
    push:apply('start')


    -- background should be drawn regardless of state, scaled to fit our virtual resoultion
    local backgroundWidth = gTextures['background']:getWidth()
    local backgoundHeight = gTextures['backgrounnd']:getHeight()

    love.graphics.draw(gTextures['background'],
        --draw at co-ordinate 0, 0
        0, 0,

        -- no rotation
        0,

        --scales factors on X and Y axis so it fills the screen
        VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgoundHeight - 1))
    
    -- use the state of machine to defer rendering to the current state we are in
    gStateMachine:render()

    --display FPS for debugging; Simply comment out to remove
    displayFPS()

    push:apply('end')
end

-- Renders current FPS

function displayFPS()
    -- Simply FPS display across all StartState
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: '.. tostring(love.timer.getFPS()), 5, 5)
end