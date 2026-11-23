local State = require "states/State"
local Dialog = require "Dialog"
local EnemyData = require "data/EnemyData"

local CombatState = { overlay = false }

local function fleeChance(playerSpeed, enemySpeed)
    local diff = playerSpeed - enemySpeed
    local chance = 50 + diff * 1.75
    return math.max(15, math.min(85, chance))
end

local function weaponOptions()
    local opts = { { name = "Fists", stat_bonuses = { attack = 1, defence = 0 }, isFist = true } }
    for _, w in ipairs(player.inventory.items.weapons) do
        table.insert(opts, w)
    end
    return opts
end

local function itemOptions()
    return player.inventory.items.consumables
end

local function showMessage(text, afterFn)
    DialogManager:show(text)
    CombatState.afterMessage = afterFn
    CombatState.phase = "message"
end

function CombatState.enter(enemy, onFinish)
    CombatState.enemy = enemy
    CombatState.onFinish = onFinish
    CombatState.phase = "menu"
    CombatState.menuIndex = 1
    CombatState.menuOptions = { "Attack", "Items", "Flee" }
end

function CombatState.finish(result)
    State.pop()
    if CombatState.onFinish then CombatState.onFinish(result) end
end

local function enemyTurn()
    local enemy = CombatState.enemy
    showMessage(EnemyData.getRandomNoises(enemy.randomNoises))
    local dmg = math.max(1, enemy.attack - 0) -- player.defence msut be added
    player:takeDamage(dmg)
    showMessage(enemy.name .. " attacks for " .. dmg .. " damage!", function()
        if not player:isAlive() then
            showMessage("Your were defeated...", function() CombatState.finish("lost") end)
        else
            CombatState.phase = "menu"
        end
    end)
end

local function doAttack(weapon)
    local enemy = CombatState.enemy
    local atk = weapon.stat_bonuses and weapon.stat_bonuses.attack or 1
    local dmg = math.max(1, atk - enemy.defence)
    enemy:takeDamage(dmg)
    local broken = false
    local damage_type = "Bludgeoning"
    if not weapon.name == "Fists" then
        broken = weapon:use()
        damage_type = weapon.damage_type
    end
    showMessage("You attack with " .. weapon.name .. " for " .. dmg .. " " .. damage_type .. " damage!", function()
        if broken then showMessage("Your weapon got destroyed during the attack...") end
        if enemy.hp/enemy.maxHp <= 0.2 then
            showMessage(enemy.name .. " looks very hurt..")
        end
        if not enemy:isAlive() then
            player.inventory.money = player.inventory.money + (enemy.goldDrop or 0)
            showMessage("You defeated the " .. enemy.name .. "! Found " .. (enemy.goldDrop or 0) .. " gold.", function ()
                CombatState.finish("won") end)
        else
            enemyTurn()
        end
    end)
end

local function doItem(item)
    player.inventory:remove_item(item, 0)
    showMessage("You used " .. item.name .. ".", function ()
        enemyTurn()
    end)
end

local function doFlee()
    local enemy = CombatState.enemy
    local chance = fleeChance(player.speed, enemy.speed)
    if love.math.random(100) <= chance then
        showMessage("You got away!", function() CombatState.finish("fled") end)
    else
        showMessage("Couldn't escape..!", function() enemyTurn() end)
    end
end

function CombatState.keypressed(key)
    local phase = CombatState.phase

    if phase == "message" then
        local d = DialogManager:getActiveDialog()
        if key == "e" or key == "return" then
            if d and not d.done then DialogManager:complete()
            else
                local cb = CombatState.afterMessage
                CombatState.afterMessage = nil
                if cb then cb() end
            end
        end
        return
    end
    
    if phase == "menu" then
        if key == "down" or key == "s" then CombatState.menuIndex = (CombatState.menuIndex % #CombatState.menuOptions) + 1
        elseif key == "up" or key == "w" then CombatState.menuIndex = ((CombatState.menuIndex - 2) % #CombatState.menuOptions) + 1
        elseif key == "e" or key == "return" then
            local choice = CombatState.menuOptions[CombatState.menuIndex]
            if choice == "Attack" then
                CombatState.phase = "chooseAttack"
                CombatState.subOptions = weaponOptions()
                CombatState.subIndex = 1
            elseif choice == "Items" then
                CombatState.subOptions = itemOptions()
                if #CombatState.subOptions == 0 then
                    showMessage("You have no items.", function() CombatState.phase = "menu" end)
                else
                    CombatState.phase = "chooseItem"
                    CombatState.subIndex = 1
                end
            elseif choice == "Flee" then
                doFlee()
            end
        end
        return
    end

    if phase == "chooseAttack" or phase == "chooseItem" then
        local opts = CombatState.subOptions
        if key == "down" or key == "s" then CombatState.subIndex = (CombatState.subIndex % #opts) + 1
        elseif key == "up" or key == "w" then CombatState.subIndex = ((CombatState.subIndex - 2) % #opts) + 1
        elseif key == "escape" then CombatState.phase = "menu"
        elseif key == "e" or key == "return" then
            local selected = opts[CombatState.subIndex]
            if phase == "chooseAttack" then
                if selected.name ~= "Fists" and selected.durability <= 0 then
                    showMessage("Your weapon has been destroyed, repair it before using it again", function() CombatState.phase = "chooseAttack" end)
                else 
                    doAttack(selected)
                end
            else 
                doItem(selected) 
            end
        end
        return
    end

end

function CombatState.draw()
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    local enemy = CombatState.enemy
    love.graphics.setColor(0.6, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", 300, 100, 120, 120)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(enemy.name .. "  HP: " .. enemy.hp .. "/" .. enemy.maxHp, 300, 230)
    love.graphics.print("Your HP: " .. player.hp .. "/" .. player.maxHp, 20, 20)

    if CombatState.phase == "menu" then
        for i, opt in ipairs(CombatState.menuOptions) do
            local prefix = (i == CombatState.menuIndex) and "> " or " "
            love.graphics.print(prefix .. opt, 20, 300 + i * 20)
        end
    elseif CombatState.phase == "chooseAttack" or CombatState.phase == "chooseItem" then
        for i, opt in ipairs(CombatState.subOptions) do
            local prefix = (i == CombatState.subIndex) and "> " or " "
            local printstring = opt.name
            if opt.name ~= "Fists" then
                printstring = opt:display()
            end
            love.graphics.print(prefix .. printstring, 20, 300 + i*20)
        end
    end

    Dialog.draw()
end

return CombatState