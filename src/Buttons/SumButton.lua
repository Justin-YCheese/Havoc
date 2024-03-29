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
