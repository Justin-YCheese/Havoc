--[[
Validation.lua START

This file contains functions for checking the status or conditions of things.
]]
-- Check if player color is one of the actual player colors

function isInGameShortcutUsable(playerColor, shortcutName)
  return hasGameStarted(shortcutName) and isValidColor(playerColor, shortcutName)
end

function isValidColor(playerColor, shortcutName)
  if playerColor ~= 'Orange' and playerColor ~= 'Blue' then
    log(playerColor .. " player cannot use "..shortcutName.." shortcut")
    return false
  end

  return true
end

function hasGameStarted(shortcutName)
  if gameStarted == false then
    log(shortcutName.." shortcut is not allowed at this time")
    return false
  end

  return true
end

--[[
Validation.lua END
]]
