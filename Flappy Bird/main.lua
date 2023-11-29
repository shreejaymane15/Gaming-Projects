-- import push library 
push = require 'push'


Class = require 'class'

-- import Bird class
require 'Bird'

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


local bird = Bird()

function love:load()
    -- initialize our nearest-neighbour 
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Flappy Bird')
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })
end


function love.resize(w, h)
    push:resize(w, h)
end


function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end


function love.update(dt)

    -- scroll background by preset speed * dt, looping back to 0 after the loop 
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT

    -- scroll ground by preset speed * dt, looping back to 0 after the screen 
    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH

    bird:update(dt)
end



function love.draw()
    push:start()

    love.graphics.draw(background, -backgroundScroll, 0)

    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)
   
    bird:render()

    push:finish()
end