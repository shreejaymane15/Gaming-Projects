-- global patterns (used to make the entire map a certain shape)
NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3


-- per - row patterns
SOLID = 1           -- all colors are same in this row
ALTERNATE = 2       -- alternate colors
SKIP = 3            -- skip every other block
NONE = 4            -- no blocks this row



LevelMaker = Class{}



--[[
    Creates a table of Bricks to be returned to the main game, with different
    possible ways of randomizing rows and columns of bricks. Calculates the 
    brick colors and tiers to choose and tiers to choose based on the level
]]


function LevelMaker.createMap(level)
    local bricks = {}

    --randomly choose the number of rows
    local numRows = math.random(1, 5)
    
    --randomly choose the number of coloumns, ensuring odd
    local numCols = math.random(7, 13)
    numCols = numCols % 2 == 0 and (numCols + 1) or numCols

    -- highest possible spawned brick color in this level;
    -- don't go above 3
    local highestTier = math.min(3, math.floor(level / 5))

    -- highest color of highest tier
    local highestColor = math.min(5, level % 5 + 3)

    -- lay out bricks such that they touch each other and fill
    for y = 1, numRows do

        -- whether we want to enable skipping for this row
        local skipPattern = math.random(1, 2) == 1 and true or false

        -- whether we want to enable alternating colors for this row
        local alternatePattern = math.random(1, 2) == 1 and true or false

        -- choose two colors to alternate between
        local alternateColor1 = math.random(1, highestColor)
        local alternateColor2 = math.random(1, highestColor)
        local alternateTier1 = math.random(0, highestTier)
        local alternateTier2 = math.random(0, highestTier)

        -- used only when we want to skip a block, for skip pattern
        local skipFlag = math.random(2) == 1 and true or false

        -- used only when we want alternate a block, for alternate pattern
        local alternateFlag = math.random(2) == 1 and true or false

        -- solid color we'll use if we're not alternating
        local solidColor = math.random(1, highestColor)
        local solidTier  = math.random(0, highestTier)


        for x = 1, numCols do 
            -- If skipping is turned on and we're on a skip iteration
            if skipPattern and skipFlag then
                --turn skipping of for next iteration
                skipFlag = not skipFlag

                --Lua doesn't have a continue statement so this work around
                goto continue
            else
                -- flip the flag to true on a iteration we don't use it
                skipFlag = not skipFlag
            end

            b = Brick(
                -- X-coordinate
                (x - 1)                 -- decrement x by 1 because tables are
                * 32                    -- multiply by 32,
                + 8                     -- the screen should have 8 pixels of padding; we can
                + (13 - numCols) * 16,  -- left-side padding for when there are fewer than 13
                
                -- y-coordinate
                y * 16                  -- just use y * 16, since we need top
            )


            -- if we're alternating figure out which color tier we are on
            if alternatePattern and alternateFlag then
                b.color = alternateColor1
                b.tier = alternateTier1
                alternateFlag = not alternateFlag
            else
                b.color = alternateColor2
                b.tier = alternateTier2
                alternateFlag = not alternateFlag
            end

            -- if not alternating and we made it here then use solid color pattern
            if not alternatePattern then
                b.color = solidColor
                b.tier = solidTier
            end

            table.insert(bricks,b)

            --Lua Version of the continue statement
            ::continue::
        end
    end
    return bricks
end