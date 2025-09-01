--[[
Shortcuts.lua START

This file contains shortcut-related functions.
]]

function setupShortcuts()
  log("Setting up shortcuts")
  addHotkey("Draw Card", drawCardShortcut)
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

-- Trigger bet button based on the given color
function betShortcut(playerColor)
  local shortcutName = "Bet"

  if isInGameShortcutUsable(playerColor, shortcutName) == false then
    return
  end

  playerBet(playerColor, playerColor)
end

-- Overwrites default behavior and setup some shortcuts when number keys are pressed on cards
function onObjectNumberTyped(object, player_color, number)
  if object.tag ~= 'Card' then
    return
  end
  
  if isObjectHeldBy(object, player_color) == true then
    if number == 1 or number == 2 then
      playCardFromHand(object, player_color, number)
    end
  end
  
  return true
end

-- Check if the given object is in the player's hand zone
function isObjectHeldBy(object, player_color)
  local handZone = players[player_color].hand

  for _, item in pairs(handZone.getObjects()) do
    if item == object then
      return true
    end
  end

  return false
end

-- Move a card from a player's hand to the field based on the key pressed
-- Only keys "1" and "2" are supported
function playCardFromHand(object, player_color, key_pressed)
  if object.tag ~= 'Card' then
    return
  end

  if player_color ~= 'Orange' and player_color ~= 'Blue' then
    return
  end

  if object.is_face_down == true then
    object.flip()
  end

  local x_offset = PLAY_CARD_X_OFFSET
  local y_offset = PLAY_CARD_Y_OFFSET
  local z_offset = PLAY_CARD_Z_OFFSET

  orange_field_card_slots = {
    { 1, {-x_offset, y_offset, -z_offset} },
    { 2, {x_offset, y_offset, -z_offset} }
  }

  blue_field_card_slots = {
    { 1, {x_offset, y_offset, z_offset} },
    { 2, {-x_offset, y_offset, z_offset} }
  }

  -- Get card slot positions based on player color
  local slots = nil

  if player_color == 'Orange' then
    slots = orange_field_card_slots
  elseif player_color == 'Blue' then
    slots = blue_field_card_slots
  end

  -- Get the new card position based on the number pressed
  for i, slot_data in pairs(slots) do
    local slot_key = slot_data[1]
    local slot_position = slot_data[2]

    if slot_key == key_pressed then
      object.setPosition(slot_position)
      return 
    end
  end
end

--[[
Shortcuts.lua END
]]
