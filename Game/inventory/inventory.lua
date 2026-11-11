local inv = {}
inv.__index = inv
local allItems

local inventoryBg
local chestBg
local selectedIndex = 1
local inventoryOpen = false

-- local ui = {
--     inventoryOpen = false,
--     chest = nil
-- }

-- Alle Werte sind in Pixeln des ORIGINALBILDES (2400x1792)
local UNIT = 3 -- kleine Abstände waren für 800px gedacht -> x3

local baseLayout = {
    leftPage  = { startX = 255,  startY = 270, width = 810, itemHeight = 120 },
    rightPage = { startX = 1335, startY = 270, width = 810 }
}

function inv.new(max_weight, money)
    local instance = {
        current_weight = 0,
        max_weight = max_weight,
        items = {
            items = {},
            equipment = {},
            weapons = {},
            armor = {},
            consumables = {}
        },
        money = money
    }
    setmetatable(instance, inv)
    return instance
end

function inv.find_index(item, list)
    for i, v in ipairs(list) do
        if v == item then
            return i
        end
    end
    return nil
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

function inv:add_item(item)
    local prefix = string.sub(item.type, 1, 2)


    if prefix == "c_" then
        for i=1,#self.items.consumables do
            if (self.items.consumables[i].type == item.type) and (self.items.consumables[i].name == item.name) then
                self.items.consumables[i] = self.items.consumables[i] + item

                return
            end
        end
        table.insert(self.items.consumables, item)

        
    elseif prefix == "i_" then
        table.insert(self.items.items, item)

    elseif prefix == "e_" then
        table.insert(self.items.equipment, item)

    elseif prefix == "w_" then
        table.insert(self.items.weapons, item)

    elseif prefix == "a_" then
        table.insert(self.items.armor, item)
    end
end

function inv:remove_item(item)
    local prefix = string.sub(item.type, 1, 2)

    if prefix == "c_" then
        local i = find_index(item, self.items.consumables)
        self.items.consumables[i] = self.items.consumables[i] - 1
        if self.items.consumables[i].quantity <= 0 then
            table.remove(self.items.consumables, i)
        end
        
        return

    elseif prefix == "i_" then
        local i = find_index(item, self.items.items)
        table.remove(self.items.items, i)

    elseif prefix == "e_" then
        local i = find_index(item, self.items.equipment)
        table.remove(self.items.equipment, i)

    elseif prefix == "w_" then
        local i = find_index(item, self.items.weapons)
        table.remove(self.items.weapons, i)

    elseif prefix == "a_" then
        local i = find_index(item, self.items.armor)
        table.remove(self.items.armor, i)
    end
end


-- Schriftgrößen in Originalbild-Pixeln
local baseFontSize = { normal = 14 * UNIT, title = 20 * UNIT }

local icons = {
    { name = "Knight's Straight Sword", icon = "images/icons/KnightsStraightSword.png" },
    { name = "Great Health Potion", icon = "images/icons/GreatHealthPotion.png"},
    { name = "Executioner's Axe", icon = "images/icons/ExecutionersAxe.png"},
    { name = "Other Potion", icon = "images/icons/GreatHealthPotion.png"},

}

local fonts = {}
local lastScale = nil

local function updateFonts(scale)
    if scale == lastScale then return end
    lastScale = scale
    for name, size in pairs(baseFontSize) do
        local f = love.graphics.newFont(math.max(8, math.floor(size * scale + 0.5)))
        f:setFilter("linear", "linear")
        fonts[name] = f
    end
end

function inv.load()
    inventoryBg = love.graphics.newImage("images/inventory.png")
    chestBg = love.graphics.newImage("images/chestInv.png")
end

function inv.isOpen()
    return inventoryOpen
end

local function getTransform()
    local winW, winH = love.graphics.getWidth(), love.graphics.getHeight()
    local imgW, imgH = inventoryBg:getWidth(), inventoryBg:getHeight()

    local scale = (winH * 0.85) / imgH
    local bgX = math.floor((winW - imgW * scale) / 2)
    local bgY = math.floor((winH - imgH * scale) / 2)
    local w, h = imgW * scale, imgH * scale

    return bgX, bgY, scale, w, h
end

function inv.keypressed(key)
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

function inv.draw(myInv)
    love.graphics.setDefaultFilter("nearest", "nearest")
    if not inventoryOpen then return end

    local bgX, bgY, scale, invW, invH = getTransform()
    updateFonts(scale)

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


return inv