--[[
StringConverter.lua START

This file contains functions that the reset button triggers.
]]

function positionToString(position)
  return '['..position[1]..', '..position[2]..', '..position[3]..']'
end

function tableToString(table)
  local tableStr = ""
  local itemNum = 0

  for index, value in ipairs(table) do
    itemNum = itemNum + 1

    if itemNum > 1 then
      tableStr = tableStr .. ", "
    end

    tableStr = tableStr .. "[" .. index .. ", " .. value .. "]"
  end
end

--[[
StringConverter.lua END
]]
