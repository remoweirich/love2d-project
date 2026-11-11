local UImanager = {}
local activeChest = nil

local function nearestChest(range)
    for _, c in ipairs(Chests) do
        local dx = (c.x + c.w/2) - player.x
        local dy = (c.y + c.h/2) - player.y
        if math.sqrt(dx*dx + dy*dy) < range then 
            return c 
            end
    end
end


function UImanager.keypressed(key)
    if activeChest and ChestUI.hasPopup() then
        ChestUI.keypressed(key, activeChest, player.inventory)
        return
    end

    if not BookUI.isOpen() and key == "e" then
        if activeChest then
            ChestUI.toggle(activeChest)
            activeChest = nil
            CanMove = true
        else
            local c = nearestChest(20)
            if c then
                activeChest = c
                ChestUI.toggle(c)
                CanMove = false
            end
        end
    end
    if key == "tab" then    
        BookUI.toggle()
    end

    if BookUI.isOpen() and ChestUI.isOpen(activeChest) then
        BookUI.keypressed(key, player.inventory, activeChest)
    elseif BookUI.isOpen() then
        BookUI.keypressed(key)
    end
    if ChestUI.isOpen(activeChest) and (not BookUI.isOpen()) then
        ChestUI.keypressed(key, activeChest)
    end
end

return UImanager