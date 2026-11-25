wf = require 'libraries/windfield'
world = wf.newWorld(0, 0)

local State = require "states/State"
local Explore = require "states/Explore"

local ItemData = require "data/ItemData"

local UImanager = require "UI/UImanager"
local BookUI = require "UI/BookUI"
local ChestUI = require "UI/ChestUI"
local ShopUI = require "UI/ShopUI"
local CommonUI = require "UI/CommonUI"

local Dialog = require "Dialog"

local Player = require "entities/Player"


function love.load()

    love.graphics.setDefaultFilter("nearest", "nearest")
    local playerSpriteSheetPath = "images/character_14_frame16x20.png"

    local playerParams = {
        x = 350, y = 250, 
        hp = 25, speed = 50, 
        imagePath = playerSpriteSheetPath
    }

    player = Player.new(playerParams, 30, 30)
    
    local sword = ItemData.new("sword")
    local potion = ItemData.new("potion")
    local potion2 = ItemData.new("potion2")
    local axe = ItemData.new("axe")
    
    player.inventory:add_item(sword, sword.value)
    player.inventory:add_item(potion, potion.value)
    player.inventory:add_item(potion, potion.value)
    player.inventory:add_item(potion2, potion2.value)
    player.inventory:add_item(axe, axe.value)
    
    BookUI.load()
    ChestUI.load()
    ShopUI.load()
    Dialog.load()

    State.push(Explore, "maps/test2.lua", 350, 250)
end

function love.keypressed(key)
    State.keypressed(key)
end

function love.update(dt)
    State.update(dt)
    ChestUI.update(dt)
    ShopUI.update(dt)
    BookUI.update(dt)
    UImanager.update(dt)
    Dialog.update(dt)
end


function love.draw()
    State.draw()
end