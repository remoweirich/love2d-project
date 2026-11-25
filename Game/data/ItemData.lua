local Item = require "inventory/Item"
local Equipment = require "inventory/Equipment"
local Weapon = require "inventory/Weapon"
local Consumable = require "inventory/Consumable"

local ItemData = {}

ItemData.templates = {
    sword = { class = "weapon", type="w_Sword", name = "Knight's Straight Sword",
              base_weight = 6, value = 8, durability = 76, max_durability = 125,
              stat_bonuses = {attack=10, defence=1}, damage_type = "Slashing" },
    axe   = { class = "weapon", type="w_Axe", name = "Executioner's Axe",
              base_weight = 12, value = 8, durability = 55, max_durability = 125,
              stat_bonuses = {attack=16, defence=0}, damage_type = "Slashing" },
    potion  = { class = "consumable", type = "c_Potion", name = "Great Health Potion",
                base_weight = 2, value = 4, effect = "Heal for 10 HP",
                effectFn = function(subject) subject:heal(10) end, me = true
            },
    potion2 = { class = "consumable", type = "c_Potion", name = "Other Potion",
                base_weight = 1, value = 3, effect = "Other effect",
                effectFn = function(subject) subject:takeDamage(10) end, me = false }
}

function ItemData.new(key)
    local tpl = ItemData.templates[key]
    if tpl.class == "weapon" then
        return Weapon.new(tpl)
    elseif tpl.class == "consumable" then
        return Consumable.new(tpl.type, tpl.name, tpl.base_weight, tpl.value, tpl.effect, tpl.effectFn, tpl.me)
    elseif tpl.class == "item" then
        return Item.new(tpl.type, tpl.name, tpl.base_weight, tpl.value)
    elseif tpl.class == "equipment" then
        return Equipment.new(tpl)
    end
end


return ItemData