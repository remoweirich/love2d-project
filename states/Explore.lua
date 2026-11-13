local State = require "states/State"
local DialogState = require "states/DialogState"
local BookState = require "states/BookState"

local Utils = require "main-utils"

local sti = require "libraries/sti"

local camera = require 'libraries/camera'
local cam = camera()

local ItemData = require "ItemData"

local Player = require "Player"

local Inventory = require "inventory/inventory"
local PlayerInventory = require "inventory/PlayerInventory"
local ChestInventory = require "inventory/ChestInventory"

local Dialog = require "Dialog"

local ChestUI = require "UI/ChestUI"

local Explore = { overlay = true}
local map
local walls, plants, bushes, stones, chests = {}, {}, {}, {}, {}
local interactables = {}

function Explore.enter(mapPath, spawnX, spawnY)
    mapPath = mapPath or "maps/test2.lua"
    map = sti(mapPath)

    interactables = {}
    walls, plants, bushes, stones, chests = {}, {}, {}, {}, {}

    player.collider:setPosition(spawnX or 350, spawnY or 250)
    
    
    if map.layers["Walls"] then
        for i, obj in pairs(map.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width/2, obj.height/1.5)
            wall:setType('static')
            table.insert(walls, wall)
        end
    end

    if map.layers["Plants"] then
        for i, obj in pairs(map.layers["Plants"].objects) do
            local plant = world:newRectangleCollider(obj.x, obj.y, obj.width/3, obj.height/1.5)
            plant:setType('static')
            table.insert(plants, plant)
        end
    end

    if map.layers["Bush"] then
        for i, obj in pairs(map.layers["Bush"].objects) do
            local bush = world:newRectangleCollider(obj.x, obj.y, obj.width/1.15, obj.height/1.5)
            bush:setType('static')
            table.insert(bushes, bush)
        end
    end

    if map.layers["Stones"] then
        for i, obj in pairs(map.layers["Stones"].objects) do
            local stone = world:newRectangleCollider(obj.x, obj.y, obj.width/1.5, obj.height/1.75)
            stone:setType('static')
            table.insert(stones, stone)
        end
    end

    if map.layers["ChestsObj"] then
        for i, obj in pairs(map.layers["ChestsObj"].objects) do
            local chest = {
                x = obj.x, y = obj.y,
                w = obj.width, h = obj.height,
                inventory = Inventory.new(math.huge, math.huge)
            }
            chest.collider = world:newRectangleCollider(obj.x, obj.y, obj.width/1.1, obj.height/1.1)
            chest.collider:setType('static')
            chest.inventory = ChestInventory.new(8)
            chest.inventoryOpen = false
            chest.type = "Chest"
            table.insert(chests, chest)
            table.insert(interactables, chest)
        end
    end

    if mapPath == "maps/test2.lua" then
        local shopKeeperSpriteSheetPath = "images/character_1_frame16x20.png"
        ShopKeeper = Player.new(400, 300, 0, shopKeeperSpriteSheetPath)
        ShopKeeper.inventory = PlayerInventory.new(100, 50)
        ShopKeeper.anim:gotoFrame(2)
        ShopKeeper.collider:setType("static")
        ShopKeeper.haveMet = false
        ShopKeeper.dialog = Dialog.shopkeeperDialog


        table.insert(interactables, ShopKeeper)
    end


    chests[1].inventory:add_item(ItemData.axe)
    chests[1].inventory:add_item(ItemData.potion)
    chests[1].inventory:add_item(ItemData.potion)
end


function Explore.exit()
    for _, c in ipairs(walls) do c:destroy() end
    for _, c in ipairs(plants) do c:destroy() end
    for _, c in ipairs(bushes) do c:destroy() end
    for _, c in ipairs(stones) do c:destroy() end
    for _, c in ipairs(chests) do c.collider:destroy() end
    chests = {}
    interactables = {}
    if ShopKeeper then ShopKeeper.collider:destroy() end
    ShopKeeper = nil
end



function Explore.update(dt)
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

    ShopKeeper.x = ShopKeeper.collider:getX()
    ShopKeeper.y = ShopKeeper.collider:getY()


    cam:lookAt(player.x+16/2, player.y + 20/2)

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    local mapW = map.width * map.tilewidth
    local mapH = map.height * map.tileheight

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

function Explore.draw()
    cam:attach()
        map:drawLayer(map.layers["Base Layer"])
        map:drawLayer(map.layers["Height 1"])
        map:drawLayer(map.layers["Test"])
        map:drawLayer(map.layers["Chests"])
        map:drawLayer(map.layers["Dungeon"])
        ShopKeeper.anim:draw(ShopKeeper.spriteSheet, ShopKeeper.x, ShopKeeper.y, nil, 1, 1, 8, 14)
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 1, 1, 8, 14)
        map:drawLayer(map.layers["Height 2"])
    cam:detach()

    for _, chest in ipairs(chests) do
        ChestUI.draw(chest)
    end
end

function Explore.keypressed(key)
    if key == "tab" then
        State.push(BookState)
        return
    end
    if key == "e" then
        local i = Utils.nearestInteractable(20, interactables)
        if not i then return end
        if i.haveMet == false then
            i.dialog.introNotMet()
            DialogManager:pop()
            State.push(DialogState, function () State.push(Utils.whichState(i), i) end)
        elseif i.haveMet then
            i.dialog.introMet()
            DialogManager:pop()
            State.push(DialogState, function () State.push(Utils.whichState(i), i) end)
        else
            State.push(Utils.whichState(i), i)
        end

    end
end

function Explore.getInteractables()
    return interactables
end


return Explore