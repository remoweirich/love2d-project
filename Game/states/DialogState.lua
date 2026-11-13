local State = require "states/State"

local Dialog = require "Dialog"

local DialogState = { overlay = true }

function DialogState.enter(onFinish)
    DialogState.onFinish = onFinish
end

function DialogState.update(dt)
    Dialog.update(dt)
    if not Dialog.isRunning() then
        State.pop()
        if DialogState.onFinish then
            DialogState.onFinish()
        end
    end
end

function DialogState.draw()
    Dialog.draw()
end

function DialogState.keypressed(key)
    local d = DialogManager:getActiveDialog()
    if key == "e" or key == "return" then
        if d and not d.done then DialogManager:complete()
        else DialogManager:pop() end
    elseif key == "down" then DialogManager:changeOption(1)
        elseif key == "up"   then DialogManager:changeOption(-1)
    end
end

return DialogState