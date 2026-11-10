local CommonUI = require "UI/CommonUI"

local BookUI = {}
local allItems

local inventoryBg
local selectedIndex = 1
local inventoryOpen = false

function BookUI.load()
    inventoryBg = love.graphics.newImage("images/inventory.png")
end

-- Alle Werte sind in Pixeln des ORIGINALBILDES (2400x1792)
local UNIT = 3 -- kleine Abstände waren für 800px gedacht -> x3

local baseLayout = {
    leftPage  = { startX = 255,  startY = 270, width = 810, itemHeight = 120 },
    rightPage = { startX = 1335, startY = 270, width = 810 }
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
local baseFontSize = { normal = 14 * UNIT, title = 20 * UNIT }

local icons = CommonUI.icons

local fonts = CommonUI.fonts


function BookUI.isOpen()
    return inventoryOpen
end

function BookUI.toggle()
    inventoryOpen = not inventoryOpen
end


function BookUI.keypressed(key)
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

function BookUI.draw(myInv)
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

    -- LINKE SEITE
    local leftX = bgX + baseLayout.leftPage.startX * scale
    local leftY = bgY + baseLayout.leftPage.startY * scale
    local itemW = baseLayout.leftPage.width * scale
    local itemH = baseLayout.leftPage.itemHeight * scale

    love.graphics.setFont(fonts.title)
    love.graphics.setColor(0.2, 0.15, 0.1, 1)
    love.graphics.print("INVENTORY", leftX, leftY - fonts.title:getHeight() - 6 * u)

    love.graphics.setFont(fonts.normal)
    for i, item in ipairs(allItems) do
        local itemY = leftY + (i - 1) * itemH
        local rowH = itemH - 4 * u

        if i == selectedIndex then
            love.graphics.setColor(0.8, 0.65, 0.3, 0.35)
            love.graphics.rectangle("fill", leftX, itemY, itemW, rowH)
            love.graphics.setColor(0.4, 0.25, 0.1, 0.8)
            love.graphics.rectangle("line", leftX, itemY, itemW, rowH)
        end

        local iconSize = rowH - 8 * u
        love.graphics.setColor(0.3,0.2,0.1,0.3)
        love.graphics.rectangle("fill", leftX + 4 * u, itemY + 4 * u, iconSize, iconSize)

        for _, tbl in ipairs(icons) do
            if tbl.name == item.name then
                local icn = love.graphics.newImage(tbl.icon)
                love.graphics.setColor(1,1,1,1)
                love.graphics.draw(icn, leftX + 2*u, itemY+ 2*u, 0, 1/2.1*u, 1/2.1*u)
            end
        end
        love.graphics.setColor(0.3, 0.2, 0.1, 0.8)
        love.graphics.rectangle("line", leftX + 4 * u, itemY + 4 * u, iconSize, iconSize)

        local textY = itemY + (rowH - fonts.normal:getHeight()) / 2
        love.graphics.setColor(0.2, 0.15, 0.1, 1)
        love.graphics.print(item:display(), leftX + iconSize + 12 * u, textY)
    end

    -- RECHTE SEITE
    local rightX = bgX + baseLayout.rightPage.startX * scale
    local rightY = bgY + baseLayout.rightPage.startY * scale
    local rightW = baseLayout.rightPage.width * scale

    love.graphics.setFont(fonts.normal)
    love.graphics.setColor(0.2, 0.15, 0.1, 1)
    love.graphics.print("Weight: " .. myInv.current_weight .. "/" .. myInv.max_weight, rightX, rightY - fonts.normal:getHeight() - 8 * u)
    local currentGold = myInv.money
    local wealthString = "Wealth: " .. tostring(currentGold) .. "G"
    local padLeft = leftX - bgX
    love.graphics.print(wealthString, bgX + invW - padLeft - fonts.normal:getWidth(wealthString), rightY - fonts.normal:getHeight() - 8 * u)

    local sel = allItems[selectedIndex]

    if sel then
        local previewY = rightY + 5*u
        local previewSize = 70 * u
        love.graphics.setColor(0.3,0.2,0.1,0.3)
        love.graphics.rectangle("fill", rightX, previewY, previewSize, previewSize)

        for _, tbl in ipairs(icons) do
            if tbl.name == sel.name then
                local icn = love.graphics.newImage(tbl.icon)
                love.graphics.setColor(1,1,1,1)
                love.graphics.draw(icn, rightX + 2*u, previewY + 2*u, 0, 1*u, 1*u)
            end
        end
        love.graphics.setColor(0.3, 0.2, 0.1, 0.8)
        love.graphics.rectangle("line", rightX, previewY, previewSize, previewSize)

        
        local typeX = rightX + previewSize + 4 * u
        local typeY = previewY
        love.graphics.setFont(fonts.normal)
        love.graphics.setColor(0.5, 0.4, 0.3, 1)
        love.graphics.print("Type: " .. string.sub(sel.type, 3, #sel.type), typeX, typeY)
        sel:displayAfterType(typeX, typeY, u, fonts)
        
        local titleY = previewY + previewSize + 3*u
        love.graphics.setFont(fonts.title)
        love.graphics.setColor(0.25, 0.15, 0.1, 1)
        love.graphics.print(sel.name, rightX, titleY)

        love.graphics.setFont(fonts.normal)
        local descY = titleY + fonts.title:getHeight() + u
        love.graphics.setColor(0.2, 0.15, 0.1, 1)
        love.graphics.printf(sel:describe(), rightX, descY, rightW, "left")
    end

    love.graphics.setColor(1, 1, 1, 1)
end


return BookUI