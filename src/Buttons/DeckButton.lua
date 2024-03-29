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
