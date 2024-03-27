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
