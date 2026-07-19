--[[
Timer.lua START

This file contains functions for timing other functions.
]]

-- Takes in a time value that represents when the function starts
function logElapsedTime(startTime, funcName)
  if startTime ~= nil and funcName ~= nil then
    local elapsedTime = round(os.clock() - startTime)
    log("Elapsed time for [" .. funcName .."]: " .. elapsedTime .. "s")
  end
end

-- Not for general use, only for a specific timing case
function round(num)
  return math.floor(num * 10^6 + 0.5) * 10^-6
end

--[[
Timer.lua END
]]
