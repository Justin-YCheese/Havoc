--Blue's win pile
owner = 'Blue'

-- Table of common zone variables
zone_vars = Global.getTable('zone_vars')

--Table of card stats
stats = Global.getTable('stats')

function onLoad()
  self.LayoutZone.setOptions(zone_vars)
end

function tableCalculatePoints()
  params = {
    zoneObjects = self.getObjects(), -- Get items in the zone
    zoneName = owner
  }
  Global.call('calculatePointsPrint',params) -- Use function in global
end

function tableCalculatePointsFromObjects()
  params = {
    zoneObjects = self.getObjects(), -- Get items in the zone
    zoneName = owner
  }
  Global.call('calculatePointsFromObjectsPrint',params) -- Use function in global
end