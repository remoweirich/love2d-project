local State = require "states/State"
local DialogState = require "states/DialogState"
local BookState = require "states/BookState"
local CombatState = require "states/CombatState"

local Utils = require "main-utils"

local sti = require "libraries/sti"

local camera = require 'libraries/camera'
local cam = camera()

local ItemData = require "data/ItemData"
local EnemyData = require "data/EnemyData"
local InventoryData = require "data/InventoryData"

local Player = require "entities/Player"

local Inventory = require "inventory/inventory"
local PlayerInventory = require "inventory/PlayerInventory"
local ChestInventory = require "inventory/ChestInventory"

local Dialog = require "Dialog"

local ChestUI = require "UI/ChestUI"

local Explore = { overlay = false}
local map
local walls, trees, plants, bushes, stones, chests = {}, {}, {}, {}, {}, {}
local interactables = {}
local enemies = {}
local npcs = {}
local mapChange = {}
local currentMapPath

local TRIGGER_RANGE = 30
local combatCooldown = 0


------------------------------------
------------------------------------
------------------------------------
local mapData = {}

local function setActive(list, active)
    for _, o in pairs(list) do o.collider:setActive(active) end
end

local function unloadMap()
    for _, list in ipairs({ walls, trees, plants, bushes, stones }) do
        for _, c in ipairs(list) do c:destroy() end
    end
    for _, d in ipairs(mapChange) do d.collider:destroy() end
    setActive(npcs, false)
    setActive(chests, false)
end

local function loadMap(path, spawnX, spawnY)
    unloadMap()
    currentMapPath = path
    map = sti(currentMapPath)
    walls, trees, plants, bushes, stones, mapChange = {}, {}, {}, {}, {}, {}

    if map.layers["Walls"] then
        for i, obj in pairs(map.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            table.insert(walls, wall)
        end
    end

    if map.layers["Trees"] then
        for i, obj in pairs(map.layers["Trees"].objects) do
            local tree = world:newRectangleCollider(obj.x, obj.y, obj.width/2, obj.height/1.5)
            tree:setType('static')
            table.insert(trees, tree)
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

    if map.layers["MapChange"] then
        for i, obj in pairs(map.layers["MapChange"].objects) do
            local mapPath = obj.properties.mapPath
            local spawnX = obj.properties.spawnX
            local spawnY = obj.properties.spawnY
            local newMap = { x = obj.x, y = obj.y, w = obj.width, mapPath = mapPath, spawnX = spawnX, spawnY = spawnY}
            newMap.collider = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            newMap.collider:setType('static')
            newMap.type = "MapChange"
            table.insert(mapChange, newMap)
            table.insert(interactables, newMap)
        end
    end


    if not mapData[path] then
        enemies, npcs, chests = {}, {}, {}

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

                local invTplKey = obj.properties.invTpl
                local invTpl = InventoryData.new(invTplKey)
                    for _, key in ipairs(invTpl) do
                        local newItem = ItemData.new(key)
                        chest.inventory:add_item(newItem)
                    end

                table.insert(chests, chest)
                table.insert(interactables, chest)
            end
        end

        -- local sword = ItemData.new("sword")
        -- local potion = ItemData.new("potion")
        -- local potion2 = ItemData.new("potion2")
        -- local axe = ItemData.new("axe")

        -- if chests[1] then
        --     chests[1].inventory:add_item(axe)
        --     chests[1].inventory:add_item(axe)
        --     chests[1].inventory:add_item(potion)
        --     chests[1].inventory:add_item(potion)
        --     print("Enemies geladen:", #enemies)
        -- end

        if map.layers["EnemyObj"] then
            for i, obj in pairs(map.layers["EnemyObj"].objects) do
                local key = obj.properties.enemyType
                local enemy = EnemyData.new(key, obj.x, obj.y)
                table.insert(enemies, enemy)
            end
        end


        if map.layers["NPC"] then
            for i, obj in pairs(map.layers["NPC"].objects) do
                local npcSpriteSheetPath = "images/character_1_frame16x20.png"
                local npcParams = {
                    x = obj.x, y = obj.y, 
                    hp = 100, speed = 0,
                    imagePath = npcSpriteSheetPath
                }
                if obj.properties.npcType == "Shop" then
                    local npc  = Player.new(npcParams, 100, 50) 
                    npc.name = obj.properties.npcName
                    npc.anim:gotoFrame(2)
                    npc.collider:setType("static")
                    npc.haveMet = false
                    npc.dialog = Dialog.shopkeeperDialog
                    
                    local invTplKey = obj.properties.invTpl
                    local invTpl = InventoryData.new(invTplKey)
                    for _, key in ipairs(invTpl) do
                        local newItem = ItemData.new(key)
                        npc.inventory:add_item(newItem, 0)
                    end
                    table.insert(interactables, npc)
                    table.insert(npcs, npc)
                end
                
            end
        end

        mapData[path] = { enemies = enemies, npcs = npcs, chests = chests }
    else
        local d = mapData[path]
        enemies, npcs, chests = d.enemies, d.npcs, d.chests
        setActive(npcs, true)
        setActive(chests, true)
    end
    
    interactables = {}
    for _, c in ipairs(chests) do table.insert(interactables, c) end
    for _, n in ipairs(npcs) do table.insert(interactables, n) end
    for _, d in ipairs(mapChange) do table.insert(interactables, d) end

    player.collider:setPosition(spawnX or 350, spawnY or 250)
    
end

------------------------------------
------------------------------------
------------------------------------

function Explore.enter(mapPath, spawnX, spawnY)
    loadMap(mapPath or "maps/test2.lua", spawnX, spawnY)
end


function Explore.exit()
    for _, c in ipairs(walls) do c:destroy() end
    for _, c in ipairs(plants) do c:destroy() end
    for _, c in ipairs(bushes) do c:destroy() end
    for _, c in ipairs(stones) do c:destroy() end
    for _, c in ipairs(chests) do c.collider:destroy() end
    for _, c in ipairs(npcs) do c.collider:destroy() end
    for _, c in ipairs(mapChange) do c.collider:destroy() end
    for _,c in ipairs(trees) do c:destroy() end
    chests = {}
    interactables = {}
    npcs = {}
    enemies = {}
    trees = {}
    -- if ShopKeeper then ShopKeeper.collider:destroy() end
    -- ShopKeeper = nil
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

    for _, npc in ipairs(npcs) do
        npc.x = npc.collider:getX()
        npc.y = npc.collider:getY()
    end

    for i, enemy in ipairs(enemies) do
        enemy.anim:update(dt)
        local dx = (enemy.x + 9) - player.x
        local dy = (enemy.y + 9) - player.y
        if math.sqrt(dx*dx + dy*dy) < TRIGGER_RANGE and combatCooldown == 0 then
            State.push(CombatState, enemy, function(result)
                if result == "won" then
                    table.remove(enemies, i)
                elseif result == "lost" then
                    State:push(LoseState)
                elseif result == "boss" then
                    State:push(WinState)
                elseif result == "fled" then
                    combatCooldown = 2
                end
            end)
            return
        end
    end
    if combatCooldown > 0 then
        combatCooldown = combatCooldown - dt
    else
        combatCooldown = 0
    end


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
    local scale = 1
    cam:attach()
        map:drawLayer(map.layers["Base Layer"])
        map:drawLayer(map.layers["Height 1"])
        map:drawLayer(map.layers["Test"])
        map:drawLayer(map.layers["Chests"])
        map:drawLayer(map.layers["Dungeon"])
        if currentMapPath == "maps/testCatacombs.lua" then
            scale = 1.25
        end
        for _, npc in ipairs(npcs) do
            npc.anim:draw(npc.spriteSheet, npc.x, npc.y, nil, scale, scale, 8, 14)
        end
        for _, enemy in ipairs(enemies) do
            enemy.anim:draw(enemy.spriteSheet, enemy.x+5, enemy.y+5, nil, scale*0.75, scale*0.75, 32, 32)
        end
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, scale, scale, 8, 14)
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
        local i = Utils.nearestInteractable(25, interactables)
        if not i then return end
        if i.haveMet == false then
            i.dialog.introNotMet(i)
            DialogManager:pop()
            State.push(DialogState, function () State.push(Utils.whichState(i), i) end)
        elseif i.haveMet then
            i.dialog.introMet(i)
            DialogManager:pop()
            State.push(DialogState, function () State.push(Utils.whichState(i), i) end)
        else
            if i.type == "MapChange" then
                loadMap(i.mapPath, i.spawnX, i.spawnY)
                return
            end
            State.push(Utils.whichState(i), i)
        end
    end
end

function Explore.getInteractables()
    return interactables
end


return Explore