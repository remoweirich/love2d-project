local Entity = require "entities/Entity"

local Enemy = {}
Enemy.__index = Enemy
setmetatable(Enemy, { __index = Entity })

Enemy.type = "Enemy"

function Enemy.new(params)
    local instance = Entity.new(params)
    instance.name = params.name
    instance.attack = params.attack
    instance.defence = params.defence
    instance.goldDrop = params.goldDrop
    instance.randomNoises = params.randomNoises
    setmetatable(instance, Enemy)
    return instance
end


return Enemy