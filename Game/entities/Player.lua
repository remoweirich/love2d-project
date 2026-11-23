local anim8 = require "libraries.anim8"

local Entity = require "entities/Entity"
local PlayerInventory = require "inventory/PlayerInventory"

local Player = {}
Player.__index = Player

setmetatable(Player, { __index = Entity })

Player.type = "Player"

function Player.new(params, max_weight, gold)
    local instance = Entity.new(params)
    instance.collider = world:newBSGRectangleCollider(params.x, params.y, 13, 11, 2.5)
    instance.spriteSheet = love.graphics.newImage(params.imagePath)
    instance.animations = {}
    instance.inventoryOpen = false
    instance.inventory = PlayerInventory.new(max_weight, gold)

    instance.grid = anim8.newGrid( 16, 20, instance.spriteSheet:getWidth(), instance.spriteSheet:getHeight() )
    instance.collider:setFixedRotation(true)
    instance.collider.w = 13
    instance.animations.down = anim8.newAnimation(instance.grid('1-3', 1), 0.2 )
    instance.animations.left = anim8.newAnimation(instance.grid('1-3', 2), 0.2 )
    instance.animations.right = anim8.newAnimation(instance.grid('1-3', 3), 0.2 )
    instance.animations.up = anim8.newAnimation(instance.grid('1-3', 4), 0.2 )
    instance.anim = instance.animations.down

    setmetatable(instance, Player)
    return instance

end

return Player