local Item = {}
Item.__index = Item


function Item.new(type, name, base_weight, value)
    local instance = { 
        type = type, name = name, 
        base_weight = base_weight, 
        value = value, 
    }

    setmetatable(instance, Item)
    return instance
end

function Item:describe()
    local printString = "Weight: " .. self.base_weight .. "kg\nValue: " .. self.value .. "G"
    return printString
end

function Item:displayAfterType(x, y, u, fonts)
    return nil
end

function Item:sell(inv)
    print("There you go! " .. "(hands over " .. self.value .. " gold pieces)\n")
    inv:remove_item(self)

end

return Item