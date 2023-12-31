Bird = Class{}

local GRAVITY = 20

function Bird:init()

    -- load bird image from disk and assign its width and height
    self.image = love.graphics.newImage('bird.png')
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
   
    -- position bird in the middle of the screen 
    self.x = VIRTUAL_WIDTH / 2 - (self.width / 2)
    self.y = VIRTUAL_HEIGHT / 2 - (self.height / 2)

    -- give bird some velocity
    self.dy = 0
end


--[[
    AABB collision that excepts a pipe, which will have an X and Y and refereance global pipe width and height values
]]

function Bird:collides(pipe)
    -- the 2's are left and top offsets
    -- the 4's are right and bottom offsets
    -- both offsets are used to shrink the bounding box to give the player
    -- a little bit of leeway with the collision
    if (self.x + 2) + (self.width - 4) >= pipe.x and self.x + 2 <= pipe.x + PIPE_WIDTH then
        if (self.y + 2) + (self.height - 4) >= pipe.y and self.y + 2 <= pipe.y + PIPE_HEIGHT then
            return true
        end
    end
end

function Bird:update(dt)
    -- to add gravity to velocity of bird image gradually
    self.dy = self.dy + GRAVITY * dt


    -- to add antigravity to space 
    if love.keyboard.wasPressed('space') then
        self.dy = -5;
        sounds['jump']:play()
    end

    -- to add velocity to height of image
    self.y = self.y + self.dy
end

function Bird:render()
    love.graphics.draw(self.image, self.x, self.y)
end

