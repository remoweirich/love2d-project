function love.load()
    wf = require 'libraries/windfield'
    world = wf.newWorld(0, 0)

    camera = require 'libraries/camera'
    cam = camera()
    -- cam.scale = cam.scale * 2.5

    anim8 = require "libraries.anim8"
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    sti = require "libraries/sti"
    gameMap = sti('maps/test2.lua')

    Inventory = require "inventory/inventory"
    PlayerInventory = require "inventory/PlayerInventory"
    ChestInventory = require "inventory/ChestInventory"

    UImanager = require "UI/UImanager"
    CommonUI = require "UI/CommonUI"
    BookUI = require "UI/BookUI"
    ChestUI = require "UI/ChestUI"
    

    player = { x = 50, y = 50, speed = 50 }
    player.collider = world:newBSGRectangleCollider(400, 250, 13, 11, 2.5)
    player.collider:setFixedRotation(true)
    player.spriteSheet = love.graphics.newImage("images/character_14_frame16x20.png")
    player.grid = anim8.newGrid( 16, 20, player.spriteSheet:getWidth(), player.spriteSheet:getHeight() )

    player.animations = {}
    player.animations.down = anim8.newAnimation(player.grid('1-3', 1), 0.2 )
    player.animations.left = anim8.newAnimation(player.grid('1-3', 2), 0.2 )
    player.animations.right = anim8.newAnimation(player.grid('1-3', 3), 0.2 )
    player.animations.up = anim8.newAnimation(player.grid('1-3', 4), 0.2 )

    player.anim = player.animations.left

    player.inventory = PlayerInventory.new(30, 30)

    c = ChestInventory.new(20)





    local Weapon = require "inventory/Weapon"
    local Sword = Weapon.new({
    type="w_Sword", name = "Knight's Straight Sword", 
    base_weight = 6, 
    value = 8, 
    durability = 76, 
    max_durability = 125, 
    stat_bonuses = {attack=10, defence=1},
    damage_type = "Slashing"
})
    player.inventory:add_item(Sword, Sword.value)

    local Consumable = require "inventory/Consumable"
    local potion = Consumable.new("c_Potion", "Great Health Potion", 2, 4, "Heal for 10 HP")
    player.inventory:add_item(potion, potion.value)
    player.inventory:add_item(potion, potion.value)
    local potion2 = Consumable.new("c_Potion", "Other Potion", 1, 4, "Something Else")
    player.inventory:add_item(potion2, potion2.value)

    
    local Axe = Weapon.new({
    type="w_Axe", name = "Executioner's Axe",
    base_weight = 12, 
    value = 8, 
    durability = 55, 
    max_durability = 125, 
    stat_bonuses = {attack=16, defence=0},
    damage_type = "Slashing"
})
    player.inventory:add_item(Axe, Axe.value)







    walls = {}
    if gameMap.layers["Walls"] then
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width/2, obj.height/1.5)
            wall:setType('static')
            table.insert(walls, wall)
        end
    end

    plants = {}
    if gameMap.layers["Plants"] then
        for i, obj in pairs(gameMap.layers["Plants"].objects) do
            local plant = world:newRectangleCollider(obj.x, obj.y, obj.width/3, obj.height/1.5)
            plant:setType('static')
            table.insert(plants, plant)
        end
    end

    bushes = {}
    if gameMap.layers["Bush"] then
        for i, obj in pairs(gameMap.layers["Bush"].objects) do
            local bush = world:newRectangleCollider(obj.x, obj.y, obj.width/1.15, obj.height/1.5)
            bush:setType('static')
            table.insert(bushes, bush)
        end
    end

    stones = {}
    if gameMap.layers["Stones"] then
        for i, obj in pairs(gameMap.layers["Stones"].objects) do
            local stone = world:newRectangleCollider(obj.x, obj.y, obj.width/1.5, obj.height/1.75)
            stone:setType('static')
            table.insert(stones, stone)
        end
    end

    chests = {}
    if gameMap.layers["ChestsObj"] then
        for i, obj in pairs(gameMap.layers["ChestsObj"].objects) do
            local chest = {
                x = obj.x, y = obj.y,
                w = obj.width, h = obj.height,
                inventory = Inventory.new(math.huge, math.huge)
            }
            chest.collider = world:newRectangleCollider(obj.x, obj.y, obj.width/1.1, obj.height/1.1)
            chest.collider:setType('static')
            chest.inventory = ChestInventory.new(5)
            table.insert(chests, chest)
        end
    end

    BookUI.load()
end

local function nearestChest(range)
    for _, c in ipairs(chests) do
        local dx = (c.x + c.w/2) - player.x
        local dy = (c.y + c.h/2) - player.y
        if math.sqrt(dx*dx + dy*dy) < range then 
            return c 
            end
    end
end

function love.keypressed(key)
    UImanager.keypressed(key)
    -- elseif key == "e" then
    --     local c = nearestChest(24)
    --     if c then
    --         Inventory.openChest(c.inventory)
    --     end
end

function love.update(dt)
    cam.scale = love.graphics.getHeight() / 230

    local isMoving = false

    local vx = 0
    local vy = 0

    if love.keyboard.isDown("d") then
        vx = player.speed
        player.anim = player.animations.right
        isMoving = true
    end
    if love.keyboard.isDown("a") then
        vx = player.speed * -1
        player.anim = player.animations.left
        isMoving = true
    end
    if love.keyboard.isDown("s") then
        vy = player.speed
        player.anim = player.animations.down
        isMoving = true
    end
    if love.keyboard.isDown("w") then
        vy = player.speed * -1
        player.anim = player.animations.up
        isMoving = true
    end

    player.collider:setLinearVelocity(vx, vy)

    if isMoving == false then
        player.anim:gotoFrame(2)
    end

    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()

    player.anim:update(dt)

    cam:lookAt(player.x+16/2, player.y + 20/2)

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    if cam.x < w/2/cam.scale then
        cam.x = w/2/cam.scale
    end
    if cam.y < h/2/cam.scale then
        cam.y = h/2/cam.scale
    end
    if cam.x > (mapW - w/2/cam.scale) then
        cam.x = (mapW - w/2/cam.scale)
    end
    if cam.y > (mapH - h/2/cam.scale) then
        cam.y = (mapH - h/2/cam.scale)
    end
end

function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Base Layer"])
        gameMap:drawLayer(gameMap.layers["Height 1"])
        gameMap:drawLayer(gameMap.layers["Test"])
        gameMap:drawLayer(gameMap.layers["Chests"])
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 1, 1, 8, 14)
        gameMap:drawLayer(gameMap.layers["Height 2"])
    cam:detach()

    BookUI.draw(player.inventory)
end