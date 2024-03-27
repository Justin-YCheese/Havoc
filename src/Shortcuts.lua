--[[
Shortcuts.lua START

This file contains shortcut-related functions.
]]

function setupShortcuts()
  log("Setting up shortcuts")
  addHotkey("Draw Card", drawCardShortcut)
  addHotkey("Get Discard Sum", getDiscardSumShortcut)
  addHotkey("Get My Sum", getMySumShortcut)
  addHotkey("Get Opponent's Sum", getOpponentSumShortcut)
  addHotkey("Bet", betShortcut)
end

-- Draw a card for player when hotkey is pressed
function drawCardShortcut(playerColor)
  local shortcutName = "Draw Card"

  if isInGameShortcutUsable(playerColor, shortcutName) == false then
    return
  end

  log("Shortcut: deal a card to " .. playerColor .. " player")
  dealDeck(1, playerColor)
end

-- Show sum of points in discard if hotkey is pressed
function getDiscardSumShortcut()
  local shortcutName = "Get Discard Sum"

  if hasGameStarted(shortcutName) == false then
    return
  end

  log("Shortcut: get discard point sum")
  discardZone.call("tableCalculatePoints")
end

-- Show sum of points in player's win pile if hotkey is pressed
function getMySumShortcut(playerColor)
  local shortcutName = "Get My Sum"

  if isInGameShortcutUsable(playerColor, shortcutName) == false then
    return
  end

  log("Shortcut: get my point sum")
  players[playerColor].winPile.call("tableCalculatePoints")
end

-- Show sum of points in opponent's win pile if hotkey is pressed
function getOpponentSumShortcut(playerColor)
  local shortcutName = "Get Opponent Sum"

  if isInGameShortcutUsable(playerColor, shortcutName) == false then
    return
  end

  local opponentZone = nil

  if playerColor == "Orange" then
    opponentZone = players["Blue"].winPile
  else
    opponentZone = players["Orange"].winPile
  end

  log("Shortcut: get opponent point sum")
  opponentZone.call("tableCalculatePoints")
end

-- Trigger bet button based on the given color
function betShortcut(playerColor)
  local shortcutName = "Bet"

  if isInGameShortcutUsable(playerColor, shortcutName) == false then
    return
  end

  playerBet(playerColor, playerColor)
end

--[[
Shortcuts.lua END
]]
