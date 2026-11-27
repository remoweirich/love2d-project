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
              base_weight = 12, value = 8, durability = 5, max_durability = 125,
              stat_bonuses = {attack=16, defence=0}, damage_type = "Slashing" },
    potion  = { class = "consumable", type = "c_Potion", name = "Great Health Potion",
                base_weight = 1, value = 4, effect = "Heal for 10 HP",
                effectFn = function(subject) subject:heal(10) end, me = true
            },
    potion2 = { class = "consumable", type = "c_Potion", name = "Charon's Kiss",
                base_weight = 0.5, value = 5, effect = "A sweet, lingering warmth—followed by the Ferryman’s cold hand pulling you into his boat",
                effectFn = function(subject) subject:takeDamage(10) end, me = false 
            },
    dagger = { class = "weapon", type = "w_Dagger", name = "Unsharp Dagger",
                base_weight = 2, value = 2, durability = 20, max_durability = 20,
                stat_bonuses = {attack = 4, defence = 0}, damage_type = "Slashing"
            },
    coin = { class = "consumable", type = "c_Coin", name = "Dirty Gold Coin",
             base_weight = 0, value = 1, effect = "Dirty, but nonetheless valuable",
             effectFn = function(subject) subject.inventory.money = subject.inventory.money + 1 end
            },
    brittlebone = { 
        class = "consumable", type = "c_Potion", name = "Brittle-Bone Brew",
        base_weight = 1, value = 5, effect = "Seeping into armor and marrow alike, leaving its victim fragile as dried twigs.",
        effectFn = function(subject) if subject.defence then subject.defence = subject.defence - 7 end end 
    }
    
            
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