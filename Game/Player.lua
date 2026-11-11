

local Player = {}

function Player.new(x, y, speed, imagePath)
    local instance = {
        x = x, y = y,
        speed = speed,
        collider = world:newBSGRectangleCollider(x, y, 13, 11, 2.5),
        spriteSheet = love.graphics.newImage(imagePath),
        animations = {}
    }
    instance.grid = anim8.newGrid( 16, 20, instance.spriteSheet:getWidth(), instance.spriteSheet:getHeight() )
    instance.collider:setFixedRotation(true)
    instance.animations.down = anim8.newAnimation(instance.grid('1-3', 1), 0.2 )
    instance.animations.left = anim8.newAnimation(instance.grid('1-3', 2), 0.2 )
    instance.animations.right = anim8.newAnimation(instance.grid('1-3', 3), 0.2 )
    instance.animations.up = anim8.newAnimation(instance.grid('1-3', 4), 0.2 )
    instance.anim = instance.animations.down

    return instance

end

return Player