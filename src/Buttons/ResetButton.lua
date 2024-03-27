--[[
ResetButton.lua START

This file contains functions that the reset button triggers.
]]

resetButtonPosition = {26.5, 1.15, 0}
resetTimesPressed = 0
resetPressedTimerId = nil

function createResetButton(label)
  local resetButtonVars = {
    click_function='incrementResetCounter',
    function_owner=nil,
    label=label,
    position=resetButtonPosition,
    rotation={0, 90, 0},
    width=SMALL_BUTTON_WIDTH,
    height=SMALL_BUTTON_HEIGHT,
    font_size=BUTTON_FONT_SIZE,
    color=BUTTON_WARNING_BACKGROUND_COLOR,
    font_color=BUTTON_WARNING_TEXT_COLOR,
    tooltip="Click "..NUM_CLICKS_TO_RESET.." times to reset the game"
  }

  button.createButton(resetButtonVars)
end

function incrementResetCounter()
  resetTimesPressed = resetTimesPressed + 1

  if resetTimesPressed == NUM_CLICKS_TO_RESET then
    resetTimesPressed = 0
    stopResetTimer()
    resetGame()
  else
    stopResetTimer()
    resetPressedTimerId = Wait.time(function() updateResetTimesPressed(0) end, SECONDS_UNTIL_COUNTER_RESET)
  end

  updateResetTimesPressed(resetTimesPressed)
end

function updateResetTimesPressed(value)
  resetTimesPressed = value

  if value == 0 then
    updateResetButtonLabel(DEFAULT_RESET_BUTTON_LABEL)
  else
    updateResetButtonLabel(value)
  end
end

function updateResetButtonLabel(label)
  deleteButtonHere(resetButtonPosition)
  createResetButton(label)
end

function stopResetTimer()
  if resetPressedTimerId ~= nil then
    Wait.stop(resetPressedTimerId)
    resetPressedTimerId = nil
  end
end

function resetGame()
  logGameData()
  regenerateBetButtons()
  resetPlayers()
  resetDeck()
  resetRoundsNotebook()
  log('Game reset')
end

-- Log game data in case we forgot to trigger results buttons and check the notebook before resetting
function logGameData()
  local latestRoundNumber = getLatestRoundNumber()

  if latestRoundNumber == nil then
    latestRoundNumber = 0
  end

  broadcast('Rounds played: '..tostring(latestRoundNumber))
  logCardPileData('Orange')
  logCardPileData('Blue')
  logCardPileData('Discard')
end

function logCardPileData(targetName)
  local params = nil

  if targetName == 'Orange' then
    params = {
      zoneObjects = players['Orange'].winPile.getObjects()
    }
  elseif targetName == 'Blue' then
    params = {
      zoneObjects = players['Blue'].winPile.getObjects()
    }
  elseif targetName == 'Discard' then
    params = {
      zoneObjects = discardZone.getObjects()
    }
  else
    return
  end

  params.zoneName = targetName
  params.stopBroadcast = false
  calculatePointsPrint(params)
end

function resetDeck()
  local allObjects = getObjects()
  local cardAndDecks = {}
  local numFound = 0
  local deckZonePosition = deckZone.getPosition()

  for _, item in pairs(allObjects) do
    if item.tag == 'Card' or item.tag == 'Deck' then
      numFound = numFound + 1
      cardAndDecks[numFound] = item
    end
  end

  local combinedDeck = group(cardAndDecks)[1]
  local targetPosition = deckZone.getPosition()
  -- The extra 2 units is to prevent the deck from clipping into the table
  targetPosition[2] = targetPosition[2] + 2
  combinedDeck.setPosition(targetPosition)

  if combinedDeck.is_face_down == false then
    combinedDeck.flip()
  end

  Wait.time(function()
    combinedDeck.shuffle()
    dealDeck(STARTING_HAND_SIZE)
  end, SECONDS_UNTIL_RESET_DECK_SHUFFLE)

  combinedDeck.locked = false
end

--[[
ResetButton.lua END
]]
