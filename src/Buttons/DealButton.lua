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
