wf = require 'libraries/windfield'
world = wf.newWorld(0, 0)

local State = require "states/State"
local Explore = require "states/Explore"

local ItemData = require "data/ItemData"

local BookUI = require "UI/BookUI"
local ChestUI = require "UI/ChestUI"
local ShopUI = require "UI/ShopUI"
local CommonUI = require "UI/CommonUI"

local Dialog = require "Dialog"

local Player = require "entities/Player"

local uiFont
local uiScale = 24

local function updateUI(winH)
    uiScale = math.max(12, math.floor(winH / 25))
    uiFont = love.graphics.newFont(uiScale)
    uiFont:setFilter("linear", "linear")
end



function love.load()

    love.graphics.setDefaultFilter("nearest", "nearest")
    local playerSpriteSheetPath = "images/character_14_frame16x20.png"

    local playerParams = {
        x = 350, y = 250, 
        hp = 25, speed = 50, 
        imagePath = playerSpriteSheetPath
    }

    player = Player.new(playerParams, 30, 0)

    local axe = ItemData.new("axe")
    axe:repair()
    player.inventory:add_item(axe, 0)
    
    
    BookUI.load()
    ChestUI.load()
    ShopUI.load()
    Dialog.load()

    updateUI(love.graphics.getHeight())
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
    Dialog.update(dt)
end


function love.resize(w, h)
    updateUI(h)
    DialogManager.viewportW = w
    DialogManager.viewportH = h
end

local function drawHeart(x, y, size)
    local r = size / 4

    love.graphics.circle("fill", x - r, y, r)
    love.graphics.circle("fill", x + r, y, r)

    love.graphics.polygon("fill", 
        x - size / 2, y + r * 0.3, 
        x + size / 2, y + r * 0.3, 
        x, y + size * 0.75
    )
end

function love.draw()
    State.draw()

    -------------------
    love.graphics.setFont(uiFont)
    love.graphics.setColor(0.9, 0.15, 0.2)
    
    local marginX = uiScale * 1
    local marginY = uiScale * 1
    local heartSize = uiScale * 0.9
    
    local heartX = marginX + (heartSize / 2)
    local heartY = marginY + (heartSize * 0.4)
    drawHeart(heartX, heartY, heartSize)
    
    local padding = uiScale * 0.4
    local textX = marginX + heartSize + padding
    local textY = marginY
    love.graphics.print(player.hp .. "/" .. player.maxHp, textX, textY)
    
    love.graphics.setColor(1, 1, 1)

    ---------------------
end