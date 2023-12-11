LevelMaker = Class{}



function LevelMaker.createMap(level)
    local bricks = {}

    --randomly choose the number of rows
    local numRows = math.random(1, 5)
    
    --randomly choose the number of coloumns
    local numCols = math.random(7, 13)

    -- lay out bricks such that they touch each other and fill
    for y = 1, numRows do
        for x = 1, numCols do 
            b = Brick(
                -- X-coordinate
                (x - 1)                 -- decrement x by 1 because tables are
                * 32                    -- multiply by 32,
                + 8                     -- the screen should have 8 pixels of padding; we can
                + (13 - numCols) * 16,  -- left-side padding for when there are fewer than 13
                
                -- y-coordinate
                y * 16                  -- just use y * 16, since we need top
            )

            table.insert(bricks,b)
        end
    end
    return bricks
end