-- intelliMine
-- by LolHens

tArgs = {...}

action = {
  go = {
    forward = turtle.forward,
    up = turtle.up,
    down = turtle.down,
    back = turtle.back,
  },
  turn = {
    left = turtle.turnLeft,
    right = turtle.turnRight,
  },
  dig = {
    forward = turtle.dig,
    up = turtle.digUp,
    down = turtle.digDown,
  },
  place = {
    forward = turtle.place,
    up = turtle.placeUp,
    down = turtle.placeDown,
  },
  drop = {
    forward = turtle.drop,
    up = turtle.dropUp,
    down = turtle.dropDown,
  },
  detect = {
    forward = turtle.detect,
    up = turtle.detectUp,
    down = turtle.detectDown,
  },
  compare = {
    forward = turtle.compare,
    up = turtle.compareUp,
    down = turtle.compareDown,
  },
  attack = {
    forward = turtle.attack,
    up = turtle.attackUp,
    down = turtle.attackDown,
  },
  suck = {
    forward = turtle.suck,
    up = turtle.suckUp,
    down = turtle.suckDown,
  },
  equip = {
    left = turtle.equipLeft,
    right = turtle.equipRight,
  },
  inspect = {
    forward = turtle.inspect,
    up = turtle.inspectUp,
    down = turtle.inspectDown,
  },
}

function rotationOffsetBy(rotation, other)
  if not rotation or not other then return end
  
  return (rotation + other + 4) % 4
end

function rotationLeft(rotation)
  return rotationOffsetBy(rotation, -1)
end

function rotationRight(rotation)
  return rotationOffsetBy(rotation, 1)
end

function rotationBack(rotation)
  return rotationOffsetBy(rotation, 2)
end

function rotationOffsetTo(rotation, other)
  if not rotation or not other then return end
  
  return (other - rotation + 4) % 4
end

function rotateBy(rotation)
  rotation = rotationOffsetBy(rotation, 0)
  if rotation == 3 then return action.turn.left() end
  for i = 1, rotation do
    if not action.turn.right() then return false end
  end
  return true
end

function Vec(x, y, z)
  if not x and not y and not z then
    x, y, z = 0, 0, 0
  elseif not y and not z then
    y, z = x, x
  elseif not z then
    return
  end
  
  return {
    x = x,
    y = y,
    z = z,
    copy = function(self)
      return Vec(self.x, self.y, self.z)
    end,
    withX = function(self, x)
      return Vec(x, self.y, self.z)
    end,
    withY = function(self, y)
      return Vec(self.x, y, self.z)
    end,
    withZ = function(self, z)
      return Vec(self.x, self.y, z)
    end,
    isNull = function(self)
      return (not self.x or self.x == 0) and (not self.y or self.y == 0) and (not self.z or self.z == 0)
    end,
    isAt = function(self, other)
      if not other then return nil end
      
      return (not self.x or not other.x or self.x == other.x) and (not self.y or not other.y or self.y == other.y) and (not self.z or not other.z or self.z == other.z)
    end,
    offsetBy = function(self, other)
      if not other then return end
      
      return Vec(self.x and other.x and (self.x + other.x), self.y and other.y and (self.y + other.y), self.z and other.z and (self.z + other.z))
    end,
    offsetTo = function(self, other)
      if not other then return end
      
      return Vec(self.x and other.x and (other.x - self.x), self.y and other.y and (other.y - self.y), self.z and other.z and (other.z - self.z))
    end,
    times = function(self, value)
      if not value then return end
      
      if value == 1 then return self end
      return Vec(self.x and self.x * value, self.y and self.y * value, self.z and self.z * value)
    end,
    length2 = function(self)
      return (self.x and (self.x * self.x) or 0) + (self.y and (self.y * self.y) or 0) + (self.z and (self.z * self.z) or 0)
    end,
    xzRotation = function(self)
      if self.x == 0 and self.z < 0 then return 0 end
      if self.x > 0 and self.z == 0 then return 1 end
      if self.x == 0 and self.z > 0 then return 2 end
      if self.x < 0 and self.z == 0 then return 3 end
      return
    end,
    nextStep = function(self)
      if self.y and (not self.x or math.abs(self.x) <= math.abs(self.y)) and (not self.z or math.abs(self.z) <= math.abs(self.y)) then
        return Vec(0, self.y >= 1 and 1 or self.y <= -1 and -1 or 0, 0)
      elseif self.x and (not self.z or math.abs(self.z) <= math.abs(self.x)) then
        return Vec(self.x >= 1 and 1 or self.x <= -1 and -1 or 0, 0, 0)
      elseif self.z then
        return Vec(0, 0, self.z >= 1 and 1 or self.z <= -1 and -1 or 0)
      end
      return Vec(0, 0, 0)
    end,
    string = function(self)
      return "{x="..(self.x or "nil")..",y="..(self.y or "nil")..",z="..(self.z or "nil").."}"
    end,
  }
end

offset = {
  up = function()
    return Vec(0, 1, 0)
  end,
  down = function()
    return Vec(0, -1, 0)
  end,
  forward = function(rotation)
    rotation = rotationOffsetBy(rotation, 0)
    if rotation == 0 then return Vec(0, 0, -1) end
    if rotation == 1 then return Vec(1, 0, 0) end
    if rotation == 2 then return Vec(0, 0, 1) end
    if rotation == 3 then return Vec(-1, 0, 0) end
    return
  end,
  left = function(rotation)
    return offset.forward(rotationLeft(rotation))
  end,
  right = function(rotation)
    return offset.forward(rotationRight(rotation))
  end,
  back = function(rotation)
    return offset.forward(rotationBack(rotation))
  end,
}

function isItemIn(item, list)
  if not item or not list then return end
  
  for _, entry in ipairs(list) do
    if item.name == entry then return true end
    for tag, _ in pairs(item.tags) do
      if tag == entry then return true end
    end
  end
  return false
end

--   80 coal
-- 1000 lava
refuelQuota = 1000

function getRefuelThreshold(refuelMin)
  local refuelMax = turtle.getFuelLimit() - refuelQuota
  local refuelThreshold = refuelMin
  if not refuelThreshold then refuelThreshold = refuelMax / 2 end
  return refuelThreshold, refuelMax
end

function refuel(refuelMin)
  local refuelThreshold, refuelMax = getRefuelThreshold(refuelMin)
  if not refuelMin then refuelMin = 1 end
  
  if turtle.getFuelLevel() < refuelThreshold then
    local selected = turtle.getSelectedSlot()
    for i = 1, 16 do
      if isItemIn(turtle.getItemDetail(i, true), {"minecraft:lava_bucket", "minecraft:coals", "minecraft:coal_block"}) then
        turtle.select(i)
        while turtle.getFuelLevel() < refuelMax and turtle.refuel(1) do end
        if turtle.getFuelLevel() >= refuelMax then break end
      end
    end
    turtle.select(selected)
  end
  
  return turtle.getFuelLevel() >= refuelMin
end

function forceAction(forcedAction, dig, attack)
  if dig == nil then dig = true end
  if attack == nil then attack = true end
  
  local function force(direction, ...)
    if not refuel(1) then return false end
    
    local function tryRecover()
      if action.detect[direction]() then
        if dig and action.dig[direction]() then return true end
      elseif attack and action.attack[direction]() then
        return true
      end
      
      return false
    end
    
    local failed = false
    for i = 1, 1000 do
      if forcedAction[direction](...) then return true end
      
      if not tryRecover() then
        if failed then return false end
        failed = true
      else
        failed = false
      end
      
      sleep(0.2)
    end
    
    return false
  end
  
  local function forceBack(keepRotation, ...)
    if not refuel(1) then return false end
    
    if forcedAction.back and forcedAction.back(...) then return true end
    
    rotateBy(2)
    local result = force("forward", ...)
    if keepRotation then
      rotateBy(2)
    end
    return result
  end
  
  return {
    forward = function(...) return force("forward", ...) end,
    up = function(...) return force("up", ...) end,
    down = function(...) return force("down", ...) end,
    back = function(...) return forceBack(true, ...) end,
    backAnyRotation = function(...) return forceBack(false, ...) end,
  }
end

locate = (function()
  local actionDelegate = action
  
  return function()
    local position = Vec(gps.locate())
    
    local function rotationByMove(go, rotationOffset)
      if not rotationOffset then rotationOffset = 0 end
      
      if not refuel(2) then return end
      
      local offsetPosition = position:copy()
      
      if go.forward() then
        offsetPosition = Vec(gps.locate())
        go.back()
      elseif go.back() then
        offsetPosition = Vec(gps.locate())
        rotationOffset = rotationBack(rotationOffset)
        go.forward()
      end
      
      return rotationOffsetBy(position:offsetTo(offsetPosition):xzRotation(), rotationOffset)
    end
    
    local rotation = rotationByMove(actionDelegate.go)
    if rotation then return position, rotation end
    
    rotateBy(1)
    rotation = rotationByMove(actionDelegate.go, 3)
    rotateBy(-1)
    if rotation then return position, rotation end
    
    local forceGo = forceAction(actionDelegate.go)
    
    rotation = rotationByMove(actionDelegate.go) or rotationByMove(forceGo)
    if rotation then return position, rotation end
    
    rotateBy(1)
    rotation = rotationByMove(actionDelegate.go, 3) or rotationByMove(forceGo, 3)
    rotateBy(-1) 
    return position, rotation
  end
end)()

globalPosition, globalRotation = nil, nil

offset.forward = (function()
  local delegate = offset.forward
  
  return function(rotation)
    if not rotation then rotation = globalRotation end
    
    return delegate(rotation)
  end
end)()

offset.left = (function()
  local delegate = offset.left
  
  return function(rotation)
    if not rotation then rotation = globalRotation end
    
    return delegate(rotation)
  end
end)()

offset.right = (function()
  local delegate = offset.right
  
  return function(rotation)
    if not rotation then rotation = globalRotation end
    
    return delegate(rotation)
  end
end)()

offset.back = (function()
  local delegate = offset.back
  
  return function(rotation)
    if not rotation then rotation = globalRotation end
    
    return delegate(rotation)
  end
end)()

function isAt(position)
  return globalPosition:isAt(position)
end

function offsetTo(position)
  return globalPosition:offsetTo(position)
end

function offsetBy(vector)
  return globalPosition:offsetBy(vector)
end

updateGlobalPositionAndRotation = {
  forward = function()
    globalPosition = globalPosition:offsetBy(offset.forward(globalRotation))
  end,
  up = function()
    globalPosition = globalPosition:offsetBy(Vec(0, 1, 0))
  end,
  down = function()
    globalPosition = globalPosition:offsetBy(Vec(0, -1, 0))
  end,
  back = function()
    globalPosition = globalPosition:offsetBy(offset.back(globalRotation))
  end,
  left = function()
    globalRotation = rotationLeft(globalRotation)
  end,
  right = function()
    globalRotation = rotationRight(globalRotation)
  end,
}

action = (function()
  local delegate = action
  
  function goTracked(direction)
    if delegate.go[direction]() then
      updateGlobalPositionAndRotation[direction]()
      return true
    end
    return false
  end
  
  function turnTracked(direction)
    if delegate.turn[direction]() then
      updateGlobalPositionAndRotation[direction]()
      return true
    end
    return false
  end
  
  local result = {}
  for k, v in pairs(delegate) do result[k] = v end
  result.go = {
    forward = function() return goTracked("forward") end,
    up = function() return goTracked("up") end,
    down = function() return goTracked("down") end,
    back = function() return goTracked("back") end,
  }
  result.turn = {
    left = function() return turnTracked("left") end,
    right = function() return turnTracked("right") end,
  }
  return result
end)()

function rotateTo(rotation)
  return rotateBy(rotationOffsetTo(globalRotation, rotation))
end

function moveStepBy(go, vector)
  local step = vector:nextStep()
  local rotationOffset = rotationOffsetTo(globalRotation, step:xzRotation())
  
  if step:isNull() then
    return true
  elseif rotationOffset == 2 then
    return (go.backAnyRotation or go.back)()
  elseif rotationOffset then
    rotateBy(rotationOffset)
    return go.forward()
  elseif step.y > 0 then
    return go.up()
  elseif step.y < 0 then
    return go.down()
  end
end

function moveStepDirectionBy(go, vector)
  local step = vector:nextStep()
  if step:isNull() then return true end
  repeat
    if moveStepBy(go, step) then return true end
    vector = Vec(step.x == 0 and vector.x or 0, step.y == 0 and vector.y or 0, step.z == 0 and vector.z or 0)
    step = vector:nextStep()
  until step:isNull()
  return false
end

function forceMoveStepBy(vector, dig, attack)
  local forceGo = forceAction(action.go, false, attack)
  if moveStepDirectionBy(forceGo, vector) then return true end
  if dig then
    forceGo = forceAction(action.go, true, attack)
    if moveStepDirectionBy(forceGo, vector) then return true end
  end
  if vector:nextStep().y < 1 then
    local xzVector = vector:withY(nil)
    while forceGo.up() do
      if moveStepDirectionBy(forceGo, xzVector) then return true end
    end
  end
  return false
end

function moveTo(position, dig, attack)
  while not isAt(position) do
    if not forceMoveStepBy(offsetTo(position), dig, attack) then return false end
  end
  return true
end

function DigStack()
  return {
    size = function(self)
      local i = 1
      while self[i] do i = i + 1 end
      return i - 1
    end,
    isEmpty = function(self)
      return self[1] == nil
    end,
    push = function(self, position, rotation)
      local i = 1
      while self[i] do
        if self[i].x == position.x and self[i].y == position.y and self[i].z == position.z then
          if self[i].r == nil then self[i].r = rotation end
          return
        end
        i = i + 1
      end
      self[i] = {
        x = position.x,
        y = position.y,
        z = position.z,
        r = rotation
      }
    end,
    pop = function(self)
      local i = self:size()
      local position, rotation = self[i] and Vec(self[i].x, self[i].y, self[i].z), self[i] and self[i].r
      if self[i] then self[i] = nil end
      return position, rotation
    end,
    popNearest = function(self, position, lastN)
      local i = 1
      if lastN then
        local size = self:size()
        if size > lastN then i = size - lastN end
      end
      local nearestIndex, nearest = nil, nil
      while self[i] do
        local length = position:offsetTo(self[i]):length2()
        if not nearest or length <= nearest then
          nearest = length
          nearestIndex = i
        end
        i = i + 1
      end
      if nearestIndex then
        local position, rotation = Vec(self[nearestIndex].x, self[nearestIndex].y, self[nearestIndex].z), self[nearestIndex].r
        local i = nearestIndex
        while self[i] do
          self[i] = self[i + 1]
          i = i + 1
        end
        return position, rotation
      end
      return
    end,
  }
end

digStack = DigStack()

enderChestSlot = 1
chunkLoaderSlot = 2
bucketSlot = 3
itemSlots = 4

function shouldDump()
  for slot = itemSlots, 16 do
    if turtle.getItemCount(slot) == 0 then return false end
  end
  return true
end

function placeEnderChest()
  if turtle.getItemDetail(enderChestSlot) then
    local selected = turtle.getSelectedSlot()
    turtle.select(enderChestSlot)
    local result = forceAction(action.place).up()
    turtle.select(selected)
    return result
  end
  return false
end

function takeEnderChest()
  if not turtle.getItemDetail(enderChestSlot) then
    local selected = turtle.getSelectedSlot()
    turtle.select(enderChestSlot)
    local result = action.dig.up()
    turtle.select(selected)
    return result
  end
  return false
end

function dumpItems()
  refuel()
  local enderChestPlaced = placeEnderChest()
  while true do
    if enderChestPlaced then
      for i = itemSlots, 16 do
        turtle.select(i)
        action.drop.up()
      end
    end
    if not shouldDump() then break end
    sleep(1)
  end
  return takeEnderChest()
end

function placeChunkLoader(position)
  moveTo(position, true)
  local selected = turtle.getSelectedSlot()
  turtle.select(chunkLoaderSlot)
  local chunkLoaderName = (turtle.getItemDetail(chunkLoaderSlot, true) or {}).name
  local success, chunkLoaderItem = action.inspect.up()
  if not (chunkLoaderName and success and chunkLoaderItem.name == chunkLoaderName) then
    forceAction(action.place).up()
  end
  turtle.select(selected)
  return chunkLoaderName
end

function takeChunkLoader(chunkLoaderName, position)
  moveTo(position, true)
  local selected = turtle.getSelectedSlot()
  turtle.select(chunkLoaderSlot)
  local chunkLoaderItem = turtle.getItemDetail(chunkLoaderSlot, true)
  if chunkLoaderName and chunkLoaderItem and chunkLoaderItem.name ~= chunkLoaderName then
    action.drop.up()
  end
  action.dig.up()
  turtle.select(selected)
end

function loadList(fileName, create)
  if not fs.exists(fileName) then
    if create then
      io.open(fileName, "w"):close()
    end
    return
  end
  local file = io.open(fileName, "r")
  local list = {}
  local entry = nil
  local i = 1
  while true do
    entry = file:read("*l")
    if not entry then
      break
    elseif entry ~= "" then
      list[i] = entry
      i = i + 1
    end
  end
  file:close()
  return list
end

local oreList = loadList("ores.txt", true)

isOre = (function()
  local function isOre(direction)
    local success, item = action.inspect[direction]()
    -- lava source
    if success and item.name == "minecraft:lava" and item.state.level == 0 then
      local item = turtle.getItemDetail(bucketSlot, true)
      if item and item.name == "minecraft:bucket" then
        local selected = turtle.getSelectedSlot()
        turtle.select(bucketSlot)
        if item.count > 1 then action.drop.up(item.count - 1) end
        action.place[direction]()
        turtle.select(selected)
        return false
      end
    end
    return isItemIn(success and item, oreList)
  end
  
  return {
    forward = function() return isOre("forward") end,
    up = function() return isOre("up") end,
    down = function() return isOre("down") end,
  }
end)()

function queueSurroundingOres(keepRotation, skipRotation)
  if keepRotation == nil then keepRotation = true end
  
  local function queueOre(direction)
    if isOre[direction]() then
      digStack:push(offsetBy(offset[direction]()))
      return true
    end
    return false
  end
  
  local result = false
  for i = 1, 4 do
    if not keepRotation and i == 3 and skipRotation and skipRotation == rotationRight(globalRotation) then break end
    result = queueOre("forward") or result
    if keepRotation or i < 4 then rotateBy(1) end
  end
  result = queueOre("up") or result
  result = queueOre("down") or result
  return result
end

function mine(count, position, rotation, startOffset)
  if not count then count = 0 end
  if not position then position = globalPosition end
  if not rotation then rotation = globalRotation end
  
  local offsetForward = offset.forward(rotation)
  if startOffset then position = position:offsetBy(offsetForward:times(startOffset)) end
  for i = count, 0, -1 do
    local minePos = position:offsetBy(offsetForward:times(i))
    digStack:push(minePos:offsetBy(offset.up()))
    digStack:push(minePos)
  end
  
  while not digStack:isEmpty() do
    local nextPosition, nextRotation = digStack:popNearest(globalPosition, 5)
    if shouldDump() then dumpItems() end
    turtle.select(itemSlots)
    -- TODO: suck
    local off = position:offsetTo(nextPosition)
    local onPath = (off.y == 0 or off.y == 1) and ((off.x == 0 and off.z ~= 0) or (off.x ~= 0 and off.z == 0))
    while not moveTo(nextPosition, true) do
      if turtle.getFuelLevel() > 0 then break end
      while not refuel() do
        print("ERROR: out of fuel!")
      end
    end
    queueSurroundingOres(false, onPath and rotationBack(rotation))
    if nextRotation then rotateTo(nextRotation) end
  end
  
  return position:offsetBy(offsetForward:times(count)), rotation
end

local minePosFile = ".minepos"

function saveMinePos(position, rotation, segment)
  local file = io.open(minePosFile, "w")
  file:write(position.x.."\n")
  file:write(position.y.."\n")
  file:write(position.z.."\n")
  file:write(rotation.."\n")
  file:write(segment.."\n")
  file:flush()
  file:close()
end

function loadMinePos()
  if not fs.exists(minePosFile) then
    return
  end
  local file = io.open(minePosFile, "r")
  local x = tonumber(file:read("*l"))
  local y = tonumber(file:read("*l"))
  local z = tonumber(file:read("*l"))
  local r = tonumber(file:read("*l"))
  local s = tonumber(file:read("*l"))
  file:close()
  return x and y and z and Vec(x, y, z), r, s
end

function stripmine(position, rotation, segment, depth, length)
  if not segment then segment = 1 end
  
  moveTo(position, true)
  if rotation then rotateTo(rotation) end
  
  local i = 1
  while not length or i <= length do
    saveMinePos(position, rotation, segment)
    
    local left, right
    if segment == 1 then
      left = rotationLeft(rotation)
      right = rotationRight(rotation)
      segment = 2
    elseif segment == 2 then
      left = rotationRight(rotation)
      right = rotationLeft(rotation)
      segment = 1
    end
    
    mine(0, position, rotation, 1)
    local chunkLoaderName = placeChunkLoader(position:offsetBy(offset.forward(rotation):times(2)))
    takeChunkLoader(chunkLoaderName, position:offsetBy(offset.back(rotation)))
    mine(0, position, rotationBack(rotation), 1)
    position = mine(depth, position, right, 1)
    position = mine(2, position, rotation, 1)
    position = mine(depth, position, left, 1)
    
    i = i + 1
  end
end

function main()
  local depth=tonumber(tArgs[1])
  local length=tonumber(tArgs[2])
  
  if depth==nil then depth=30 end
  
  print("intelliMine by LolHens")
  print("Stripmining "..depth.." block long tunnels")
  
  refuel()
  
  while true do
    globalPosition, globalRotation = locate()
    if globalRotation then break end
    
    if refuel(2) then
      print("ERROR: gps localization failed!")
    else
      print("ERROR: out of fuel!")
    end
    
    sleep(1)
  end
  
  print("Position: "..globalPosition:string().." "..globalRotation)
  
  local position, rotation, segment = loadMinePos()
  if not position or not rotation then
    position = globalPosition
    rotation = globalRotation
  end
  
  if not position.isAt(globalPosition) or rotation ~= globalRotation then
    print("Resuming: "..position:string().." "..rotation)
  end
  
  takeEnderChest()
  
  stripmine(position, rotation, segment, depth, length)
end

main()