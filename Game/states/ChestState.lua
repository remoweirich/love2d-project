local State = require "states/State"
local ChestUI = require "UI/ChestUI"
local BookState = require "states/BookState"

local ChestState = { overlay = true }

function ChestState.enter(chest)
    ChestState.chest = chest
    ChestUI.toggle(ChestState.chest)
end

function ChestState.keypressed(key)
    local chest = ChestState.chest
    if key == "e" and not ChestUI.hasPopup() then
        ChestUI.toggle(chest)
        State.pop()
        return
    end
    if key == "tab" then
        State.push(BookState, chest)
    else
        ChestUI.keypressed(key, chest, player)
    end

end

function ChestState.draw()
    ChestUI.draw(ChestState.chest)
end

return ChestState