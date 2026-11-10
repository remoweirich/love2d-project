local Item = require "inventory/Item"


local Equipment = {}
Equipment.__index = Equipment
setmetatable(Equipment, {__index = Item})

function Equipment.new(params)
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
    setmetatable(instance, Equipment)
    return instance
end

function Equipment:describe()
    local printString = "Durability: " .. self.durability .. "/" .. self.max_durability .. "\nWeight: " .. self.base_weight .. "kg\nValue: " .. self.value .. "G"
    return printString
end

function Equipment:display()
    local printString = self.name .. " " .. self.durability .. "/" .. self.max_durability
    return printString
end

function Equipment:displayAfterType(x, y, u, fonts)
    love.graphics.print("Att: +" .. self.stat_bonuses.attack, x, y + 2*(fonts.normal:getHeight() + u))
    love.graphics.print("Def: +" .. self.stat_bonuses.defence, x, y + 3*(fonts.normal:getHeight() + u))
end

function Equipment:use()
    self.durability = self.durability - 1
    -- maybe do debuff if durability lower than some number, also maybe name change
    if self.durability <= 0 then
        print(self.name .. "broke..")
    end
end

function Equipment:repair()
    self.durability = self.max_durability
    print("Here you go, weapon repaired!")
end

return Equipment