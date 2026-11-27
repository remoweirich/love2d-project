local Enemy = require "entities/Enemy"

local EnemyData = {}

EnemyData.templates = {
    zombie = { 
        name = "Zombie", hp = 20, 
        attack = 5, defence = 1,
        speed = 20, goldDrop = 3,
        randomNoises = {
            "Grrrhhh", "Uurhhhhghg", "Rhhraaa", "grrruuhh",
        }
    },
    unarmed_skeleton = {
        name = "Unarmed Skeleton", hp = 13,
        attack = 7, defence = 0,
        speed = 35, goldDrop = 3,
        randomNoises = {
            "Clack-clack!", "*Rattle...*", "Creak-snap!", "*Teeth chattering*",
            "*Hollow knocking*", "Clatter-clack!", "*Dry bone scraping*"
        }
    },
    armed_skeleton = {
        name = "Armed Skeleton", hp = 13,
        attack = 15, defence = 2,
        speed = 35, goldDrop = 6,
        randomNoises = {
            "Clack-clack!", "*Rattle...*", "Creak-snap!", "*Teeth chattering*",
            "*Hollow knocking*", "Clatter-clack!", "*Dry bone scraping*"
        }
    },
    shielded_skeleton = {
        name = "Shielded Skeleton", hp = 13,
        attack = 15, defence = 8,
        speed = 30, goldDrop = 8,
        randomNoises = {
            "Clack-clack!", "*Rattle...*", "Creak-snap!", "*Teeth chattering*",
            "*Hollow knocking*", "Clatter-clack!", "*Dry bone scraping*"
        }
    }
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