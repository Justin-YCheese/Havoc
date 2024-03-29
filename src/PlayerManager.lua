--[[
PlayerManager.lua START

This file contains functions for modifying or checking player state
]]

-- Reset player states to what they would be like at the start of a new game
function resetPlayers()
  for _, color in pairs(PLAYER_COLOR_STRINGS) do
    players[color].backup = false
    players[color].betState = false
  end
end

-- Reset player bet states
function resetBetStates()
  for _, color in pairs(PLAYER_COLOR_STRINGS) do
    players[color].betState = false
  end
end

--[[
PlayerManager.lua END
]]
