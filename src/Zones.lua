--[[
Zones.lua START

This file contains zone-related functions
]]

-- Runs when an object enters a zone
function onObjectEnterZone(zone, object)
   -- Color of player who owns zone
  local color = zone.getVar('owner')

  if color != nil then
    updateScore(zone)
    -- A win or discard pile and card entering
    if (color!='Discard' and zone==players[color].winPile) then
      --So both cards and decks activate layout
      zone.LayoutZone.layout()

      if object.tag=='Card' then
        --Can optionaly add 'true' as a parameter to log cards
        -- Add card to player's wonCards Table (Player and card name)
        recordCard(players[color],object.getName())
      end
    elseif zone==discardZone then
      -- zone.LayoutZone.layout() Don't layout discard
    end
  end
end

function onObjectLeaveZone(zone, object)
  local color = zone.getVar('owner') -- Color of player who owns zone

  if color != nil then
    updateScore(zone)
    -- A win or discard pile and card entering
    -- If zone is discard than color is discard which isn't a player
    if (color!='Discard' and zone==players[color].winPile and object.tag=='Card') then
      --Can optionaly add 'true' as a parameter to log cards
      -- Add card to player's wonCards Table (Player and card name)
      forgetCard(players[color],object.getName())
    end
  end
end

function updateScore(zone)
  local owner = zone.getVar('owner')
  local zoneObjects = zone.getObjects()
  local scoreText = scores[owner]

  local points = calculatePointsFromObjects(zoneObjects)

  if owner != 'Discard' then
    scoreText.TextTool.setValue("Score: "..points)
  else
    scoreText.TextTool.setValue("Total: "..points)
  end
end

--[[
Zones.lua END
]]
