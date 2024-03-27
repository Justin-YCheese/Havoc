--[[
ClearButton.lua START

This file contains functions that the reset button triggers.
]]

function createClearButton()
  local buttonSettings = {
    click_function='clearField',
    function_owner=nil,
    label='Clear',
    position={-7,1.15,-3.75},
    rotation={0,270,0},
    width=STANDARD_BUTTON_WIDTH,
    height=STANDARD_BUTTON_HEIGHT,
    font_size=BUTTON_FONT_SIZE,
    color=BUTTON_WARNING_BACKGROUND_COLOR,
    font_color=BUTTON_WARNING_TEXT_COLOR, -- Changed from text to background color for white colored text
    tooltip="Move fields cards to discard"
  }

  button.createButton(buttonSettings)
end

-- Puts cards in field into discard zone
function clearField(obj, color)
  if players[color] == nil then
    broadcast(PLAYER_HAS_NO_COLOR_BROADCAST_MESSAGE)
    return
  end

  addRoundNote('Clear '..getNumCardsInField()..' cards from the field.')
  moveCardsToDiscard()
  regenerateBetButtons()
  resetBetStates()
end

function getNumCardsInField()
  local fieldZoneObjects = fieldZone.getObjects()
  local numCards = 0

  for _, item in pairs(fieldZoneObjects) do
    if #item.getZones() == NUM_OF_ZONES_FOR_FIELD_CARDS and item.tag == 'Card' then
      numCards = numCards + 1
    end
  end

  return numCards
end

function moveCardsToDiscard()
    local fieldZoneObjects = fieldZone.getObjects()
    local i = 0

    for _, item in ipairs(fieldZoneObjects) do
      -- If in only field zone and the zone surrounding the whole game (so doesn't grab deck)
      if #item.getZones() == NUM_OF_ZONES_FOR_FIELD_CARDS and item.tag == 'Card' then
        -- Jitter is for 'shaking' the cards slightly to reduce a chance of exactly overlapping cards
        local newPosition = getRandomDiscardPosition(i)
        item.setPositionSmooth(newPosition, false, true)
        i = i + .8
      end
    end
end

function getRandomDiscardPosition(numIterations)
  local discardZonePosition = discardZone.getPosition()
  local randomXOffset = math.random(DISCARD_X_OFFSET * 2 + 1) - DISCARD_X_OFFSET;
  local randomYOffset = math.random(DISCARD_Y_OFFSET * 2 + 1) - DISCARD_Y_OFFSET;
  local xJitter = math.random() * 2 - 1
  local yJitter = math.random() * 2 - 1

  local newX = discardZonePosition[1] + randomXOffset + xJitter
  local newZ = discardZonePosition[2] + 5 + numIterations
  local newY = discardZonePosition[3] + randomYOffset + yJitter
  return {newX, newZ, newY}
end

--[[
ClearButton.lua END
]]
