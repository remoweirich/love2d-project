local Inventory = require "inventory/inventory"

local PlayerInventory = {}
PlayerInventory.__index = PlayerInventory
setmetatable(PlayerInventory, { __index = Inventory})


function PlayerInventory.new(max_weight, money)
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
    setmetatable(instance, PlayerInventory)
    return instance
end

function PlayerInventory:add_item(item, cost)
    local prefix = string.sub(item.type, 1, 2)

    if item.base_weight + self.current_weight > self.max_weight then
        print("Item is too heavy to add to inventory")
        return
    end
    if self.money < cost then
        print("Item is too expensive, sell other items first!")
        return
    end

    if prefix == "c_" then
        for i=1,#self.items.consumables do
            if (self.items.consumables[i].type == item.type) and (self.items.consumables[i].name == item.name) then
                self.items.consumables[i] = self.items.consumables[i] + item

                self.current_weight = self.current_weight + item.base_weight
                self.money = self.money - cost

                return
            end
        end
        table.insert(self.items.consumables, item)
        self.current_weight = self.current_weight + item.base_weight
        self.money = self.money - cost

        
    elseif prefix == "i_" then
        table.insert(self.items.items, item)
        self.current_weight = self.current_weight + item.base_weight
        self.money = self.money - cost

    elseif prefix == "e_" then
        table.insert(self.items.equipment, item)
        self.current_weight = self.current_weight + item.base_weight
        self.money = self.money - cost

    elseif prefix == "w_" then
        table.insert(self.items.weapons, item)
        self.current_weight = self.current_weight + item.base_weight
        self.money = self.money - cost

    elseif prefix == "a_" then
        table.insert(self.items.armor, item)
        self.current_weight = self.current_weight + item.base_weight
        self.money = self.money - cost
    end
end

function PlayerInventory:remove_item(item, cost)
    local prefix = string.sub(item.type, 1, 2)

    if prefix == "c_" then
        local i = inv.find_index(item, self.items.consumables)
        self.items.consumables[i] = self.items.consumables[i] - 1
        if self.items.consumables[i].quantity <= 0 then
            table.remove(self.items.consumables, i)
        end

        self.current_weight = self.current_weight - item.base_weight
        self.money = self.money + cost
        
        return

    elseif prefix == "i_" then
        local i = inv.find_index(item, self.items.items)
        table.remove(self.items.items, i)
        self.current_weight = self.current_weight - item.base_weight
        self.money = self.money + cost

    elseif prefix == "e_" then
        local i = inv.find_index(item, self.items.equipment)
        table.remove(self.items.equipment, i)
        self.current_weight = self.current_weight - item.base_weight
        self.money = self.money + cost

    elseif prefix == "w_" then
        local i = inv.find_index(item, self.items.weapons)
        table.remove(self.items.weapons, i)
        self.current_weight = self.current_weight - item.base_weight
        self.money = self.money + cost

    elseif prefix == "a_" then
        local i = inv.find_index(item, self.items.armor)
        table.remove(self.items.armor, i)
        self.current_weight = self.current_weight - item.base_weight
        self.money = self.money + cost
    end
end

return PlayerInventory