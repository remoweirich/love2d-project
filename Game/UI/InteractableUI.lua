local InteractableUI = {}


function InteractableUI.isOpen(interactable)
    if interactable then
        if interactable.type == "Player" then
            return ShopUI.isOpen(interactable)
        elseif interactable.type == "Chest" then
            return ChestUI.isOpen(interactable)
        end
    end
end

function InteractableUI.toggle(interactable)
    if interactable.type == "Player" then
        ShopUI.toggle(interactable)
    elseif interactable.type == "Chest" then
        ChestUI.toggle(interactable)
    end
end

function InteractableUI.hasPopup(interactable)
    if interactable.type == "Player" then
        return ShopUI.hasPopup()
    elseif interactable.type == "Chest" then
        return ChestUI.hasPopup()
    end
end

function InteractableUI.keypressed(key, interactable, person)
    if interactable.type == "Player" then
        ShopUI.keypressed(key, interactable, person)
    elseif interactable.type == "Chest" then
        ChestUI.keypressed(key, interactable, person)

    end
end


return InteractableUI