local Inventory = require "inventory/inventory"
local Item = require "inventory/Item"
local Equipment = require "inventory/Equipment"
local Weapon = require "inventory/Weapon"
local Consumable = require "inventory/Consumable"

local ChestInventory = {}
ChestInventory.__index = ChestInventory
setmetatable(ChestInventory, Inventory)

function ChestInventory.new(slots)
    local instance = {
        slots = slots,
        slotsUsed = 0,
        items = {
            items = {},
            equipment = {},
            weapons = {},
            armor = {},
            consumables = {}
        }
    }

    setmetatable(instance, ChestInventory)
    return instance
end



function ChestInventory:add_item(item)  
    local prefix = string.sub(item.type, 1, 2)

    if self.slotsUsed + 1 > self.slots then
        print("Chest is full")
        return false
    end

    if prefix == "c_" then
        for i=1,#self.items.consumables do
            if (self.items.consumables[i].type == item.type) and (self.items.consumables[i].name == item.name) then
                self.items.consumables[i] = self.items.consumables[i] + item

                return true
            end
        end
        local newPotion = Consumable.new(item.type, item.name, item.base_weight, item.value, item.effect, item.effectFn, item.me)
        table.insert(self.items.consumables, newPotion)
        self.slotsUsed = self.slotsUsed + 1
        
    elseif prefix == "i_" then
        local newItem = Item.new(item.type, item.name, item.base_weight, item.value)
        table.insert(self.items.items, newItem)
        self.slotsUsed = self.slotsUsed + 1

    elseif prefix == "e_" then
        local params = {
            type = item.type,
            name = item.name,
            base_weight = item.base_weight,
            value = item.value,
            durability = item.durability,
            max_durability = item.max_durability,
            stat_bonuses = item.stat_bonuses
        }
        local newEquipment = Equipment.new(params)
        table.insert(self.items.equipment, newEquipment)
        self.slotsUsed = self.slotsUsed + 1

    elseif prefix == "w_" then
        local params = {
            type = item.type,
            name = item.name,
            base_weight = item.base_weight,
            value = item.value,
            durability = item.durability,
            max_durability = item.max_durability,
            stat_bonuses = item.stat_bonuses,
            damage_type = item.damage_type
        }
        local newWeapon = Weapon.new(params)
        table.insert(self.items.weapons, newWeapon)
        self.slotsUsed = self.slotsUsed + 1

    elseif prefix == "a_" then
        table.insert(self.items.armor, item)
        self.slotsUsed = self.slotsUsed + 1
    end

    return true
end



function ChestInventory:remove_item(item)
    local prefix = string.sub(item.type, 1, 2)

    if prefix == "c_" then
        local i = Inventory.find_index(item, self.items.consumables)
        self.items.consumables[i] = self.items.consumables[i] - 1
        if self.items.consumables[i].quantity <= 0 then
            table.remove(self.items.consumables, i)
            self.slotsUsed = self.slotsUsed - 1
        end
        
        return

    elseif prefix == "i_" then
        local i = Inventory.find_index(item, self.items.items)
        table.remove(self.items.items, i)
        self.slotsUsed = self.slotsUsed - 1

    elseif prefix == "e_" then
        local i = Inventory.find_index(item, self.items.equipment)
        table.remove(self.items.equipment, i)
        self.slotsUsed = self.slotsUsed - 1

    elseif prefix == "w_" then
        local i = Inventory.find_index(item, self.items.weapons)
        table.remove(self.items.weapons, i)
        self.slotsUsed = self.slotsUsed - 1

    elseif prefix == "a_" then
        local i = Inventory.find_index(item, self.items.armor)
        table.remove(self.items.armor, i)
        self.slotsUsed = self.slotsUsed - 1
    end
end

return ChestInventory