local State = require "states/State"
local Dialog = require "Dialog"
local EnemyData = require "data/EnemyData"
local CommonUI = require "UI/CommonUI"


local CombatState = { overlay = false }

local fonts = CommonUI.fonts

local BASE_W, BASE_H = 800, 450

local ENEMY_BOX = { x = 400, y = 99, w = 64, h = 64 }

local function getTransform()
    local winW, winH = love.graphics.getWidth(), love.graphics.getHeight()
    local scale = math.min(winW / BASE_W, winH / BASE_H)
    local offX = (winW - BASE_W * scale) / 2
    local offY = (winH - BASE_H * scale) / 2
    return offX, offY, scale
end

local function X(offX, scale, x) return offX + x * scale end
local function Y(offY, scale, y) return offY + y * scale end
local function S(scale, s) return s * scale end


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
    CombatState.afterMessage = afterFn
    CombatState.phase = "message"
    DialogManager:push(text)
    local d = DialogManager:getActiveDialog()
    DialogManager:pop()
end


function CombatState.finish(result)
    State.pop()
    if CombatState.onFinish then CombatState.onFinish(result) end
end

local function hitSubject(dmg, subject, item)
    if subject ~= player then
        if item then
            item:use(subject)
        else
            subject:takeDamage(dmg)
        end
        CombatState.enemyHitTimer = 0.3
    else
        subject:takeDamage(dmg)
        CombatState.playerHitTimer = 0.3
    end
end


local function enemyTurn()
    local enemy = CombatState.enemy
    showMessage(EnemyData.getRandomNoises(enemy.randomNoises))
    local dmg = math.max(1, enemy.attack - 0) -- player.defence msut be added
    showMessage(enemy.name .. " attacks for " .. dmg .. " damage!", function()
        CombatState.enemyAttackedTimer = 1
        enemy.anim = enemy.animations.attack
        enemy.spriteSheet = enemy.attackSheet
        enemy.anim:gotoFrame(1)
        enemy.anim:resume()

        hitSubject(dmg, player)
        if not player:isAlive() then
            showMessage("Your were defeated...", function() CombatState.finish("lost") end)
        else
            CombatState.phase = "menu"
        end
    end)
end

function CombatState.enter(enemy, onFinish)
    showMessage("You are attacked by a " .. enemy.name)
    CombatState.enemy = enemy
    CombatState.onFinish = onFinish
    CombatState.phase = "menu"
    CombatState.menuIndex = 1
    CombatState.menuOptions = { "Attack", "Items", "Flee" }

    if enemy.speed > player.speed then
        enemyTurn()
    end
end

local function doAttack(weapon)
    local enemy = CombatState.enemy
    local atk = weapon.stat_bonuses and weapon.stat_bonuses.attack or 1
    local dmg = math.max(1, atk - enemy.defence)
    hitSubject(dmg, enemy)
    local broken = false
    local damage_type = "Bludgeoning"
    if weapon.name ~= "Fists" then
        broken = weapon:use()
        print(weapon:display())
        damage_type = weapon.damage_type
    end
    showMessage("You attack with " .. weapon.name .. " for " .. dmg .. " " .. damage_type .. " damage!", function()
        if broken then showMessage("Your weapon got destroyed during the attack...") end
        if (enemy.hp > 0) and (enemy.hp/enemy.maxHp <= 0.2) then
            showMessage(enemy.name .. " looks very hurt..")
        end
        if not enemy:isAlive() then
            -- enemyDies()
            player.inventory.money = player.inventory.money + (enemy.goldDrop or 0)
            showMessage("You defeated the " .. enemy.name .. "! Found " .. (enemy.goldDrop or 0) .. " gold.", function ()
                CombatState.finish("won") end)
        else
            enemyTurn()
        end
    end)
end

local function doItem(item)
    local enemy = CombatState.enemy
    if item.me then
        item:use(player)
        player.inventory:remove_item(item, 0)
        showMessage("You feel warm inside... Effect: " .. item.effect, function ()
            enemyTurn()
        end)
    else
        hitSubject(nil, enemy, item)
        player.inventory:remove_item(item, 0)
        showMessage("You threw " .. item.name .. " on " .. enemy.name .. "... Effect: " .. item.effect)
        if (enemy.hp > 0) and (enemy.hp/enemy.maxHp <= 0.2) then
            showMessage(enemy.name .. " looks very hurt..")
        end
        if not enemy:isAlive() then
            -- enemyDies()

            player.inventory.money = player.inventory.money + (enemy.goldDrop or 0)
            showMessage("You defeated the " .. enemy.name .. "! Found " .. (enemy.goldDrop or 0) .. " gold.", function ()
                CombatState.finish("won") end)
        else
            enemyTurn()
        end
    end
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
                DialogManager:pop()
                if not DialogManager:getActiveDialog() then
                    local cb = CombatState.afterMessage
                    CombatState.afterMessage = nil
                    if cb then cb() end
                end
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


function CombatState.update(dt)

    if CombatState.enemyHitTimer and CombatState.enemyHitTimer > 0 then
        CombatState.enemyHitTimer = CombatState.enemyHitTimer - dt
    end
    if CombatState.playerHitTimer and CombatState.playerHitTimer > 0 then
        CombatState.playerHitTimer = CombatState.playerHitTimer - dt
    end

    if CombatState.enemyAttackedTimer and CombatState.enemyAttackedTimer > 0 then
        CombatState.enemyAttackedTimer = CombatState.enemyAttackedTimer - dt
        if CombatState.enemyAttackedTimer <= 0 then
            CombatState.enemy.anim = CombatState.enemy.animations.idle
            CombatState.enemy.spriteSheet = CombatState.enemy.idleSheet
            CombatState.enemy.anim:gotoFrame(1)
        end
    end

    CombatState.enemy.anim:update(dt)
end

local baseFontSize = { normal = 20, title = 28, small = 14, enemyLabel = 12 }

function CombatState.draw()
    local offX, offY, scale = getTransform()
    CommonUI.updateFonts(scale, baseFontSize)
    
    local enemy = CombatState.enemy
    
    local plFlashAmount = 0
    if CombatState.playerHitTimer and CombatState.playerHitTimer > 0 then
        local t = CombatState.playerHitTimer / 0.3
        plFlashAmount = t
    end

    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(
        0.1 + plFlashAmount*0.9,
        0.1 * (1-plFlashAmount),
        0.1 * (1-plFlashAmount),
        1
    )
    love.graphics.setLineWidth(8)
    love.graphics.rectangle("line", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setLineWidth(1)
    
    

    local shakeX, flashAmount = 0, 0
    if CombatState.enemyHitTimer and CombatState.enemyHitTimer > 0 then
        local t = CombatState.enemyHitTimer / 0.3
        shakeX = math.sin(t * math.pi * 8) * 6 * t
        flashAmount = t
    end

    -- temporary enemy-box
    love.graphics.setColor(
        0.9 + flashAmount * 0.1,
        0.9 * (1-flashAmount),
        0.9 * (1-flashAmount),
        1
    )
    if enemy.hp <= 0 then
        love.graphics.setColor(1, 1, 1, 1)
        enemy.spriteSheet = enemy.deadSheet
        enemy.anim = enemy.animations.dead
    end

    local drawX = X(offX, scale, ENEMY_BOX.x + shakeX)
    local drawY = Y(offY, scale, ENEMY_BOX.y)

    enemy.anim:draw(enemy.spriteSheet, drawX, drawY, 0, 4*scale, 4*scale, 32, 32)
    
    -- enemy hp
    local labelGap = 6
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(fonts.enemyLabel)
    local printString = enemy.name .. "  HP: " .. enemy.hp .. "/" .. enemy.maxHp
    love.graphics.print(printString, (love.graphics.getWidth()-fonts.enemyLabel:getWidth(printString))/2, Y(offY, scale, ENEMY_BOX.y + ENEMY_BOX.h + 2*labelGap)
    )

    love.graphics.setFont(fonts.small)

    if CombatState.phase == "menu" then
        for i, opt in ipairs(CombatState.menuOptions) do
            local prefix = (i == CombatState.menuIndex) and "> " or "  "
            love.graphics.print(
                prefix .. opt,
                X(offX, scale, 20), Y(offY, scale, 300 + i * 20)
            )
        end
    elseif CombatState.phase == "chooseAttack" or CombatState.phase == "chooseItem" then
        for i, opt in ipairs(CombatState.subOptions) do
            local prefix = (i == CombatState.subIndex) and "> " or "  "
            local printstring = opt.name
            if opt.name ~= "Fists" then
                printstring = opt:display()
            end
            love.graphics.print(
                prefix .. printstring,
                X(offX, scale, 20), Y(offY, scale, 300 + i * 20)
            )
        end
    end

    Dialog.draw()
end

return CombatState