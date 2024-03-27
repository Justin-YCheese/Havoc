--[[
Havoc.lua START

The main file for running the Havoc (Tabletop Edition) game.
]]

-- Notes:
-- I use players['Blue'] because in a few functions you can input
--     'players[Color of Player that clicked button]' to easily get the player variables
-- Indexes start at 1. So the first element in a table is at 'table[1]'
-- You can use '#' to get the length of a table like '#table'
-- Using editNotebookTab() is super janky, check Notebook info in Utility section
--
-- Workshop ID: 2723093390

-- TODO: Remove dependancy on Player Won Cards

require("src/Buttons/BetButton")
require("src/Buttons/ButtonManager")
require("src/Buttons/ClearButton")
require("src/Buttons/DealButton")
require("src/Buttons/DeckButton")
require("src/Buttons/ResetButton")
require("src/Buttons/ResultsButton")
require("src/Buttons/SumButton")
require("src/Constants")
require("src/Deck")
require("src/Notebook")
require("src/PlayerManager")
require("src/Shortcuts")
require("src/Utility/Messaging")
require("src/Utility/StringConverter")
require("src/Validation")
require("src/Zones")

-- Tools for debugging
require("src/Buttons/TestButton")
require("src/Utility/Debug")

players = {}
--Table of Player Blue variables
players['Blue'] = {
  betState=false, --If player betted
  betPos={7,1.15,3.75}, -- For player's bet position
  sumButtonPos={-19,1.15,1.4}, -- Position of sum points button
  --class='',     --player's class
  --drawNum=0,    --amount player will draw by default (for classes?)
  winPile='',     --player's winpile
  wonCards={},    --Table of cards in player's winPile
  points=0,       --player's points
  hand='',        --player's hand
  backup=false    --if player has gotten backup
}

--Table of Player 2 variables (Orange)
players['Orange'] = {
  betState=false,--If player betted
  betPos={7,1.15,-3.75}, -- For player's bet position
  sumButtonPos={-19,1.15,-1.4}, -- Position of sum points button
  --class='',     --player's class
  --drawNum=0,    --amount player will draw by default (for classes?)
  winPile='',     --player's winpile
  wonCards={},    --Table of cards in player's winPile
  points=0,       --player's points
  hand='',        --player's hand
  backup=false    --if player has gotten backup
}

-- For gathering game statistics
record = {}
record['points'] = {} -- Points won each round of the game

-- Global table of zone variables
zone_vars = {
  allow_swapping=false,
  cards_per_deck=1,
  combine_into_decks=false,
  meld_sort_existing=true,
  --direction=0,
  horizontal_group_padding=.1,
  vertical_group_padding=.1,
  horizontal_spread=.4,
  vertical_spread=0,
  max_objects_per_group=4,
  max_objects_per_new_group=4,
  new_object_facing=1,
  split_added_decks=true,
  sticky_cards=false
}

scores = {}
scores['Blue'] = ''
scores['Orange'] = ''
scores['Discard'] = ''

-- Track if players should be allowed to use certain shortcuts or not
gameStarted = false

-- Runs once when the game loads
function onLoad()
  log('onLoad!')

  --Get objects from GUIDs (All these variables are global)
  button = getObjectFromGUID(BUTTON_GUID)
  button.setPosition({0,0,0})
  button.setRotation({0,0,0})

  fieldZone = getObjectFromGUID(FIELD_ZONE_GUID)
  deckZone = getObjectFromGUID(DECK_ZONE_GUID)

  players['Blue'].winPile = getObjectFromGUID(WIN_PILE_GUID['Blue'])
  players['Orange'].winPile = getObjectFromGUID(WIN_PILE_GUID['Orange'])

  players['Blue'].hand = getObjectFromGUID(HAND_GUID['Blue'])
  players['Orange'].hand = getObjectFromGUID(HAND_GUID['Orange'])

  scores['Blue'] = getObjectFromGUID(SCORE_GUID['Blue'])
  scores['Orange'] = getObjectFromGUID(SCORE_GUID['Orange'])
  scores['Discard'] = getObjectFromGUID(SCORE_GUID['Discard'])

  discardZone = getObjectFromGUID(DISCARD_GUID)
  deckBuilder = getObjectFromGUID(DECK_BUILDER_GUID)

  local deck = deckZone.getObjects()
  shuffle(deck)
  createDealButton()
  createBuildDeckButton(deckBuilder)

  -- createTestButton()

  setupShortcuts()
end

--Given a table of cards, returns sum of points
--If bonusIsSeparate defined, then return sum and bonus seperately
function calculatePoints(cardTable, bonusIsSeparate)
  local bonusCards = {}
  local sum = 0 -- Normal sum

  for name, cards in pairs(cardTable) do
    -- add value of cards to sum
    sum = sum + cards*stats[name][1]
    -- If there are 4 of that type of card
    if cards == 4 then
      table.insert(bonusCards,name)
    end
  end

  -- If not assigned
  if bonusIsSeparate == nil then
    return sum
  else if bonusIsSeparate == true then
    return sum, bonusCards end
  end
end

-- A simpler version of calculate points which uses the objects instead of an array
function calculatePointsFromObjects(zoneObjects)
  local sum = 0
  local count = 0

  for _, item in pairs(zoneObjects) do
    -- If a card
    if item.tag == 'Card' then
      local name = item.getName()
      -- add value of cards to sum
      sum = sum + stats[name][1]
      count = count + 1
    end
  end

  return sum, count
end

function calculatePointsFromObjectsPrint(params)
  local zoneObjects = params.zoneObjects -- All objects in zone
  local zoneName = params.zoneName
  local stopBroadcast = params.stopBroadcast

  local sum, numCards = calculatePointsFromObjects(zoneObjects)

  broadcast(zoneName.." has "..sum.." points")
end

function countCards(cardTable)
  local numCards = 0

  for name, cards in pairs(cardTable) do
    numCards = numCards + cards
  end

  return numCards
end

function calculatePointsPrint(params)
  local zoneObjects = params.zoneObjects
  local zoneName = params.zoneName
  local stopBroadcast = params.stopBroadcast
  -- Count the cards in the zone
  local cardTable = {}

  for _, item in pairs(zoneObjects) do
    -- If a card
    if item.tag == 'Card' then
      local name = item.getName()

      -- If not counted yet
      if cardTable[name] == nil then
        cardTable[name] = 1
      -- If already counted
      else
        cardTable[name] = cardTable[name] + 1
      end
    end
  end
  -- Calculate total points, record bonus cards and num cards in zone
  local sum, bonusCards = calculatePoints(cardTable, true)
  local numCards = countCards(cardTable)

  -- Base points message
  local pointMessage = zoneName..' has '..sum..' points'

  if (numCards > 0) then
    pointMessage = pointMessage..' and '..numCards

    if (numCards == 1) then
      pointMessage = pointMessage..' card'
    else
      pointMessage = pointMessage..' cards'
    end
  end

  -- Bonuses gained
  if #bonusCards > 0 then --There is at least a bonus
    local bonusMessage = '\nFour of a Kind: ' -- "Hello" "World" "HelloWorld"
    for _, card in pairs(bonusCards) do
      bonusMessage = bonusMessage..card..'s '
    end

    -- Broadcast with bonusMessage (seems only one broadcast at a time)
    if stopBroadcast then
      log(pointMessage..bonusMessage)
    else
      broadcast(pointMessage..bonusMessage)
    end
  else
    -- Broadcast without bonusMessage
    if stopBroadcast then
      log(pointMessage)
    else
      broadcast(pointMessage)
    end
  end
end

--[[
Havoc.lua END
]]
