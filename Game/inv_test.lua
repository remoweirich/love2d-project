local inv = {}

local inventoryOpen = false
local inventoryBg
local selectedIndex = 1

-- Alle Werte sind in Pixeln des ORIGINALBILDES (2400x1792)
local UNIT = 3 -- kleine Abstände waren für 800px gedacht -> x3

local baseLayout = {
    leftPage  = { startX = 255,  startY = 270, width = 810, itemHeight = 120 },
    rightPage = { startX = 1335, startY = 270, width = 810 }
}

-- Schriftgrößen in Originalbild-Pixeln
local baseFontSize = { normal = 14 * UNIT, title = 20 * UNIT }

local items = {
    { name = "Health Potion", count = 3, type = "Consumable", desc = "Restores 50 HP when consumed. Smells faintly of wild berries.", color = { 0.9, 0.2, 0.2 } },
    { name = "Forest Key",    count = 1, type = "Key Item",   desc = "An old iron key wrapped in thick vines. Opens the ruined gate.", color = { 0.9, 0.8, 0.2 } },
    { name = "Antidote",      count = 2, type = "Consumable", desc = "Cures poison instantly upon drinking.", color = { 0.2, 0.8, 0.3 } },
    { name = "Wooden Shield", count = 1, type = "Equipment",  desc = "A sturdy oak shield. Blocks incoming attacks from wild beasts.", color = { 0.6, 0.4, 0.2 } },
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

    return bgX, bgY, scale
end

function inv.keypressed(key)
    if key == "tab" then
        inventoryOpen = not inventoryOpen
    end

    if inventoryOpen then
        if key == "down" then
            selectedIndex = math.min(selectedIndex + 1, #items)
        elseif key == "up" then
            selectedIndex = math.max(selectedIndex - 1, 1)
        end
    end
end

function inv.mousepressed(x, y, button)
    if not inventoryOpen or button ~= 1 then return end

    local bgX, bgY, scale = getTransform()
    local leftX = bgX + baseLayout.leftPage.startX * scale
    local leftY = bgY + baseLayout.leftPage.startY * scale
    local itemW = baseLayout.leftPage.width * scale
    local itemH = baseLayout.leftPage.itemHeight * scale

    for i = 1, #items do
        local itemY = leftY + (i - 1) * itemH
        if x >= leftX and x <= leftX + itemW and y >= itemY and y < itemY + itemH then
            selectedIndex = i
            break
        end
    end
end

function inv.draw()
    if not inventoryOpen then return end

    local bgX, bgY, scale = getTransform()
    updateFonts(scale)

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
    for i, item in ipairs(items) do
        local itemY = leftY + (i - 1) * itemH
        local rowH = itemH - 4 * u

        if i == selectedIndex then
            love.graphics.setColor(0.8, 0.65, 0.3, 0.35)
            love.graphics.rectangle("fill", leftX, itemY, itemW, rowH)
            love.graphics.setColor(0.4, 0.25, 0.1, 0.8)
            love.graphics.rectangle("line", leftX, itemY, itemW, rowH)
        end

        local iconSize = rowH - 8 * u
        love.graphics.setColor(item.color)
        love.graphics.rectangle("fill", leftX + 4 * u, itemY + 4 * u, iconSize, iconSize)

        local textY = itemY + (rowH - fonts.normal:getHeight()) / 2
        love.graphics.setColor(0.2, 0.15, 0.1, 1)
        love.graphics.print(item.name .. " x" .. item.count, leftX + iconSize + 12 * u, textY)
    end

    -- RECHTE SEITE
    local rightX = bgX + baseLayout.rightPage.startX * scale
    local rightY = bgY + baseLayout.rightPage.startY * scale
    local rightW = baseLayout.rightPage.width * scale
    local sel = items[selectedIndex]

    if sel then
        love.graphics.setFont(fonts.title)
        love.graphics.setColor(0.25, 0.15, 0.1, 1)
        love.graphics.print(sel.name, rightX, rightY)

        local y = rightY + fonts.title:getHeight() + 4 * u
        love.graphics.setFont(fonts.normal)
        love.graphics.setColor(0.5, 0.4, 0.3, 1)
        love.graphics.print("Type: " .. sel.type, rightX, y)

        y = y + fonts.normal:getHeight() + 10 * u
        local previewSize = 50 * u
        love.graphics.setColor(sel.color)
        love.graphics.rectangle("fill", rightX, y, previewSize, previewSize)
        love.graphics.setColor(0.3, 0.2, 0.1, 0.8)
        love.graphics.rectangle("line", rightX, y, previewSize, previewSize)

        y = y + previewSize + 12 * u
        love.graphics.setColor(0.2, 0.15, 0.1, 1)
        love.graphics.printf(sel.desc, rightX, y, rightW, "left")
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return inv