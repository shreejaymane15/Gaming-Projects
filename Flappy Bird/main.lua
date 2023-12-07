-- import push library 
push = require 'push'


Class = require 'class'

-- import Bird class
require 'Bird'

-- import pipe class
require 'Pipe'

-- 
require 'PipePair'

require 'StateMachine'

require '../states/BaseState'

require 'states/CountdownState'

require 'states/ScoreState'

require '../states/TitleScreenState'

require '../states/PlayState'

-- Actual window height and width
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720


-- Game screen height and width
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288


-- images we load into memory from files to later draw onto the screen
local background = love.graphics.newImage('background.png')
local backgroundScroll = 0

local ground = love.graphics.newImage('ground.png')
local groundScroll = 0


-- speed at which we should scroll our images, scaled by   
local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

-- Point at which we should loop our back and back to
local BACKGROUND_LOOPING_POINT = 413

-- our bird sprite
local bird = Bird()


-- our table of pipe pairs
local pipePairs = {}

-- our timer for spawning pipes
local spawnTimer = 0

--
local scrolling = true


--initialize  our last recorded Y value for a gap placement 
local lastY = -PIPE_HEIGHT + math.random(80) + 20

function love:load()
    -- initialize our nearest-neighbour 
    love.graphics.setDefaultFilter('nearest', 'nearest')
    

    -- seed the RNG
    math.randomseed(os.time())

    -- app window title
    love.window.setTitle('Flappy Bird')
    
    
    -- initialize our nice looking retro text fonts
    smallFont = love.graphics.newFont('font.ttf', 8)    
    mediumFont = love.graphics.newFont('flappy.ttf', 14)
    flappyFont = love.graphics.newFont('flappy.ttf', 28)
    hugeFont = love.graphics.newFont('flappy.ttf', 56)
    love.graphics.setFont(flappyFont)
    
    
    -- initialize our virtual resolution 
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })


    -- initialize state machine with all state-returning functions
    gStateMachine = StateMachine{
        ['title'] = function() return TitleScreenState() end,
        ['countdown'] = function() return CountdownState() end,
        ['play'] = function() return PlayState() end,
        ['score'] = function() return ScoreState() end
    }
    gStateMachine:change('title')

    -- initailize input table
    love.keyboard.keypressed = {}
end


function love.resize(w, h)
    push:resize(w, h)
end


function love.keypressed(key)
    love.keyboard.keypressed[key] = true

    if key == 'escape' then
        love.event.quit()
    end
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keypressed[key] then
        return true
    else
        return false
    end
end

function love.update(dt)

    if scrolling then 
        -- scroll background by preset speed * dt, looping back to 0 after the loop 
        backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT

        -- scroll ground by preset speed * dt, looping back to 0 after the screen 
        groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH



        gStateMachine:update(dt)
        
    --     spawnTimer = spawnTimer + dt

    --     -- spawn a new Pipepair if the timer is past 2 seconds
    --     if spawnTimer > 2 then
            
    --         -- table.insert(pipes, Pipe())
            
    --         -- modify the last Y coordinate we placed so pipe gaps aren't too far apart
    --         -- no higher than 10 pixels below the top edge of the screen
    --         -- and no lower than a gap length (90 pixels) from the bottom

    --         local y = math.max(-PIPE_HEIGHT + 10, math.min(lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
    --         lastY = y

    --         table.insert(pipePairs, PipePair(y))
            
    --         spawnTimer = 0

    --     end
        
    --     bird:update(dt)

        
    --     -- for every pipe in the scene ...
    --     for k, pair in pairs(pipePairs) do
            
    --         pair:update(dt)
            
    --         -- Check to see if the bird is collided with the pipe
    --         for l, pipe in pairs(pair.pipes) do
    --             if bird:collides(pipe) then
    --                 -- pause the game to show collision
    --                 scrolling = false
    --             end
    --         end

    --         -- if pipe is no longer visible past left edge, remove

    --         -- remove any flagged pipes
    --         -- we need this seconf loop, rather than deleting in the previous loop, 
    --         -- modifying the table in-place withut explicit keys will result in skipp
    --         -- next pip, since all implicit keys (numerical indices ) are automatically
    --         -- down after a table removal
    --         for k, pair in pairs(pipePairs) do 
    --             if pair.remove then
    --                 table.remove(pipePairs, k)
    --             end
    --         end
    --     end
        love.keyboard.keypressed = {}
    end
end



function love.draw()
    push:start()

    love.graphics.draw(background, -backgroundScroll, 0)
    
    gStateMachine:render()
    
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)
    -- for k, pair in pairs(pipePairs) do
    --     pair:render()
    --  end    
    
   
    -- bird:render()

    push:finish()
end