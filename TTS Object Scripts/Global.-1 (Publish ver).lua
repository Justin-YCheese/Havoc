-- Bundled by luabundle {"rootModuleName":"Global.-1.lua","version":"1.6.0"}
local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)
	local loadingPlaceholder = {[{}] = true}

	local register
	local modules = {}

	local require
	local loaded = {}

	register = function(name, body)
		if not modules[name] then
			modules[name] = body
		end
	end

	require = function(name)
		local loadedModule = loaded[name]

		if loadedModule then
			if loadedModule == loadingPlaceholder then
				return nil
			end
		else
			if not modules[name] then
				if not superRequire then
					local identifier = type(name) == 'string' and '\"' .. name .. '\"' or tostring(name)
					error('Tried to require ' .. identifier .. ', but no such module has been registered')
				else
					return superRequire(name)
				end
			end

			loaded[name] = loadingPlaceholder
			loadedModule = modules[name](require, loaded, register, modules)
			loaded[name] = loadedModule
		end

		return loadedModule
	end

	return require, loaded, register, modules
end)(nil)
__bundle_register("Global.-1.lua", function(require, _LOADED, __bundle_register, __bundle_modules)
require("src/Havoc")
end)
__bundle_register("src/Havoc", function(require, _LOADED, __bundle_register, __bundle_modules)
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

-- Order matters for the require imports. If file A requires a function in file B, B should be higher than A.
require("src/Utility/ListManager")
require("src/Utility/StringConverter")
require("src/Utility/Messaging")
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
require("src/Validation")
require("src/Zones")
require("src/DeckViewer")

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

-- To track number of jokers to display in the deck viewer
numJokers = nil

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
  usedCardZones = { players['Blue'].winPile, players['Orange'].winPile, discardZone }

  local deck = deckZone.getObjects()
  shuffle(deck)
  createDealButton()
  createBuildDeckButton(deckBuilder)
  refreshDeckViewer()
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

end)
__bundle_register("src/Utility/Debug", function(require, _LOADED, __bundle_register, __bundle_modules)
-- Default function for TestButton
function testMe (obj, color, alt_click)
  broadcast("testing button...")
end

end)
__bundle_register("src/Buttons/TestButton", function(require, _LOADED, __bundle_register, __bundle_modules)
-- Debug button
function createTestButton()
  local testButtonVars = {
    click_function='testMe', -- default function is testMe
    function_owner=nil,
    label='Test Me',
    position={0,4,0},
    rotation={0,0,0},
    width=SMALL_BUTTON_WIDTH*1.2,
    height=SMALL_BUTTON_HEIGHT*1.2,
    font_size=BUTTON_FONT_SIZE,
    color=BUTTON_BACKGROUND_COLOR,
    font_color=BUTTON_TEXT_COLOR,
    tooltip="For degugging specific functions"
  }
  button.createButton(testButtonVars)
end

end)
__bundle_register("src/DeckViewer", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
DeckViewer.lua START

This file contains deck viewer functions.
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
  local xmlTable = UI.getXmlTable()
  local deckViewerChildren = {}

  for _, element in ipairs(xmlTable) do
    if element.tag == "GridLayout" and element.attributes.id == "deckViewer" then
      deckViewerChildren = element.children or {}
      break
    end
  end

  if #deckViewerChildren == 0 then
    log("Deck Viewer layout not found")
    return {}
  end

  local imageIds = {}
  local imageIndex = 0

  for _, childElement in ipairs(deckViewerChildren) do
    if childElement.tag == "Image" then
      imageIndex = imageIndex + 1
      imageIds[imageIndex] = childElement.attributes.id
    end
  end

  return imageIds
end

-- Darken all cards in the deck viewer
function darkenCardsInDeckViewer()
  local imageIds = getDeckViewerImageIds()

  for _, id in ipairs(imageIds) do
    UI.setClass(id, "hidden")
  end
end

function combineLists(list1, list2)
  local result = {}

  for i = 1, #list1 do
      table.insert(result, list1[i])
  end

  for i = 1, #list2 do
      table.insert(result, list2[i])
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
        table.insert(cardNames, cardName)
      end
    elseif item.tag == "Card" then
      local fullCardName = getFullCardName(item)
      table.insert(cardNames, fullCardName)
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
  for _, cardName in ipairs(allCardNames) do
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
    table.insert(cardNames, getFullCardName(object))
  elseif object.tag == "Deck" then
    local deckCardNames = getCardNamesInDeck(object)

    for _, cardName in ipairs(deckCardNames) do
      table.insert(cardNames, cardName)
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
end)
__bundle_register("src/Zones", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
Zones.lua START

This file contains zone-related functions
]]

-- Runs when an object enters a zone
function onObjectEnterZone(zone, object)
   -- Color of player who owns zone
  local color = zone.getVar('owner')

  if color ~= nil and object ~= nil then
    updateScore(zone)
    -- A win or discard pile and card entering
    if (color ~='Discard' and zone==players[color].winPile) then
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

  if contains(usedCardZones, zone) and not inZones(object, copyWithException(usedCardZones, zone)) then
    updateCardDisplay(object, true)
  end
end

function onObjectLeaveZone(zone, object)
  -- Check if game is still running before continuing
  if Info == nil or Info.name == nil then
    return
  end
  
  local color = zone.getVar('owner') -- Color of player who owns zone

  if color ~= nil and object ~= nil then
    updateScore(zone)
    -- A win or discard pile and card entering
    -- If zone is discard than color is discard which isn't a player
    if (color~='Discard' and zone==players[color].winPile and object.tag=='Card') then
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

  if contains(usedCardZones, zone) and not inZones(object, copyWithException(usedCardZones, zone)) then
    updateCardDisplay(object, false)
  end
end

-- Check if the object is inside any of the given zones
function inZones(object, targetZones)
  local objectZones = object.getZones()

  for _, objectZone in ipairs(objectZones) do
    for _, targetZone in ipairs(targetZones) do
      if objectZone == targetZone then
        return true
      end
    end
  end

  return false
end

function updateScore(zone)
  local owner = zone.getVar('owner')
  local zoneObjects = zone.getObjects()
  local scoreText = scores[owner]

  local points = calculatePointsFromObjects(zoneObjects)
  -- Need to finish below
  -- highlightBonusCards(cardTable, "Yellow")

  if owner ~= 'Discard' then
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

end)
__bundle_register("src/Validation", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
Validation.lua START

This file contains functions for checking the status or conditions of things.
]]
-- Check if player color is one of the actual player colors

function isInGameShortcutUsable(playerColor, shortcutName)
  return hasGameStarted(shortcutName) and isValidColor(playerColor, shortcutName)
end

function isValidColor(playerColor, shortcutName)
  if playerColor ~= 'Orange' and playerColor ~= 'Blue' then
    log(playerColor .. " player cannot use "..shortcutName.." shortcut")
    return false
  end

  return true
end

function hasGameStarted(shortcutName)
  if gameStarted == false then
    log(shortcutName.." shortcut is not allowed at this time")
    return false
  end

  return true
end

--[[
Validation.lua END
]]

end)
__bundle_register("src/Shortcuts", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
Shortcuts.lua START

This file contains shortcut-related functions.
]]

function setupShortcuts()
  log("Setting up shortcuts")
  addHotkey("Draw Card", drawCardShortcut)
  addHotkey("Bet", betShortcut)
  addHotkey("View Used Cards", viewDeckShortcut)
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

-- Show the cards left in the deck
function viewDeckShortcut(playerColor)
  local shortcutName = "View Used Cards"

  if isInGameShortcutUsable(playerColor, shortcutName) == false then
    return
  end

  toggleDeckViewer(playerColor)
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
  for _, slot_data in pairs(slots) do
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

end)
__bundle_register("src/PlayerManager", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
PlayerManager.lua START

This file contains functions for modifying or checking player state
]]

-- Reset player states to what they would be like at the start of a new game
function resetPlayers()
  for _, color in pairs(PLAYER_COLOR_STRINGS) do
    players[color].backup = false
    players[color].betState = false
  end
end

-- Reset player bet states
function resetBetStates()
  for _, color in pairs(PLAYER_COLOR_STRINGS) do
    players[color].betState = false
  end
end

--[[
PlayerManager.lua END
]]

end)
__bundle_register("src/Notebook", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
Notebook.lua START

This file contains notebook-related functions.
]]

--                     !!! IMPORTANT INFORMATION ABOUT NOTEBOOKS !!!
--                     !!! IMPORTANT INFORMATION ABOUT NOTEBOOKS !!!
-- Can't just make you own Notebooks, make sure you start with the default 12 notebooks (Gr,Wh,Br,R,O,Y,B,B,T,Pu,Pi,Bl)
-- Each default notebook has an id which can't be changed with scripts. Ids are different from index and color
--      Source of discovery (sebaestschjin) https://tabletopsimulator.nolt.io/398
-- If you delete a default notebook, any new or old notebooks with a higher id can't be edited by the editNotebookTab() function
--      My guess is that when finding the notebook to edit, if an id is missing, then it just stops searching for notebooks
-- Another oddity is that you can't change the color with editNotebookTab(), and must do it manually in TableTop
-- You are able to have more than 12 notebooks that are editable, by keeping the 12 default (and editing them to your desire), then adding additional notebooks
--                     !!! IMPORTANT INFORMATION ABOUT NOTEBOOKS !!!
--                     !!! IMPORTANT INFORMATION ABOUT NOTEBOOKS !!!

-- Adds a new line to Rounds Notebook tab
function addRoundNote(note)
  local lineNumber = 1
  local lastRoundNum = getLatestRoundNumber()

  if lastRoundNum ~= nil then
    lineNumber = lastRoundNum + 1
  end

  -- Get the Notebook array, Get the Rounds Tab from index, get body of Rounds Tab
  -- Plus one because arrays count from 1, but Notebook Index counts from 0
  local roundsTabBody = Notes.getNotebookTabs()[ROUNDS_TAB_INDEX+1].body

  Notes.editNotebookTab({
    index = ROUNDS_TAB_INDEX,
    body = removeNewlinesFromEnd(roundsTabBody)..'\n'..lineNumber..': '..note
  })

  log('Adding \"'..note..'\" to Rounds on line '..lineNumber)
end

function getLatestRoundNumber()
  local roundsTabBody = Notes.getNotebookTabs()[ROUNDS_TAB_INDEX+1].body
  local roundNotePattern = "\n(%d+):[^\r\n]*[^\r\n%s]"
  local lastLine = roundsTabBody:match(".*("..roundNotePattern..")")

  if lastLine == nil then
    return nil
  end

  local lastRoundNumber = tonumber(lastLine:match(roundNotePattern))

  if lastRoundNumber == nil then
    return nil
  end

  return lastRoundNumber
end

function removeNewlinesFromEnd(str)
    return str:gsub("[\r\n]+$", "")
end

function resetRoundsNotebook()
  Notes.editNotebookTab({
    index = ROUNDS_TAB_INDEX,
    body = STARTING_ROUNDS_NOTEBOOK_LINE
  })
end

function addSummaryNote(note)
  local summaryNotes = Notes.getNotebookTabs()[SUMMARY_TAB_INDEX+1].body

  Notes.editNotebookTab({
    index = SUMMARY_TAB_INDEX,
    body = summaryNotes..'\n'..note
  })
end

--[[
Notebook.lua END
]]

end)
__bundle_register("src/Deck", function(require, _LOADED, __bundle_register, __bundle_modules)
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

end)
__bundle_register("src/Constants", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
Constants.lua START

This file contains global constants.
]]

BUTTON_GUID = '9fdc25'
FIELD_ZONE_GUID = '7a6e1a'
DECK_ZONE_GUID = '7f0e92'
WIN_PILE_GUID = {}
WIN_PILE_GUID['Blue'] = '4ca699'
WIN_PILE_GUID['Orange'] = 'c641a0'
HAND_GUID = {}
HAND_GUID['Blue'] = 'fd5538'
HAND_GUID['Orange'] = '48113c'
DISCARD_GUID = '7f3593'
DECK_BUILDER_GUID = 'b8db70'

SCORE_GUID = {}
SCORE_GUID['Blue'] = 'f1b2b4'
SCORE_GUID['Orange'] = '119183'
SCORE_GUID['Discard'] = '5cf4ba'

-- Value of face cards
FACE_CARD_VALUE = 10

-- Global table of card stats
stats = {}
stats['Ace'] = {1,1}
stats['2'] = {2,2}
stats['3'] = {20,3}
stats['4'] = {4,4}
stats['5'] = {5,5}
stats['6'] = {6,6}
stats['7'] = {7,7}
stats['8'] = {8,8}
stats['9'] = {9,9}
stats['10'] = {10,10}
stats['Jack'] = {FACE_CARD_VALUE,11}
stats['Queen'] = {FACE_CARD_VALUE,12}
stats['King'] = {FACE_CARD_VALUE,13}
stats['Joker'] = {0,0}

-- Player variables
PLAYER_COLOR_STRINGS = {'Orange', 'Blue'}

-- Game constants
STARTING_HAND_SIZE = 4

-- Notebook constants
ROUNDS_TAB_INDEX = 3 -- Index of Rounds Tab in Notebook
SUMMARY_TAB_INDEX = 4 -- Index of Summary Tab in Notebook
STARTING_ROUNDS_NOTEBOOK_LINE = 'Recording Round Data Here'

-- Colors
WHITE = {1, 1, 1}
BLACK = {0, 0, 0}
RED = {1, 0, 0}
BRIGHT_PURPLE = {212, 0, 255}

-- Button colors
BUTTON_BACKGROUND_COLOR = WHITE
BUTTON_TEXT_COLOR = BLACK
BUTTON_WARNING_BACKGROUND_COLOR = RED
BUTTON_WARNING_TEXT_COLOR = WHITE

-- Card color contants
FOUR_OF_A_KIND_HIGHLIGHT_COLOR = BRIGHT_PURPLE

-- Button attributes
SMALL_BUTTON_WIDTH = 900
STANDARD_BUTTON_WIDTH = 1200
BIG_BUTTON_WIDTH = 1500
SMALL_BUTTON_HEIGHT = 650
STANDARD_BUTTON_HEIGHT = 800
BUTTON_FONT_SIZE = 300

-- Button labels
DEFAULT_RESET_BUTTON_LABEL = 'Reset'

-- Reset button Constants
NUM_CLICKS_TO_RESET = 3
SECONDS_UNTIL_COUNTER_RESET = 2
SECONDS_UNTIL_RESET_DECK_SHUFFLE = 0.25

-- Discard constants
DISCARD_X_OFFSET = 6
DISCARD_Y_OFFSET = 5

-- Messages
PLAYER_HAS_NO_COLOR_BROADCAST_MESSAGE = 'The player does not have a color'
PLAYER_HAS_NO_COLOR_LOG_MESSAGE = 'A player with no color tried to press results button'
BET_BUTTON_TOOLTIP_MESSAGE = 'Bet to risk extra cards'

-- Shortcut constants
PLAY_CARD_X_OFFSET = 2
PLAY_CARD_Y_OFFSET = 3
PLAY_CARD_Z_OFFSET = 3

-- Misc
NUM_OF_ZONES_FOR_FIELD_CARDS = 1 -- The number of zones which a card on the field should be in
NUM_OF_ZONES_FOR_SPOILS_CARD = 1

-- Suit mappings
DEFAULT_SUIT_NAMES = {"diamond", "heart", "spade", "club"}

--[[
Constants.lua END
]]

end)
__bundle_register("src/Buttons/SumButton", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
SumButton.lua START

This file contains functions that the reset button triggers.
]]

function createSumButtons()
  createBlueSumButton()
  createOrangeSumButton()
  createDiscardSumButton()
end

function createBlueSumButton()
  createSumButton(players['Blue'].sumButtonPos, {0,0,0}, players['Blue'].winPile)
end

function createOrangeSumButton()
  createSumButton(players['Orange'].sumButtonPos, {0,180,0}, players['Orange'].winPile)
end

function createDiscardSumButton()
  createSumButton({11.4,1.15,0}, {0,270,0}, discardZone)
end

function createSumButton(position, rotation, function_owner)
  local sumButtonVars = {
    click_function='tableCalculatePoints',
    function_owner=function_owner,
    label='Sum',
    position=position,
    rotation=rotation,
    width=SMALL_BUTTON_WIDTH,
    height=SMALL_BUTTON_HEIGHT,
    font_size=BUTTON_FONT_SIZE,
    color=BUTTON_BACKGROUND_COLOR,
    font_color=BUTTON_TEXT_COLOR,
    tooltip="Click to find sum"
  }

  button.createButton(sumButtonVars)
end

--[[
SumButton.lua END
]]

end)
__bundle_register("src/Buttons/ResultsButton", function(require, _LOADED, __bundle_register, __bundle_modules)
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

end)
__bundle_register("src/Buttons/ResetButton", function(require, _LOADED, __bundle_register, __bundle_modules)
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
  numJokers = 0
end

--[[
ResetButton.lua END
]]

end)
__bundle_register("src/Buttons/DeckButton", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
DeckButton.lua START

This file contains functions that the reset button triggers.
]]

function createBuildDeckButton(deckBuilder)
  --Make Build Deck button (a button to assign Havoc values to cards)
  local bDeckBuilder_vars = {
    click_function='build',
    function_owner=deckBuilder,
    label='Build Deck',
    position={19,4,14},
    rotation={0,180,0},
    width=BIG_BUTTON_WIDTH,
    height=STANDARD_BUTTON_HEIGHT,
    font_size=BUTTON_FONT_SIZE,
    color=BUTTON_BACKGROUND_COLOR,
    font_color=BUTTON_TEXT_COLOR,
    tooltip="Spread cards here then click button to use custom decks"
  }

  button.createButton(bDeckBuilder_vars)
end

--[[
DeckButton.lua END
]]

end)
__bundle_register("src/Buttons/DealButton", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
DealButton.lua START

This file contains functions that the reset button triggers.
]]

function createDealButton()
  local bDeal_vars = {
    click_function='dealCards',
    function_owner=nil,
    label='Deal',
    position={7,3,0},
    rotation={0,90,0},
    width=STANDARD_BUTTON_WIDTH,
    height=STANDARD_BUTTON_HEIGHT,
    font_size=BUTTON_FONT_SIZE,
    color=BUTTON_BACKGROUND_COLOR,
    font_color=BUTTON_TEXT_COLOR,
    tooltip="Give players 4 cards"
  }

  button.createButton(bDeal_vars)
end

-- Deal 4 cards to both players, spawn buttons, and start planning phase
function dealCards()
  log('deal')
  dealDeck(STARTING_HAND_SIZE)
  -- Remove Deal and Deck Builder buttons
  button.clearButtons()
  createBetButtons()
  createResultsButton()
  createClearButton()
  --createSumButtons() --Added Score Counters
  createResetButton(DEFAULT_RESET_BUTTON_LABEL)
  gameStarted = true
end

--[[
DealButton.lua END
]]

end)
__bundle_register("src/Buttons/ClearButton", function(require, _LOADED, __bundle_register, __bundle_modules)
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

end)
__bundle_register("src/Buttons/ButtonManager", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
ButtonManager.lua START

This file contains functions for modifying or checking button state.
]]

-- Removes button with specific position (because removeButton() only works with indexes)
function deleteButtonHere(position)
  for i, b in pairs(button.getButtons()) do
    if button.positionToWorld(b.position) == button.positionToWorld(position) then -- So that both positions will match
      button.removeButton(i-1) -- The corresponding index (because indexes start at 1)
      break
    end
  end
end

--[[
ButtonManager.lua END
]]

end)
__bundle_register("src/Buttons/BetButton", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
BetButton.lua START

This file contains functions that the reset button triggers.
]]

-- Makes bet button for players
function createBetButtons()
  createBetButton('Blue')
  createBetButton('Orange')
end

-- Make button for specified player
function createBetButton(color)
  local bet_function = nil

  if color == 'Blue' then
    bet_function = 'blueBet'
  elseif color == 'Orange' then
    bet_function = 'orangeBet'
  end

  local bBet_vars = {
    click_function=bet_function,
    function_owner=nil,
    label='Bet',
    position=players[color].betPos,
    rotation={0,90,0},
    width=STANDARD_BUTTON_WIDTH,
    height=STANDARD_BUTTON_HEIGHT,
    font_size=BUTTON_FONT_SIZE,
    color=BUTTON_BACKGROUND_COLOR,
    font_color=BUTTON_TEXT_COLOR,
    tooltip=BET_BUTTON_TOOLTIP_MESSAGE
  }

  button.createButton(bBet_vars)
end

-- Check if bet buttons exist, if not re-create them
function regenerateBetButtons()
  for _, color in pairs(PLAYER_COLOR_STRINGS) do
    if doesBetButtonExist(color) == false then
      log('Creating '..color..' bet button again')
      createBetButton(color)
    end
  end
end

function doesBetButtonExist(color)
  buttonPosition = button.positionToWorld(players[color].betPos)

  for i, b in pairs(button.getButtons()) do
    if button.positionToWorld(b.position) == buttonPosition then
      log(color..' bet button found')
      return true
    end
  end

  return false
end

function playerBet(player_color, bet_color)
  if player_color ~= bet_color then
    local logMessage = getColorSpecificLogMessage(player_color, bet_color)
    log(logMessage)
    local broadcastMessage = getColorSpecificGlobalMessage(bet_color)
    broadcastToAll(broadcastMessage)
    return
  end

  if players[bet_color].betState == true then
    log(player_color..' already bet this round')
    return
  end

  if getDeck() ~= nil then
    log('Player '..bet_color..' bets')
    moveCardToBetZone(bet_color)
    players[bet_color].betState = true
    local betPlacement = players[bet_color].betPos
    deleteButtonHere(betPlacement)
  end
end

function moveCardToBetZone(bet_color)
  -- Bet button's place and bet card's place are the same
  local betPlacement = players[bet_color].betPos
  local deck = getDeck()

  if deck == nil then
    return
  end

  deck.takeObject({
    --Have to flip x cordinate because the takeObject position flips the x value
    position = {-betPlacement[1],betPlacement[2],betPlacement[3]},
    rotation = {0,0,0},
    flip = true
  })
end

function getColorSpecificLogMessage(playerColor, expectedColor)
  return playerColor..' player tried using a button that only '..expectedColor..' player can use'
end

function getColorSpecificGlobalMessage(expectedColor)
  return 'Only '..expectedColor..' player can use this button'
end

function orangeBet(obj, color, alt_click)
  playerBet(color, 'Orange')
end

function blueBet(obj, color, alt_click)
  playerBet(color, 'Blue')
end

--[[
BetButton.lua END
]]

end)
__bundle_register("src/Utility/Messaging", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
Messaging.lua START

This file contains functions that the reset button triggers.
]]

function broadcast(message)
  broadcastToAll(message)
  log(message)
end

--[[
Messaging.lua END
]]

end)
__bundle_register("src/Utility/StringConverter", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
StringConverter.lua START

This file contains functions that the reset button triggers.
]]

function positionToString(position)
  return '['..position[1]..', '..position[2]..', '..position[3]..']'
end

function tableToString(table)
  local tableStr = ""
  local itemNum = 0

  for index, value in ipairs(table) do
    itemNum = itemNum + 1

    if itemNum > 1 then
      tableStr = tableStr .. ", "
    end

    tableStr = tableStr .. "[" .. index .. ", " .. value .. "]"
  end
end

--[[
StringConverter.lua END
]]

end)
__bundle_register("src/Utility/ListManager", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
ListManager.lua START

This file contains functions to help with handling lists
]]

-- Return true if the given value is in the list. False otherwise
function contains(list, value)
    for i = 1, #list do
        if list[i] == value then
            return true
        end
    end

    return false
end

-- Return a copy of the list without the given value
function copyWithException(list, excludeValue)
    local newList = {}

    for i = 1, #list do
        if list[i] ~= excludeValue then
            table.insert(newList, list[i])
        end
    end

    return newList
end

--[[
ListManager.lua END
]]

end)
return __bundle_require("Global.-1.lua")