--[[
ResultsButton.lua START

This file contains functions that the reset button triggers.
]]

-- Sends cards on field to winner's Win Pile and proceeds to drawing phase
function createResultsButton()
  local bResults_vars = {
    click_function='results',
    function_owner=nil,
    label='Results',
    position={-7,1.15,3.75},
    rotation={0,270,0},
    width=STANDARD_BUTTON_WIDTH,
    height=STANDARD_BUTTON_HEIGHT,
    font_size=BUTTON_FONT_SIZE,
    color=BUTTON_BACKGROUND_COLOR,
    font_color=BUTTON_TEXT_COLOR,
    tooltip="For the Winner"
  }

  button.createButton(bResults_vars) -- Make results button
end

-- Puts cards in field into the win pile of the player who triggered this function
function results(obj, color, alt_click)
  if players[color] == nil then
    broadcast(PLAYER_HAS_NO_COLOR_BROADCAST_MESSAGE)
    return
  end

  resetBetStates()
  local zoneObjects = fieldZone.getObjects()

  -- Calculate, Broadcast, and Record gained points & bonuses
  resultAddedPoints(color,zoneObjects)
  moveCardsToWinPile(color, zoneObjects)
  regenerateBetButtons()
end

function moveCardsToWinPile(color, zoneObjects)
  local i = 0
  local winPlacement = players[color].winPile.getPosition()

  for _, item in ipairs(zoneObjects) do
    -- If in only field zone and the zone surrounding the whole game (so doesn't grab deck)
    if #item.getZones() == NUM_OF_ZONES_FOR_FIELD_CARDS and item.tag == 'Card' then
      -- Put cards above win pile at varying heights
      local winPilePosition = {winPlacement[1], winPlacement[2]+5+i, winPlacement[3]}
      item.setPositionSmooth(winPilePosition, false, true)
      i = i + .8
    end
  end
end

-- Returns points earned from adding cards to winner
-- Given the player that won and cards that will be added
-- Doesn't work for decks in the field
function resultAddedPoints(playerColor,zoneObjects)
  local player = players[playerColor]
  local numofCards = 0
  local cardTable = {}
  local bonusCards = {}
  local initialPoints = calculatePoints(player.wonCards)
  -- Kept empty if there was no backup
  local backupMessage = ''
  -- Copy values without reference
  for name, cards in pairs(player.wonCards) do
    cardTable[name] = player.wonCards[name]
  end
  -- simulates 'adding' cards from field to wonCards (doesn't actually change wonCards)
  for _, item in pairs(zoneObjects) do
    -- If a card is in only 2 zones (FieldZone and DeckBuilder | So not the deck)
    if #item.getZones() == NUM_OF_ZONES_FOR_FIELD_CARDS and item.tag == 'Card' then
      numofCards = numofCards + 1
      local name = item.getName()
      -- If not counted yet
      if cardTable[name] == nil then
        cardTable[name] = 1
      -- If already counted
      else
        cardTable[name] = cardTable[name] + 1
        -- Record 4 of a kind
        if cardTable[name] == 4 then
          --log('Found 4 of a kind: '..name)
          table.insert(bonusCards, name)
          if not player.backup then
            player.backup = true
            -- Backup removed from the game
            -- backupMessage = 'and got Backup!'
          end
        end
      end
    end
  end

  -- New sum of points
  local simulatedPoints = calculatePoints(cardTable)

  -- Points gained from new cards
  local pointsGained = simulatedPoints - initialPoints
  -- 'Point totals added' message
  local pointMessage = 'Adding '..pointsGained..' to '..initialPoints..' for '..simulatedPoints..' points'
  -- Bonuses gained
  if #bonusCards > 0 then --There is at least a bonus
    local bonusMessage = '\nFour of a Kind: '
    for _, card in pairs(bonusCards) do
      bonusMessage = bonusMessage..card..'s '
    end

    -- If there was no backup, then backupMessage should be empty
    bonusMessage = bonusMessage..backupMessage
    broadcast(pointMessage..bonusMessage)
  else
    broadcast(pointMessage)
  end

  if #bonusCards == 0 then
    addRoundNote(playerColor..' gained '..pointsGained..' from '..numofCards..' cards '..backupMessage)
  else
    addRoundNote(playerColor..' gained '..pointsGained..' with '..#bonusCards..' FoK from '..numofCards..' cards '..backupMessage)
  end

  return pointsGained
end

--[[
ResultsButton.lua END
]]
