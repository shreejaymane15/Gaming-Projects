-- StateMachine is a state machine
-- Usage:-

-- -- States are only created as need, to save memory, reduce clean up bugs and
-- -- due to garbage collection taking longer with more data in memory.

-- -- States are added with a string identifier and an intialisation function.
-- -- It is except the init function, when called, will return a table with
-- -- Render, Update, Enter and Exit methods




StateMachine = Class{}

function StateMachine:init(states)
    self.empty = {
        render = function() end,
        update = function() end,    
        enter = function() end,
        exit = function() end
    }
    
    self.states =  states or {} -- [name] -> [function that returns state]
    self.current = self.empty
end


function StateMachine:change(stateName, enterParams)
    assert(self.states[stateName])   -- state must exist
    self.current:exit()
    self.current = self.states[stateName]()
    self.current:enter(enterParams)
end

function StateMachine:update(dt)
    self.current:update(dt)
end

function StateMachine:render()
    self.current:render()
end