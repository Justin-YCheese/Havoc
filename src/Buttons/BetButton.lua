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
