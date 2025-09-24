--[[
Deck.lua START

This file contains deck and card-related functions.
]]

function shuffle(deck)
  for _, item in ipairs(deck) do
      if item.tag == 'Deck' then
          item.shuffle()
      end
  end
end

-- Record card in player's wonCard table, Pass in player and name of card (boolean log if logging)
function recordCard(player, name)
  if player.wonCards[name] == nil then -- If card hasn't been counted yet
    player.wonCards[name] = 1
  else -- If card has been counted
    player.wonCards[name] = player.wonCards[name] + 1

    if player.wonCards[name] > 4 then
      log('Error: Counted more than 4 of '..name..'s')
    end
  end

  log('Count '..player.wonCards[name]..' '..name..'(s) in zone')
end

-- Forget card in player's wonCard table, Pass in player and name of card
function forgetCard(player, name)
  player.wonCards[name] = player.wonCards[name] - 1

  if player.wonCards[name] < 0 then
    log('Error: wonCards reads a negative value for '..name)
  end
  log('Count '..player.wonCards[name]..' '..name..'(s) in zone')
end

-- Get a card from either the deck or card in the deck zone (a single card deck turns into a card)
function getDeck()
    local zoneObjects = deckZone.getObjects()

    for _, item in ipairs(zoneObjects) do -- Check if there's a deck
        if item.tag == 'Deck' then
            return item -- Return deck
        end
    end

    for _, item in ipairs(zoneObjects) do -- Check if there's a card after checking for deck
        if item.tag == 'Card' then
            return item -- Return card
        end
    end

    log('Deck is empty')
    return nil
end

-- Deals a card all players or a certain player from the deck Zone (playerColor optional)
function dealDeck(number, playerColor)
  local deck = getDeck()

  if deck ~= nil then
    local locked = deck.locked

    if not locked then
      deck.locked = true
    end

    if playerColor == nil then
      deck.deal(number)
    else
      deck.deal(number, playerColor)
    end

    if not locked then
      deck.locked = false
    end
  end
end

-- Prevent cards from stacking when in a Spoils or Graveyard
function tryObjectEnterContainer(_, object)
  zone = object.getZones()
  if zone == NUM_OF_ZONES_FOR_SPOILS_CARD and (zone == WIN_PILE_GUID['Blue'] or WIN_PILE_GUID['Orange'] or DISCARD_GUID) then
    return object.type ~= 'Card'
  end
  return true
end

function contains(list, str)
  for _, value in ipairs(list) do
    if value == str then
      return true
    end
  end

  return false
end

-- Given a Card type object, get a string int the format "VALUE of SUIT"
function getFullCardName(card)
  local cardName = ""
  local cardDescription = ""

  if card.tag ~= "Card" then
    cardName = card.name
    cardDescription = card.description
  else
    -- For handling single card left in deck
    cardName = card.getName()
    cardDescription = card.getDescription()
  end

  local cardSuit = string.lower(cardDescription)

  -- Make the suit name match the image file syntax (e.g. spades)
  if contains(DEFAULT_SUIT_NAMES, cardSuit) then
    cardSuit = cardSuit .. "s"
  end

  return string.lower(cardName) .. "_of_" .. cardSuit
end

--[[
Deck.lua END
]]
