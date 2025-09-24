--Table of card stats
stats = Global.getTable('stats')

function onLoad() -- Create Button
  self.createButton(button_vars)
end

function build() -- For assigning values to cards when they are spread out
  local zoneObjects = self.getObjects()
  for i, item in pairs(zoneObjects) do
    if item.tag == 'Card' then
      local name = item.getName()
      if item.getVar('value') ~= nil then -- Testing for variable (variable disapears when put in a deck)
        log('   The value is already '..item.getVar('value'))
      end
      log(name..' assigned '..stats[name][1].." and "..stats[name][2])
      -- set value and power of card by giving it Lua script
      -- This is because using setVar() won't keep variable if put in a deck
      item.setLuaScript('value='..stats[name][1]..'\npower='..stats[name][2])
      --log(item.getVar('value')..' is the value')
    end
  end
end