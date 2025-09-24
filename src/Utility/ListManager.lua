--[[
ListManager.lua START

This file contains functions to help with handling lists
]]

-- Return true if the given value is in the list. False otherwise
function contains(list, value)
    for i = 1, #list do
        if list[i] == value then
            return true
        end
    end

    return false
end

-- Return a copy of the list without the given value
function copyWithException(list, excludeValue)
    local newList = {}

    for i = 1, #list do
        if list[i] ~= excludeValue then
            table.insert(newList, list[i])
        end
    end

    return newList
end

--[[
ListManager.lua END
]]
