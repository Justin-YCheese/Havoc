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

  local roundsTabBody = Notes.getNotebookTabs()[ROUNDS_TAB_INDEX+1].body
  local lineNumber = 1
  local lastRoundNum = getLatestRoundNumber()

  if lastRoundNum != nil then
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
