local Entity = require "entities/Entity"
local anim8 = require "libraries.anim8"

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
    instance.idleSheet = love.graphics.newImage("images/enemies/" .. params.name .. ".png")
    instance.spriteSheet = instance.idleSheet
    instance.attackSheet = love.graphics.newImage("images/enemies/" .. params.name .. "_Attack.png")
    instance.deadSheet = love.graphics.newImage("images/enemies/" .. params.name .. "_Dead.png")


    instance.animations = {}
    instance.grid = anim8.newGrid( 64, 64, instance.spriteSheet:getWidth(), instance.spriteSheet:getHeight())
    instance.animations.idle = anim8.newAnimation(instance.grid('1-6', 1), 0.2)
    instance.animations.attack = anim8.newAnimation(instance.grid('1-6', 1), 0.1, 'pauseAtEnd')
    instance.animations.dead = anim8.newAnimation(instance.grid('1-6', 1), 0.2, 'pauseAtEnd')
    instance.anim = instance.animations.idle
    
    
    
    setmetatable(instance, Enemy)
    return instance
end


return Enemy