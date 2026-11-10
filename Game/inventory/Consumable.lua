local Item = require "inventory/Item"

local Consumable = {}
Consumable.__index = Consumable
setmetatable(Consumable, {__index = Item})

function Consumable.new(type, name, base_weight, value, effect)
    local instance = {
        type = type, name = name,
        base_weight = base_weight,
        value = value,
        quantity = 1,
        effect = effect
    }
    setmetatable(instance, Consumable)
    return instance
end

function Consumable:describe()
    local printString = "Effect: " .. self.effect .. "\nWeight: " .. self.base_weight*self.quantity .. "kg\nValue: " .. self.value*self.quantity .. "G"
    return printString
end

function Consumable:displayAfterType(x, y, u, fonts)
    love.graphics.print("Amount:  " .. self.quantity, x, y + fonts.normal:getHeight() + u)
end

function Consumable:display()
    local printString = self.name .. " " .. self.quantity .. "x"
    return printString
end

Consumable.__add = function(c1, c2)
    if (c1.type == c2.type) and (c1.name == c2.name) then
        local quantity = c1.quantity + c2.quantity
        local new = Consumable.new(c1.type, c1.name, c1.base_weight, c1.value, c1.effect)
        new.quantity = quantity
        return new
    else
        print("Cannot stack these consumables")
    end
end

Consumable.__sub = function(c1, num)
    local quantity = c1.quantity - num
    local new = Consumable.new(c1.type, c1.name, c1.base_weight, c1.value, c1.effect)
    new.quantity = quantity
    return new
end

return Consumable
