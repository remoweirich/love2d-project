local bgImage
local inventory = {
    startX = 120,   -- X position where slot (1,1) starts
    startY = 150,   -- Y position where slot (1,1) starts
    slotSize = 48,  -- Size of each slot box (48x48 px)
    spacing = 8,    -- Gap between slots
    cols = 5,
    rows = 4,
    slots = {}      -- 2D table holding item data
}

function loadInv()
    bgImage = love.graphics.newImage("images/inventory.png")

    -- Initialize an empty grid
    for r = 1, inventory.rows do
        inventory.slots[r] = {}
        for c = 1, inventory.cols do
            inventory.slots[r][c] = nil -- nil indicates an empty slot
        end
    end

    -- Add a test item at Row 1, Column 2
    inventory.slots[1][2] = { name = "Health Potion", id = "potion_hp" }
end

-- Convert grid index (col, row) -> screen coordinates (x, y)
local function getSlotScreenPos(col, row)
    local x = inventory.startX + (col - 1) * (inventory.slotSize + inventory.spacing)
    local y = inventory.startY + (row - 1) * (inventory.slotSize + inventory.spacing)
    return x, y
end

-- Convert mouse coordinates (mx, my) -> grid index (col, row)
local function getGridPosAt(mx, my)
    local col = math.floor((mx - inventory.startX) / (inventory.slotSize + inventory.spacing)) + 1
    local row = math.floor((my - inventory.startY) / (inventory.slotSize + inventory.spacing)) + 1

    if col >= 1 and col <= inventory.cols and row >= 1 and row <= inventory.rows then
        return col, row
    end
    return nil, nil -- Cursor is outside grid bounds
end

function drawInv()
    -- 1. Draw your inventory background artwork
    -- love.graphics.draw(bgImage, 100, 100)

    -- 2. Render items in their respective invisible grid slots
    for r = 1, inventory.rows do
        for c = 1, inventory.cols do
            local x, y = getSlotScreenPos(c, r)
            local item = inventory.slots[r][c]

            if item then
                -- Render item icon at slot position
                love.graphics.setColor(1, 0.2, 0.2, 1)
                love.graphics.rectangle("fill", x + 4, y + 4, inventory.slotSize - 8, inventory.slotSize - 8)
                love.graphics.setColor(1, 1, 1, 1)
            end
        end
    end

    -- 3. Highlight slot currently under the mouse
    local mx, my = love.mouse.getPosition()
    local col, row = getGridPosAt(mx, my)
    if col and row then
        local x, y = getSlotScreenPos(col, row)
        love.graphics.setColor(1, 1, 0, 0.3) -- Semi-transparent highlight
        love.graphics.rectangle("fill", x, y, inventory.slotSize, inventory.slotSize)
        love.graphics.setColor(1, 1, 1, 1)
    end
end