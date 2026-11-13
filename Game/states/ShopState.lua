local State = require "states/State"
local DialogState = require "states/DialogState"
local BookState = require "states/BookState"

local ShopUI = require "UI/ShopUI"

local ShopState = { overlay = true }

function ShopState.enter(shop)
    ShopState.shop = shop
    ShopState.boughtSomething = false
    ShopUI.toggle(ShopState.shop)
end

function ShopState.keypressed(key)
    local shop = ShopState.shop
    if key == "e" and not ShopUI.hasPopup() then
        ShopUI.toggle(shop)
        State.pop()
        shop.dialog.outro(ShopState.boughtSomething)
        DialogManager:pop()
        State.push(DialogState)
        return
    end
    if ShopUI.keypressed(key, shop, player) then
        ShopState.boughtSomething = true
    end
    if key == "tab" then
        State.push(BookState, shop)
    end

end


function ShopState.draw()
    ShopUI.draw(ShopState.shop)
end

return ShopState