local CommonUI = require "UI/CommonUI"

local ChestUI = {}
local allItems

local confirm = nil

local message = nil

function ChestUI.hasPopup()
    return confirm ~= nil
end

local inventoryBg
local selectedIndex = 1


function ChestUI.load()
    inventoryBg = love.graphics.newImage("images/chestInv.png")
end

-- Alle Werte sind in Pixeln des ORIGINALBILDES (2400x1792)
local UNIT = 3 -- kleine Abstände waren für 800px gedacht -> x3

local baseLayout = {
    lid = { startX = 310, startY = 270, width = 1350 },
    body  = { startX = 310,  startY = 1250, width = 1350, cols = 4, cell = 150, gap = 10 }
}

local function slotRect(i, bodyX, bodyY, scale)
    local col = (i - 1) % baseLayout.body.cols
    local row = math.floor((i - 1) / baseLayout.body.cols)
    local step = (baseLayout.body.cell + baseLayout.body.gap) * scale
    return bodyX + col * step, bodyY + row * step, baseLayout.body.cell * scale
end


local function getAllItems(inventory)
    local catOrder = {"items", "equipment", "weapons", "armor", "consumables"}
    local items = {}
    for i, category in ipairs(catOrder) do
        for j, itm in ipairs(inventory.items[category]) do
            table.insert(items, itm)
        end
    end
    return items
end


-- Schriftgrößen in Originalbild-Pixeln
local baseFontSize = { normal = 21 * UNIT, title = 30 * UNIT, bigTitle = 30 * UNIT, small = 14 * UNIT }

local icons = CommonUI.icons

local fonts = CommonUI.fonts


function ChestUI.isOpen(chest)
    if chest then
        return chest.inventoryOpen
    end
end

function ChestUI.toggle(chest)
    chest.inventoryOpen = not chest.inventoryOpen
    message = nil
end


function ChestUI.keypressed(key, chest, playerInv)
    local cols = baseLayout.body.cols
    local maxSlot = chest.inventory.slots
    if chest.inventoryOpen then
        
        if confirm then
            if key == "left" or key == "right" then
                confirm.choice = (confirm.choice == 1) and 2 or 1
            elseif key == "return" or key == "kpenter" then
                if confirm.choice == 1 then
                    local ok, msg = playerInv:add_item(confirm.item, 0)
                    if ok then   -- 0 = kostenlos, passe das an deine Signatur an
                        chest.inventory:remove_item(confirm.item)
                    else
                        message = { text = msg, time = 2} 
                    end
                end
                confirm = nil
            elseif key == "escape" then
                confirm = nil
            end
            return
        end
        if key == "right" then selectedIndex = math.min(selectedIndex + 1, maxSlot)
        elseif key == "left" then selectedIndex = math.max(selectedIndex - 1, 1)
        elseif key == "down" then selectedIndex = math.min(selectedIndex + cols, maxSlot)
        elseif key == "up" then selectedIndex = math.max(selectedIndex - cols, 1) end

        if key == "return" or key == "kpenter" then
        local item = allItems[selectedIndex]
        if item then confirm = { item = item, choice = 1 } end
    end
    end
end

function ChestUI.update(dt)
    if message then
        message.time = message.time - dt
        if message.time <= 0 then message = nil end
    end
end


-- function inv.mousepressed(x, y, button)
--     if not inventoryOpen or button ~= 1 then return end

--     local bgX, bgY, scale = getTransform()
--     local leftX = bgX + baseLayout.leftPage.startX * scale
--     local leftY = bgY + baseLayout.leftPage.startY * scale
--     local itemW = baseLayout.leftPage.width * scale
--     local itemH = baseLayout.leftPage.itemHeight * scale

--     for i = 1, #myInv.items do
--         local itemY = leftY + (i - 1) * itemH
--         if x >= leftX and x <= leftX + itemW and y >= itemY and y < itemY + itemH then
--             selectedIndex = i
--             break
--         end
--     end
-- end

function ChestUI.draw(chest)
    if not chest.inventoryOpen then return end
    love.graphics.setDefaultFilter("nearest", "nearest")

    local bgX, bgY, scale, invW, invH = CommonUI.getTransform(inventoryBg)
    CommonUI.updateFonts(scale, baseFontSize)

    allItems = getAllItems(chest.inventory)

    -- "u" = eine Design-Einheit in Bildschirmpixeln (für kleine Abstände)
    local u = UNIT * scale

    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(inventoryBg, bgX, bgY, 0, scale, scale)

    -- Deckel
    local bodyX = bgX + baseLayout.body.startX * scale
    local bodyY = bgY + baseLayout.body.startY * scale


    love.graphics.setFont(fonts.normal)

    ---------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------
    -- Body
    ---------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------


    for i = 1, chest.inventory.slots do
        local x, y, size = slotRect(i, bodyX, bodyY, 2.15*scale)
        local item = allItems[i]   -- nil bei leerem Slot

        -- Slot-Hintergrund
        love.graphics.setColor(0.3, 0.2, 0.1, 0.3)
        love.graphics.rectangle("fill", x, y, size, size)

        -- Auswahl-Highlight
        if i == selectedIndex then
            love.graphics.setColor(0.8, 0.65, 0.3, 0.5)
            love.graphics.rectangle("fill", x, y, size, size)
        end

        -- Icon (nur wenn Item da)
        if item then
            for _, tbl in ipairs(icons) do
                if tbl.name == item.name then
                    local icn = love.graphics.newImage(tbl.icon)
                    local s = size / icn:getWidth()
                    love.graphics.setColor(1, 1, 1, 1)
                    love.graphics.draw(icn, x, y, 0, s, s)
                    if string.sub(item.type, 1, 2) == "c_" then
                        love.graphics.print(item.quantity .. "x", x, y)
                    end
                end
            end
        end

        love.graphics.setColor(0.3, 0.2, 0.1, 0.8)
        love.graphics.rectangle("line", x, y, size, size)
    end


    ---------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------
    -- Lid
    ---------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------
    
    local lidX = bgX + baseLayout.lid.startX * scale
    local lidY = bgY + baseLayout.lid.startY * scale
    local lidW = baseLayout.lid.width * scale

    love.graphics.setFont(fonts.small)
    love.graphics.setColor(1, 1, 1, 1)
    local slotString = "Space used: " .. chest.inventory.slotsUsed .. "/" .. chest.inventory.slots
    love.graphics.print(slotString, lidX+lidW-fonts.small:getWidth(slotString), lidY+ 196*u - fonts.small:getHeight())

    local sel = allItems[selectedIndex]

    if sel then
        local previewY = lidY + 5*u
        local previewSize = 95 * u
        love.graphics.setColor(0.5,0.3,0.3,0.5)
        love.graphics.rectangle("fill", lidX, previewY, previewSize, previewSize)

        for _, tbl in ipairs(icons) do
            if tbl.name == sel.name then
                local icn = love.graphics.newImage(tbl.icon)
                love.graphics.setColor(1,1,1,1)
                love.graphics.draw(icn, lidX + 2*u, previewY + 2*u, 0, 1.35*u, 1.35*u)
            end
        end
        love.graphics.setColor(0.3, 0.2, 0.1, 0.8)
        love.graphics.rectangle("line", lidX, previewY, previewSize, previewSize)

        
        local typeX = lidX + previewSize + 4 * u
        local typeY = previewY
        love.graphics.setFont(fonts.normal)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Type: " .. string.sub(sel.type, 3, #sel.type), typeX, typeY)
        sel:displayAfterType(typeX, typeY, u, fonts)
        
        local titleY = lidY
        love.graphics.setFont(fonts.title)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(sel.name, lidX, titleY - fonts.title:getHeight() - 6 * u)

        love.graphics.setFont(fonts.normal)
        local descY = titleY + fonts.normal:getHeight() + 95*u
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(sel:describe(), lidX, descY, lidW, "left")
    end

    ---------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------
    -- transfer
    ---------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------


    if confirm then
        local w, h = 800 * scale, 400 * scale
        local x = bgX + (invW - w) / 2
        local y = bgY + (invH - h) / 2

        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", bgX, bgY, invW, invH)       -- Hintergrund abdunkeln

        love.graphics.setColor(0.25, 0.17, 0.1, 1)
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(0.8, 0.65, 0.3, 1)
        love.graphics.rectangle("line", x, y, w, h)

        love.graphics.setFont(fonts.normal)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Move " .. confirm.item.name .. " to inventory?", x, y + 30*u, w, "center")

        local labels = { "Yes", "No" }
        for i, label in ipairs(labels) do
            local bx = x + w * (i == 1 and 0.15 or 0.55)
            local bw, bh = w * 0.3, 70 * scale
            local by = y + h - bh - 30*u
            if confirm.choice == i then
                love.graphics.setColor(0.8, 0.65, 0.3, 0.6)
                love.graphics.rectangle("fill", bx, by, bw, bh)
            end
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.rectangle("line", bx, by, bw, bh)
            love.graphics.printf(label, bx, by + (bh - fonts.normal:getHeight())/2, bw, "center")
        end
    end

    if message then
        love.graphics.setFont(fonts.normal)
        local w = fonts.normal:getWidth(message.text) + 20 * u
        local h = fonts.normal:getHeight() + 10 * u
        local x = bgX + (invW - w) / 2
        local y = bgY + invH - h - 20 * u

        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(1, 0.4, 0.4, 1)
        love.graphics.print(message.text, x + 10 * u, y + 5 * u)
    end
    love.graphics.setColor(1, 1, 1, 1)
end


return ChestUI