local CommonUI = require "UI/CommonUI"

local ChestUI = {}
local allItems

local inventoryBg
local selectedIndex = 1

local chests = {}

function ChestUI.putChest(chest)
    chest.inventoryOpen = false
    table.insert(chests, chest)
end

function ChestUI.getChests() 
    return chests
end


function ChestUI.load()
    inventoryBg = love.graphics.newImage("images/chestInv.png")
end

-- Alle Werte sind in Pixeln des ORIGINALBILDES (2400x1792)
local UNIT = 3 -- kleine Abstände waren für 800px gedacht -> x3

local baseLayout = {
    lid = { startX = 310, startY = 270, width = 1350 },
    body  = { startX = 310,  startY = 1250, width = 1350, itemHeight = 120 }
}


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


function ChestUI.isOpen()
    return inventoryOpen
end

function ChestUI.toggle()
    inventoryOpen = not inventoryOpen
end


function ChestUI.keypressed(key)
    if key == "tab" then
        inventoryOpen = not inventoryOpen
    end

    if inventoryOpen then
        if key == "down" then
            selectedIndex = math.min(selectedIndex + 1, math.max(1, #allItems))
        elseif key == "up" then
            selectedIndex = math.max(selectedIndex - 1, 1)
        end
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

function ChestUI.draw(myInv)
    if not inventoryOpen then return end
    love.graphics.setDefaultFilter("nearest", "nearest")

    local bgX, bgY, scale, invW, invH = CommonUI.getTransform(inventoryBg)
    CommonUI.updateFonts(scale, baseFontSize)

    allItems = getAllItems(myInv)

    -- "u" = eine Design-Einheit in Bildschirmpixeln (für kleine Abstände)
    local u = UNIT * scale

    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(inventoryBg, bgX, bgY, 0, scale, scale)

    -- Deckel
    local bodyX = bgX + baseLayout.body.startX * scale
    local bodyY = bgY + baseLayout.body.startY * scale
    local itemW = baseLayout.body.width * scale
    local itemH = baseLayout.body.itemHeight * scale

    -- love.graphics.setFont(fonts.title)
    -- love.graphics.setColor(0.2, 0.15, 0.1, 1)
    -- love.graphics.print("INVENTORY", bodyX + 100*u, bodyY - fonts.title:getHeight() - 6 * u)

    love.graphics.setFont(fonts.normal)
    for i, item in ipairs(allItems) do
        local itemY = bodyY + (i - 1) * itemH
        local rowH = itemH - 4 * u

        if i == selectedIndex then
            love.graphics.setColor(0.8, 0.65, 0.3, 0.35)
            love.graphics.rectangle("fill", bodyX, itemY, itemW, rowH)
            love.graphics.setColor(0.4, 0.25, 0.1, 0.8)
            love.graphics.rectangle("line", bodyX, itemY, itemW, rowH)
        end

        local iconSize = rowH - 8 * u
        love.graphics.setColor(0.3,0.2,0.1,0.3)
        love.graphics.rectangle("fill", bodyX + 4 * u, itemY + 4 * u, iconSize, iconSize)

        for _, tbl in ipairs(icons) do
            if tbl.name == item.name then
                local icn = love.graphics.newImage(tbl.icon)
                love.graphics.setColor(1,1,1,1)
                love.graphics.draw(icn, bodyX + 2*u, itemY+ 2*u, 0, 1/2.1*u, 1/2.1*u)
            end
        end
        love.graphics.setColor(0.3, 0.2, 0.1, 0.8)
        love.graphics.rectangle("line", bodyX + 4 * u, itemY + 4 * u, iconSize, iconSize)

        local textY = itemY + (rowH - fonts.normal:getHeight()) / 2
        love.graphics.setColor(0.2, 0.15, 0.1, 1)
        love.graphics.print(item:display(), bodyX + iconSize + 12 * u, textY)
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
    local slotString = "Space used: " .. myInv.slotsUsed .. "/" .. myInv.slots
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
        love.graphics.setColor(1, 1, 1, 1)
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

end


return ChestUI