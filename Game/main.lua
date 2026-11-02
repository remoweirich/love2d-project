require("map-functions")


function love.load()
    loadMap("maps/chez-peter.lua")
    player = { x = 50, y = 50, speed = 3 }
end


function love.update(dt)
    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed
    end
    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed
    end
    if love.keyboard.isDown("s") then
        player.y = player.y + player.speed
    end
    if love.keyboard.isDown("w") then
        player.y = player.y - player.speed
    end
end


function love.draw()
    drawMap()
    love.graphics.circle("fill", player.x, player.y, 10)
end
