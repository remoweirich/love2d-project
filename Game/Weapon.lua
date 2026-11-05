local Item = require "Item"
local Equipment = require "Equipment"

local Weapon = {}
Weapon.__index = Weapon
setmetatable(Weapon, {__index = Equipment})

function Weapon.new(params)
    params = params or {}
    if not next(params) then
        print("Invalid arguments, Equipment could not be created")
        return
    end
    local instance = {}
    instance.type = params.type
    instance.name = params.name
    instance.base_weight = params.base_weight
    instance.value = params.value or 0
    instance.durability = params.durability
    instance.max_durability = params.max_durability
    instance.stat_bonuses = params.stat_bonuses or {attack = 0, defence = 0}
    instance.damage_type = params.damage_type
    setmetatable(instance, Weapon)
    return instance
end

function Weapon:describe()
    local printString = "Durability: " .. self.durability .. "/" .. self.max_durability .. "\nWeight: " .. self.base_weight .. "kg\nValue: " .. self.value .. "G)"
    return printString
end

function Weapon:display()
    local printString = self.name .. " " .. self.durability .. "/" .. self.max_durability
    return printString
end

function Weapon:displayAfterType(x, y, u, fonts)
    love.graphics.print("Dmg:  " .. self.damage_type, x, y + fonts.normal:getHeight() + u)
    love.graphics.print("Att: +" .. self.stat_bonuses.attack, x, y + 2*(fonts.normal:getHeight() + u))
    love.graphics.print("Def: +" .. self.stat_bonuses.defence, x, y + 3*(fonts.normal:getHeight() + u))
end

return Weapon