wf = require 'libraries/windfield'
world = wf.newWorld(0, 0)

local State = require "states/State"
local Explore = require "states/Explore"

local ItemData = require "ItemData"
local PlayerInventory = require "inventory/PlayerInventory"

local UImanager = require "UI/UImanager"
local BookUI = require "UI/BookUI"
local ChestUI = require "UI/ChestUI"
local ShopUI = require "UI/ShopUI"

local Dialog = require "Dialog"

local Player = require "Player"

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    local playerSpriteSheetPath = "images/character_14_frame16x20.png"
    player = Player.new(350, 250, 50, playerSpriteSheetPath)
    player.inventory = PlayerInventory.new(30, 30)
    
    player.inventory:add_item(ItemData.sword, ItemData.sword.value)
    player.inventory:add_item(ItemData.potion, ItemData.potion.value)
    player.inventory:add_item(ItemData.potion, ItemData.potion.value)
    player.inventory:add_item(ItemData.potion2, ItemData.potion2.value)
    player.inventory:add_item(ItemData.axe, ItemData.axe.value)
    
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
    UImanager.update(dt)
    Dialog.update(dt)
end

function love.draw()
    State.draw()
end