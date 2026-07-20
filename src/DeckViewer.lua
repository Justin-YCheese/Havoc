--[[
DeckViewer.lua START

This file contains deck viewer functions.

The deck viewer doesn't actually show cards in the deck or the players' hands.
It shows the cards that are in discard and win piles, otherwise you get extra information you wouldn't otherwise in an offline game. 
]]

-- If the player can see the deck viewer, turn it off for them. Otherwise show them the deck viewer.
function toggleDeckViewer(playerColor)
  local currVisibility = UI.getAttribute("deckViewer", "visibility")

  -- No one can see the deck viewer, so show it to the given player
  if currVisibility == nil or currVisibility == '' then
    UI.setAttribute("deckViewer", "visibility", playerColor)
    return
  end

  local deckViewerIsVisible = string.find(currVisibility, playerColor)

  if deckViewerIsVisible == nil then
    -- Since player has no visibility, give them visibility
    currVisibility = currVisibility .. "|" .. playerColor
  else
    -- Otherwise, hide the display for the given user
    currVisibility = string.gsub(currVisibility, playerColor, "")
    
    -- Remove potential lingering pipes characters
    currVisibility = string.gsub(currVisibility, "||", "|")

    if #currVisibility > 0 and string.sub(currVisibility, 1, 1) == "|" then
      currVisibility = string.sub(currVisibility, 2)
    end

    if #currVisibility > 0 and string.sub(currVisibility, -1) == "|" then
      currVisibility = string.sub(currVisibility, 1, -2)
    end
  end

  UI.setAttribute("deckViewer", "visibility", currVisibility)
end

-- Get all image ids in the deck viewer layout
function getDeckViewerImageIds()
  -- Find deck viewer
  local xmlTable = UI.getXmlTable()
  local deckViewerChildren = {}
  local element = nil

  for i=1,#xmlTable do
    element = xmlTable[i]

    if element == nil then
      break
    end

    if element.tag == "TableLayout" and element.attributes.id == "deckViewer" then
      deckViewerChildren = element.children or {}
      break
    end
  end

  if #deckViewerChildren == 0 then
    log("Deck Viewer layout not found")
    return {}
  end

  -- Get cells within the table
  local deckViewerCells = {}
  local deckViewerChild = nil
  local rowChild = nil

  for i=1,#deckViewerChildren do
    deckViewerChild = deckViewerChildren[i]

    if deckViewerChild == nil then
      break
    end

    if deckViewerChild.tag == "Row" then
      for j=1,#deckViewerChild.children do
        rowChild = deckViewerChild.children[j]

        if rowChild == nil then
          break
        end

        if rowChild.tag == "Cell" then
          deckViewerCells[#deckViewerCells + 1] = rowChild
        end
      end
    end
  end

  if #deckViewerCells == 0 then
    log("No cells found within Deck Viewer layout")
    return {}
  end

  -- Get image ids within the cells
  local imageIds = {}
  local imageIndex = 0
  local cell = nil
  local cellChild = nil

  for i=1,#deckViewerCells do
    cell = deckViewerCells[i]

    if cell == nil then
      break
    end

    local cellChildren = cell.children

    if #cellChildren > 0 then
      for j=1,#cellChildren do
        cellChild = cellChildren[j]

        if cellChild == nil then
          break
        end

        if cellChild.tag == "Image" then
          imageIndex = imageIndex + 1
          imageIds[imageIndex] = cellChild.attributes.id
        end
      end
    end
  end

  return imageIds
end

-- Darken all cards in the deck viewer
function darkenCardsInDeckViewer()
  local imageIds = getDeckViewerImageIds()
  local id = nil

  for i=1,#imageIds do
    id = imageIds[i]

    if id == nil then
      break
    end

    UI.setClass(id, "hidden")
  end
end

function combineLists(list1, list2)
  local result = {}

  for i = 1, #list1 do
    result[#result + 1] = list1[i]
  end

  for i = 1, #list2 do
    result[#result + 1] = list2[i]
  end

  return result
end

function getCardNamesInDeck(deck)
  if deck == nil or deck.tag ~= "Deck" then
    return nil
  end

  local cardNames = {}
  local index = 0
  local deckObjects = deck.getObjects()

  for _, card in ipairs(deckObjects) do
    if card.name ~= nil and card.name ~= "" and card.description ~= nil and card.description ~= "" then
      index = index + 1
      cardNames[index] = getFullCardName(card)
    end
  end

  return cardNames
end

-- Get all cards left in the given zone in the format "VALUE of SUIT"
function getCardNames(zone)
  local cardNames = {}
  local zoneObjects = zone.getObjects()

  for _, item in ipairs(zoneObjects) do -- Check if there's a deck
    if item.tag == "Deck" then
      local deckCardNames = getCardNamesInDeck(item)

      for _, cardName in ipairs(deckCardNames) do
        cardNames[#cardNames + 1] = cardName
      end
    elseif item.tag == "Card" then
      local fullCardName = getFullCardName(item)
      cardNames[#cardNames + 1] = fullCardName
    end
  end

  return cardNames
end

-- Update jokers in the deck viewer based on how many jokers are tracked so far
function updateJokerDisplay(makeVisible)
  if numJokers == nil then
    return
  end

  if numJokers >= 2 then
    UI.setClass("joker1", "")
    UI.setClass("joker2", "")
  elseif numJokers == 1 then
    UI.setClass("joker1", "")
    UI.setClass("joker2", "hidden")
  else
    UI.setClass("joker1", "hidden")
    UI.setClass("joker2", "hidden")
  end
end

-- Check for all cards in discard and win piles and update deck viewer accordingly 
function refreshDeckViewer()
  -- Find out what cards are in discard and win piles
  local blueWinCards = getCardNames(players['Blue'].winPile)
  local orangeWinCards = getCardNames(players['Orange'].winPile)
  local discardCards = getCardNames(discardZone)
  local allCardNames = combineLists(blueWinCards, orangeWinCards)
  allCardNames = combineLists(allCardNames, discardCards)

  darkenCardsInDeckViewer()
  numJokers = 0

  -- Make all cards that are actually in the deck visible
  local cardName = nil

  for i=1,#allCardNames do
    cardName = allCardNames[i]

    if cardName == nil then
      break
    end

    if cardName ~= "joker_of_joker" then
      UI.setClass(cardName, "")
    else
      numJokers = numJokers + 1
    end
  end

  updateJokerDisplay()
end

-- Update the deck viewer based on an object leaving or entering a relevant zone
function updateCardDisplay(object, makeVisible)
  if object == nil and object.tag ~= "Card" and object.tag ~= "Deck" then
    return
  end

  local cardNames = {}

  if object.tag == "Card" then
    cardNames[#cardNames + 1] = getFullCardName(object)
  elseif object.tag == "Deck" then
    local deckCardNames = getCardNamesInDeck(object)

    for _, cardName in ipairs(deckCardNames) do
      cardNames[#cardNames + 1] = cardName
    end
  end

  local targetClass = nil

  if makeVisible then
    targetClass = ""
  else
    targetClass = "hidden"
  end


  for _, cardName in ipairs(cardNames) do
    if cardName ~= "joker_of_joker" then
      UI.setClass(cardName, targetClass)
    elseif makeVisible then
      numJokers = math.min(numJokers + 1, 2)
    else
      numJokers = math.max(numJokers - 1, 0)
    end
  end

  updateJokerDisplay()
end

--[[
DeckViewer.lua END
]]