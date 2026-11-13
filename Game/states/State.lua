local State = { stack = {} }


function State.current() return State.stack[#State.stack] end

function State.push(s, ...)
    table.insert(State.stack, s)
    if s.enter then 
        s.enter(...) 
    end
end

function State.pop()
    local s = table.remove(State.stack)
    if s and s.exit then
        s.exit()
    end
end

function State.update(dt)
    local s = State.current()
    if s.update then
        s.update(dt)
    end
end

function State.keypressed(key)
    local s = State.current()
    if s.keypressed then
        s.keypressed(key)
    end
end


function State.draw() 
    local first = #State.stack
    while first > 1 and State.stack[first].overlay do
        first = first - 1
    end
    for i = first, #State.stack do
        State.stack[i].draw()
    end
end

return State