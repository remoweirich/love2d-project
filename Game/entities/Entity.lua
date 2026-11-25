local Entity = {}

Entity.__index = Entity

function Entity.new(params)
    local instance = {
        x = params.x, y = params.y,
        hp = params.hp, maxHp = params.hp,
        speed = params.speed
    }

    return setmetatable(instance, Entity) 
end

function Entity:isAlive()
    return self.hp > 0
end
function Entity:heal(amount)
    self.hp = math.min(self.maxHp, self.hp + amount)
end

function Entity:takeDamage(amount)
    self.hp = math.max(0, self.hp - amount)
    -- return self:isAlive()
end

return Entity