local UImanager = {}


local function nearestChest(range)
    for _, c in ipairs(chests) do
        local dx = (c.x + c.w/2) - player.x
        local dy = (c.y + c.h/2) - player.y
        if math.sqrt(dx*dx + dy*dy) < range then 
            return c 
            end
    end
end


function UImanager.keypressed(key)
    if not BookUI.isOpen() then
        if key == "e" then
            local c = nearestChest(25)
            ChestUI.toggle(c)
        end
    end
    if key == "tab" then
        BookUI.toggle()
    end
    if BookUI.isOpen() then
        BookUI.keypressed(key)
    end

end

return UImanager