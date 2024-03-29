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
