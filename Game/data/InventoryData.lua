local ItemData = require "data/ItemData"

local InventoryData = {}

InventoryData.chestTemplates = {
    c1 = { "dagger", "potion", "coin", "coin" },
    c2 = { "potion", "potion", "coin" },
    c3 = { "coin", "coin", "brittlebone"},
    c4 = { "dagger"}
}

InventoryData.shopTemplates = {
    s1 = { "sword", "axe", 
    "potion", "potion", "potion", "potion", "potion", "potion", "potion", "potion", "potion", "potion", "potion",
    "potion2", "potion2", "brittlebone", "brittlebone"
}
}

function InventoryData.new(key)
    if InventoryData.chestTemplates[key] then
        return InventoryData.chestTemplates[key]
    elseif InventoryData.shopTemplates[key] then
        return InventoryData.shopTemplates[key]
    end
end


return InventoryData