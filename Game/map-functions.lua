local mapTileW, mapTileH, mapTileset, mapQuads, mapTileTable

function newMap(tileW, tileH, tilesetPath, quadInfo, tileString)
    mapTileset = love.graphics.newImage(tilesetPath)

    mapTileW = tileW
    mapTileH = tileH

    local tilesetW, tilesetH = mapTileset:getWidth(), mapTileset:getHeight()

    mapQuads = {}
    for _, info in ipairs(quadInfo) do
        -- info[1] = x, info[2] = y
        mapQuads[info[1]] = love.graphics.newQuad(info[2], info[3], mapTileW, mapTileH, tilesetW, tilesetH)
    end

    mapTileTable = {}

    local width = #(tileString:match("[^\n]+"))

    for x=1, width, 1 do mapTileTable[x] = {} end

    local x, y = 1, 1
    for row in tileString:gmatch("[^\n]+") do
        assert(#row == width, "Map is not aligned: width of row " .. tostring(y) .. " should be " .. tostring(width) .. ", but is " .. tostring(#row))
        x = 1
        for character in row:gmatch(".") do
            mapTileTable[x][y] = character
            x = x + 1
        end
        y = y + 1
    end


end



------------------------------------------------------------------
---                         Seperator
------------------------------------------------------------------



function drawMap()
    for columnIndex, column in ipairs(mapTileTable) do
        for rowIndex, char in ipairs(column) do
            local x, y = (columnIndex-1)*mapTileW, (rowIndex-1)*mapTileH
            love.graphics.draw(mapTileset, mapQuads[char], x, y)
        end
    end

end


------------------------------------------------------------------
---                         Seperator
------------------------------------------------------------------


function loadMap(path)
    love.filesystem.load(path)()
end

