local Enemy = require "entities/Enemy"

local EnemyData = {}

EnemyData.templates = {
    zombie = { 
        name = "Zombie", hp = 20, 
        attack = 5, defence = 1,
        speed = 20, goldDrop = 5,
        randomNoises = {
            "Grrrhhh", "Uurhhhhghg", "Rhhraaa", "grrruuhh",
        }
    },
}

function EnemyData.new(key, x, y)
    local tpl = EnemyData.templates[key]
    local instance = Enemy.new({
        name = tpl.name,
        x = x, y = y, hp = tpl.hp,
        attack = tpl.attack, defence = tpl.defence,
        speed = tpl.speed, goldDrop = tpl.goldDrop,
        randomNoises = tpl.randomNoises
    })
    return instance
end

function EnemyData.getRandomNoises(randomNoises)
    local num = love.math.random(1, #randomNoises)
    return randomNoises[num]
end

return EnemyData