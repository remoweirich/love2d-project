local State = require "states/State"
local BookUI = require "UI/BookUI"
local InteractableUI = require "UI/InteractableUI"

local BookState = { overlay = true }

function BookState.enter(interactable)
    BookState.interactable = interactable
    BookUI.toggle(player)
end


function BookState.keypressed(key)
    local interactable = BookState.interactable
    if key == "tab" and not BookUI.hasPopup() then
        BookUI.toggle(player)
        State.pop()
        return
    end
    if BookUI.isOpen(player) and interactable and InteractableUI.isOpen(interactable) then
        BookUI.keypressed(key, player, interactable)
    elseif BookUI.isOpen(player) then
        BookUI.keypressed(key, player)
    elseif InteractableUI.isOpen(interactable) then
        InteractableUI.keypressed(key, interactable, player)
    end
end

function BookState.draw()
    BookUI.draw(player)
end

return BookState