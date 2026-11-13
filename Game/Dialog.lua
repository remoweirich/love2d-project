Dialove = require "libraries/Dialove"

local Dialog = {}

function Dialog.load()
    DialogManager = Dialove.init({
    font = love.graphics.newFont("libraries/fonts/PressStart2P-Regular.ttf", 16), -- Optional: pass your custom LÖVE font
    viewportW = love.graphics.getWidth(), -- Optional: defaults to window width (set to canvas width if using a canvas)
    viewportH = love.graphics.getHeight(), -- Optional: defaults to window height
    typingVolume = 0.1 -- Optional: 0 to 1
  })
end


function Dialog.update(dt)
    DialogManager:update(dt)
end

function Dialog.draw()
    DialogManager:draw()
end

function Dialog.isRunning()
    if DialogManager:getActiveDialog() then return true end
    for _, list in pairs(DialogManager.activeDialogListMap) do
        if #list > 0 then return true end
    end
    return false
end

Dialog.shopkeeperDialog = { 
    introNotMet = function ()
        if not ShopKeeper.haveMet then
            DialogManager:push({
                title = "Shopkeeper Aphelton",
                text = "Hello there! I haven't seen you around here any time lately."
            })
            DialogManager:push({
                title = "Shopkeeper Aphelton",
                text = "Anyway, my name is Aphelton, I'm the shopkeeper around here. What's your name?",
                options = {
                    {
                        "Don't say your name",
                        function () DialogManager:show("Okay I guess...\n Well anyhow, how can i help you?") end
                    },
                    {
                        "Tell him your name",
                        function () DialogManager:show("Nice to meet you!\n How can I help you?") end
                    }
                }
            })
            ShopKeeper.haveMet = true
        end
    end,
    introMet = function ()
        DialogManager:push({
            title = "Shopkeeper Aphelton",
            text = Dialog.randomHello()
        })
    end,
    outro = function (bought)
        if bought then
            DialogManager:push({
                title = "Shopkeeper Aphelton",
                text = "Thanks for coming, be safe out there!"
            })
        else
            DialogManager:push({
                title = "Shopkeeper Aphelton",
                text = "Didn't buy anything? Well you know where to find me if you change your mind"
            })
        end
    end
}


function Dialog.randomHello()
    local texts = {
      "Hey, haven't we met before? Your face certainly looks familiar to me.\n How can I help you today?",
      "Hey buddy, how can I help you?",
      "Hi there, you wanna buy something?",
      "Nice to see you! I'm here to trade, buy or sell!",
      "Still alive huh? Maybe some stuff im selling can make staying alive easier",
      "Ahhh, I see some gold shining in your pockets, come on and spend some!",
      "Today I'm in the mood for spending some gold myself. Have you got something for me?"
    }
    return texts[love.math.random(1, #texts)]
  end


return Dialog