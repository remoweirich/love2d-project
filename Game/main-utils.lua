local ChestState = require "states/ChestState"
local ShopState = require "states/ShopState"

local Utils = {}

function Utils.nearestInteractable(range, interactables)
    for _, i in ipairs(interactables) do
        local w
        if i.type == "Player" then
            w = i.collider.w
        elseif i.type == "Chest" then
            w = i.w
        end
        local dx = (i.x + w/2) - player.x
        local dy = (i.y + w/2) - player.y
        if math.sqrt(dx*dx + dy*dy) < range then
            return i
        end
    end
end

function Utils.whichState(interactable)
    if interactable.type == "Chest" then
        return ChestState
    elseif interactable.type == "Player" then
        return ShopState
    end
end


return Utils

