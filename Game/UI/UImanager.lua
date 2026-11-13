local InteractableUI = require "UI/InteractableUI"
local Utils = require "main-utils"


local UImanager = {}
local activeInteractable = nil
local dialog = { active = false, onFinish = nil }

local boughtSomething = false 

function UImanager.startDialog(onFinish)
    dialog.active = true
    dialog.onFinish = onFinish
    CanMove = false
end

local function nearestInteractable(range)
    for _, i in ipairs(Utils.getInteractables()) do
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

function UImanager.keypressed(key)
    if dialog.active then
        local d = DialogManager:getActiveDialog()
        if key == "e" or key == "return" then
            if d and not d.done then DialogManager:complete()
            else DialogManager:pop() end
        elseif key == "down" then DialogManager:changeOption(1)
        elseif key == "up"   then DialogManager:changeOption(-1)
        end
        return
    end
    if activeInteractable and InteractableUI.hasPopup(activeInteractable) then
        InteractableUI.keypressed(key, activeInteractable, player)
        return
    end

    if not BookUI.isOpen(player) and key == "e" then
        if activeInteractable then
            InteractableUI.toggle(activeInteractable)
            if activeInteractable.dialog then
                UImanager.startDialog(function ()
                    activeInteractable = nil
                    CanMove = true
                    boughtSomething = false
                end)
                activeInteractable.dialog.outro(boughtSomething)
                DialogManager:pop()
            else
                activeInteractable = nil
                CanMove = true
                boughtSomething = false
            end
        else
            local i = nearestInteractable(20)
            if i then
                activeInteractable = i
                if activeInteractable.haveMet == false then
                    activeInteractable.dialog.introNotMet()
                    UImanager.startDialog(function() InteractableUI.toggle(i) end)
                    DialogManager:pop()
                    return
                elseif activeInteractable.haveMet then
                    activeInteractable.dialog.introMet()
                    UImanager.startDialog(function() InteractableUI.toggle(i) end)
                    DialogManager:pop()
                    return
                end
                InteractableUI.toggle(i)
                CanMove = false
            end
        end
        return
    end
    if key == "tab" then    
        BookUI.toggle(player)
    end

    if BookUI.isOpen(player) and InteractableUI.isOpen(activeInteractable) then
        BookUI.keypressed(key, player, activeInteractable)
    elseif BookUI.isOpen(player) then
        BookUI.keypressed(key, player)
    elseif InteractableUI.isOpen(activeInteractable) then
        InteractableUI.keypressed(key, activeInteractable, player)
    end
end

function UImanager.update(dt)
    if dialog.active and not Dialog.isRunning() then
        dialog.active = false
        local cb = dialog.onFinish
        dialog.onFinish = nil
        if cb then cb() end
    end
end

function UImanager.setBoughtSomething(bool)
    boughtSomething = bool
end

return UImanager