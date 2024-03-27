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
