local Inventory = require "inventory/inventory"

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
    ChestUI.putChest(instance)
    setmetatable(instance, ChestInventory)
    return instance
end



function ChestInventory:add_item(item)
    local prefix = string.sub(item.type, 1, 2)

    if self.slotsUsed + 1 > self.slots then
        print("Chest is full")
        return
    end

    if prefix == "c_" then
        for i=1,#self.items.consumables do
            if (self.items.consumables[i].type == item.type) and (self.items.consumables[i].name == item.name) then
                self.items.consumables[i] = self.items.consumables[i] + item

                return
            end
        end
        table.insert(self.items.consumables, item)
        self.slotsUsed = self.slotsUsed + 1
        
    elseif prefix == "i_" then
        table.insert(self.items.items, item)
        self.slotsUsed = self.slotsUsed + 1

    elseif prefix == "e_" then
        table.insert(self.items.equipment, item)
        self.slotsUsed = self.slotsUsed + 1

    elseif prefix == "w_" then
        table.insert(self.items.weapons, item)
        self.slotsUsed = self.slotsUsed + 1

    elseif prefix == "a_" then
        table.insert(self.items.armor, item)
        self.slotsUsed = self.slotsUsed + 1
    end
end



function ChestInventory:remove_item(item)
    local prefix = string.sub(item.type, 1, 2)

    if prefix == "c_" then
        local i = inv.find_index(item, self.items.consumables)
        self.items.consumables[i] = self.items.consumables[i] - 1
        if self.items.consumables[i].quantity <= 0 then
            table.remove(self.items.consumables, i)
            self.slotsUsed = self.slotsUsed - 1
        end

        self.slotsUsed = self.slotsUsed - 1
        
        return

    elseif prefix == "i_" then
        local i = inv.find_index(item, self.items.items)
        table.remove(self.items.items, i)
        self.slotsUsed = self.slotsUsed - 1

    elseif prefix == "e_" then
        local i = inv.find_index(item, self.items.equipment)
        table.remove(self.items.equipment, i)
        self.slotsUsed = self.slotsUsed - 1

    elseif prefix == "w_" then
        local i = inv.find_index(item, self.items.weapons)
        table.remove(self.items.weapons, i)
        self.slotsUsed = self.slotsUsed - 1

    elseif prefix == "a_" then
        local i = inv.find_index(item, self.items.armor)
        table.remove(self.items.armor, i)
        self.slotsUsed = self.slotsUsed - 1
    end
end

return ChestInventory