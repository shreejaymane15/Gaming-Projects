Paddle = Class{}


function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
end

function Paddle:update(dt)
    -- math.max here ensures that we're the greater of 0 or the player's
    -- current calculated Y position when pressing up so we don't
    -- go into negatives; the movement calculations is simply our 
    -- previously-defined paddle speed scaled by dt
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    else
    -- similar to before, this time we use math.min to ensure
    -- go any farther than the bottom of the screen minus the
    -- height (or else it will go partially below, since pos)
    -- Based on its top left corner)
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

--[[
    To be called by our main function in `love.draw`, ideally. Uses Love2D's `retangle` function,
    which takes in a draw mode as the first argument as well as the position and dimensions for the
    rectangle. To change the color, one must call, `love.graphics.setColor`. The newest version of Love2D,
    you can even draw rounded rectangle 
]]

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end