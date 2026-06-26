--[[
BettedTokenManager.lua START

This file contains functions to modify betted tokens
]]

-- Get an object at a specified position with a specific tag
-- pos must be a world-relative position
-- Returns the first such object found
function getObjectAtPosition(pos, tag)
  -- Use a sphere cast to find the object 
  local hits = Physics.cast({
      origin = pos,
      direction = {0, 1, 0},
      type = 2, -- Sphere cast
      size = {OBJ_SEARCH_RADIUS, OBJ_SEARCH_RADIUS, OBJ_SEARCH_RADIUS},
      max_distance = 0,
      -- debug = true -- If true, see where the sphere cast is located 
  })

  for _, hit in ipairs(hits) do
    local obj = hit.hit_object
    print('hit obj tag' .. obj.tag)

    if obj.tag == tag then
      return obj
    end
  end

  return nil
end

function hasCardInBetZone(color)
  local betPos = players[color].betPos
  
  -- Invert the x position to point to the correct spot
  local convertedBetPos = {betPos[1] * -1, betPos[2], betPos[3]}
  local betCard = getObjectAtPosition(convertedBetPos, 'Card')

  if betCard ~= nil then
    return true
  else
    return false
  end
end

-- Set the given player's token to BETTED
function activateBettedToken(color)
  local tokenGUID = BETTED_TOKEN_GUID[color]
  local bettedToken = getObjectFromGUID(tokenGUID)
  bettedToken.setColorTint(RED2)
  bettedToken.setName(BETTED_TOOLTIP)
end

-- Set the given player's token to NOT BETTED
function deactivateBettedToken(color)
  local tokenGUID = BETTED_TOKEN_GUID[color]
  local bettedToken = getObjectFromGUID(tokenGUID)
  bettedToken.setColorTint(WHITE)
  bettedToken.setName(NO_BET_TOOLTIP)
end

-- Change bet token's color and name based on whether the player betted last round
function updateBettedToken(color)
  if players[color].betted then
    activateBettedToken(color)
  else
    deactivateBettedToken(color)
  end
end

-- Track whether each player's betted or not
-- This should be used before bet cards are moved to the win piel
function trackBettedStatus()
  for _, color in pairs(PLAYER_COLOR_STRINGS) do
    players[color].betted = hasCardInBetZone(color)
    updateBettedToken(color)
  end
end

-- Deactivate betted tokens for both players
function resetBettedTokens()
  for _, color in pairs(PLAYER_COLOR_STRINGS) do
    deactivateBettedToken(color)
  end
end

--[[
BettedTokenManager.lua END
]]