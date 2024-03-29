--[[
Zones.lua START

This file contains zone-related functions
]]

-- Runs when an object enters a zone
function onObjectEnterZone(zone, object)
   -- Color of player who owns zone
  local color = zone.getVar('owner')

  if color != nil and object != nil then
    updateScore(zone)
    -- A win or discard pile and card entering
    if (color!='Discard' and zone==players[color].winPile) then
      --So both cards and decks activate layout
      zone.LayoutZone.layout()

      if object.tag=='Card' then
        --Can optionaly add 'true' as a parameter to log cards
        -- Add card to player's wonCards Table (Player and card name)
        local player = players[color]
        local cardName = object.getName()
        recordCard(player, cardName)

        -- If a four-of-a-kind is detected, then highlight those cards
        if (player.wonCards[cardName] == 4) then
          highlightCards(cardName, zone, FOUR_OF_A_KIND_HIGHLIGHT_COLOR)
        end

      end
    elseif zone==discardZone then
      -- zone.LayoutZone.layout() Don't layout discard
    end
  end
end

function onObjectLeaveZone(zone, object)
  local color = zone.getVar('owner') -- Color of player who owns zone

  if color != nil and object != nil then
    updateScore(zone)
    -- A win or discard pile and card entering
    -- If zone is discard than color is discard which isn't a player
    if (color!='Discard' and zone==players[color].winPile and object.tag=='Card') then
      --Can optionaly add 'true' as a parameter to log cards
      -- Remove card from player's wonCards Table (Player and card name)
      local player = players[color]
      local cardName = object.getName()
      local numCardsBeforeObjectLeave = player.wonCards[cardName]
      forgetCard(player,cardName)

      -- If a player loses a four-of-a-kind, unhighlight those cards
      if (numCardsBeforeObjectLeave == 4) then
        removeHighlightsFromCards(cardName, zone)
      end

      object.highlightOff()
    end
  end
end

function updateScore(zone)
  local owner = zone.getVar('owner')
  local zoneObjects = zone.getObjects()
  local scoreText = scores[owner]

  local points = calculatePointsFromObjects(zoneObjects)
  -- Need to finish below
  -- highlightBonusCards(cardTable, "Yellow")

  if owner != 'Discard' then
    scoreText.TextTool.setValue("Score: "..points)
  else
    scoreText.TextTool.setValue("Total: "..points)
  end
end

-- Highlight all cards with the given name in a target zone
function highlightCards(cardName, zone, highlightColor)
  log("Highlight " .. cardName .. " cards")
  local zoneObjects = zone.getObjects()

  -- If object is a card that matches the given name, highlight it
  for _, item in pairs(zoneObjects) do
    if item.tag == 'Card' and item.getName() == cardName then
      item.highlightOn(highlightColor)
    end
  end
end

-- Remove highlights from all cards with the given name within a specific zone
function removeHighlightsFromCards(cardName, zone)
  log("Removing highlights from " .. cardName .. " cards")
  local zoneObjects = zone.getObjects()

  -- If object is a card that matches the given name, remove highlights from it
  for _, item in pairs(zoneObjects) do
    if item.tag == 'Card' and item.getName() == cardName then
      item.highlightOff()
    end
  end
end

--[[
Zones.lua END
]]
