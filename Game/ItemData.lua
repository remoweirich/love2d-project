local Weapon = require "inventory/Weapon"
local Consumable = require "inventory/Consumable"

local ItemData = {}

ItemData.sword = Weapon.new({
        type="w_Sword", name = "Knight's Straight Sword", 
        base_weight = 6, 
        value = 8, 
        durability = 76, 
        max_durability = 125, 
        stat_bonuses = {attack=10, defence=1},
        damage_type = "Slashing"
    })

ItemData.axe = Weapon.new({
        type="w_Axe", name = "Executioner's Axe",
        base_weight = 12, 
        value = 8, 
        durability = 55, 
        max_durability = 125, 
        stat_bonuses = {attack=16, defence=0},
        damage_type = "Slashing"
    })

ItemData.potion = Consumable.new("c_Potion", "Great Health Potion", 2, 4, "Heal for 10 HP")

ItemData.potion2 = Consumable.new("c_Potion", "Other Potion", 1, 4, "Something Else")

return ItemData