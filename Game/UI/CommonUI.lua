local CommonUI = {}

local chestBg

CommonUI.icons = {
    { name = "Knight's Straight Sword", icon = "images/icons/KnightsStraightSword.png" },
    { name = "Great Health Potion", icon = "images/icons/GreatHealthPotion.png"},
    { name = "Executioner's Axe", icon = "images/icons/ExecutionersAxe.png"},
    { name = "Other Potion", icon = "images/icons/GreatHealthPotion.png"},

}

CommonUI.fonts = {}
local lastScale = nil

function CommonUI.updateFonts(scale, baseFontSize)
    if scale == lastScale then return end
    lastScale = scale
    for name, size in pairs(baseFontSize) do
        local f = love.graphics.newFont(math.max(8, math.floor(size * scale + 0.5)))
        f:setFilter("linear", "linear")
        CommonUI.fonts[name] = f
    end
end

function CommonUI.getTransform(img)
    local winW, winH = love.graphics.getWidth(), love.graphics.getHeight()
    local imgW, imgH = img:getWidth(), img:getHeight()

    local scale = (winH * 0.85) / imgH
    local bgX = math.floor((winW - imgW * scale) / 2)
    local bgY = math.floor((winH - imgH * scale) / 2)
    local w, h = imgW * scale, imgH * scale

    return bgX, bgY, scale, w, h
end

return CommonUI