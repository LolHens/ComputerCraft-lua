-- intelliMine
-- by LolHens

tArgs = {...}

local turtleRaw = {
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

local function isInWhitelist(detail, whitelist)
  if not detail or not whitelist then return nil end
  
  for _, entry in ipairs(whitelist) do
    if detail.name == entry then return true end
    for tag, _ in pairs(detail.tags) do
      if tag == entry then return true end
    end
  end
  return false
end

local function refuel(refuelMin)
  local limit = turtle.getFuelLimit()
  local refuelMax = limit - 100
  local refuelThreshold = refuelMin
  if not refuelThreshold then refuelThreshold = limit / 2 end
  if not refuelMin then refuelMin = 1 end
  
  if turtle.getFuelLevel() < refuelThreshold then
    local selected = turtle.getSelectedSlot()
    for i = 1, 16 do
      if isInWhitelist(turtle.getItemDetail(i, true), {"minecraft:coals"}) then
        turtle.select(i)
        while turtle.getFuelLevel() < refuelMax and turtle.refuel(1) do end
        if turtle.getFuelLevel() >= refuelMax then break end
      end
    end
    turtle.select(selected)
  end
  
  return turtle.getFuelLevel() >= refuelMin
end

local function turtleForceGo(dig, attack)
  if dig == nil then dig = false end
  if attack == nil then attack = true end
  
  local function forceGo(direction)
    if not refuel(1) then return false end
    
    local function tryRecover()
      if turtleRaw.detect[direction]() then
        if dig and turtleRaw.dig[direction]() then return true end
      elseif attack and turtleRaw.attack[direction]() then
        return true
      end
      
      return false
    end
    
    local failed = false
    for i = 1, 1000 do
      if turtleRaw.go[direction]() then return true end
      
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
  
  local function forceGoBack(keepRotation)
    if not refuel(1) then return false end
    
    if turtleRaw.go.back() then return true end
    
    turtleRaw.turn.right()
    turtleRaw.turn.right()
    local result = forceGo("forward")
    if keepRotation then
      turtleRaw.turn.left()
      turtleRaw.turn.left()
    end
    return result
  end
 
  return {
    forward = function() return forceGo("forward") end,
    up = function() return forceGo("up") end,
    down = function() return forceGo("down") end,
    back = function() return forceGoBack(true) end,
    backAnyRotation = function() return forceGoBack(false) end,
  }
end

local function rotationOffsetBy(rotation, other)
  if not rotation or not other then return nil end
  
  return (rotation + other + 4) % 4
end

local function rotationOffsetTo(rotation, other)
  if not rotation or not other then return nil end
  
  return (other - rotation + 4) % 4
end

local function Vec(x, y, z)
  if not x and not y and not z then
    x, y, z = 0, 0, 0
  elseif not y and not z then
    y, z = x, x
  elseif not z then
    return nil
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
      if not other then return nil end
      
      return Vec(self.x and other.x and (self.x + other.x), self.y and other.y and (self.y + other.y), self.z and other.z and (self.z + other.z))
    end,
    offsetTo = function(self, other)
      if not other then return nil end
      
      return Vec(self.x and other.x and (other.x - self.x), self.y and other.y and (other.y - self.y), self.z and other.z and (other.z - self.z))
    end,
    xzRotation = function(self)
      if self.x == 0 and self.z < 0 then return 0 end
      if self.x > 0 and self.z == 0 then return 1 end
      if self.x == 0 and self.z > 0 then return 2 end
      if self.x < 0 and self.z == 0 then return 3 end
      return nil
    end,
    offsetByRotation = function(self, rotation)
      rotation = rotationOffsetBy(rotation, 0)
      if rotation == 0 then return Vec(self.x, self.y, self.z - 1) end
      if rotation == 1 then return Vec(self.x + 1, self.y, self.z) end
      if rotation == 2 then return Vec(self.x, self.y, self.z + 1) end
      if rotation == 3 then return Vec(self.x - 1, self.y, self.z) end
      return nil
    end,
    step = function(self)
      if self.y and (not self.x or math.abs(self.x) <= math.abs(self.y)) and (not self.z or math.abs(self.z) <= math.abs(self.y)) then
        return Vec(0, self.y / math.abs(self.y), 0)
      elseif self.x and (not self.z or math.abs(self.z) <= math.abs(self.x)) then
        return Vec(self.x / math.abs(self.x), 0, 0)
      elseif self.z then
        return Vec(0, 0, self.z / math.abs(self.z))
      end
      return nil
    end,
    string = function(self)
      return "{x="..self.x..",y="..self.y..",z="..self.z.."}"
    end,
  }
end

local offset = {
  up = function()
    return Vec(0, 1, 0)
  end,
  down = function()
    return Vec(0, -1, 0)
  end,
}

local function locate()
  local position = Vec(gps.locate())
  
  local function rotationByMove(go, rotationOffset)
    if not rotationOffset then rotationOffset = 0 end
    
    if not refuel(2) then return nil end
    
    local offsetPosition = position:copy()
    
    if go.forward() then
      offsetPosition = Vec(gps.locate())
      go.back()
    elseif go.back() then
      offsetPosition = Vec(gps.locate())
      rotationOffset = rotationOffsetBy(rotationOffset, 2)
      go.forward()
    end
    
    return rotationOffsetBy(position:offsetTo(offsetPosition):xzRotation(), rotationOffset)
  end
  
  local rotation = rotationByMove(turtleRaw.go)
  if not rotation then
    turtleRaw.turn.right()
    rotation = rotationByMove(turtleRaw.go, 3)
    turtleRaw.turn.left()
  end
  if not rotation then
    local forceGo = turtleForceGo(true)
    
    rotation = rotationByMove(forceGo)
    if not rotation then
      turtleRaw.turn.right()
      rotation = rotationByMove(forceGo, 3)
      turtleRaw.turn.left()
    end
  end
  
  return position, rotation
end

globalPosition, globalRotation = locate()

offset.forward = function()
  return Vec():offsetByRotation(globalRotation)
end

local function isAt(position)
  return globalPosition:isAt(position)
end

local function offsetTo(position)
  return globalPosition:offsetTo(position)
end

local function offsetBy(vector)
  return globalPosition:offsetBy(vector)
end

local updateGlobalPositionAndRotation = {
  forward = function()
    globalPosition = globalPosition:offsetByRotation(globalRotation)
  end,
  up = function()
    globalPosition = globalPosition:offsetBy(Vec(0, 1, 0))
  end,
  down = function()
    globalPosition = globalPosition:offsetBy(Vec(0, -1, 0))
  end,
  back = function()
    globalPosition = globalPosition:offsetByRotation(rotationOffsetBy(globalRotation, 2))
  end,
  left = function()
    globalRotation = rotationOffsetBy(globalRotation, 3)
  end,
  right = function()
    globalRotation = rotationOffsetBy(globalRotation, 1)
  end,
}

turtleRaw = (function()
  local delegate = turtleRaw
  
  function goTracked(direction)
    if delegate.go[direction]() then
      updateGlobalPositionAndRotation[direction]()
      return true
    else
      return false
    end
  end
  
  function turnTracked(direction)
    if delegate.turn[direction]() then
      updateGlobalPositionAndRotation[direction]()
      return true
    else
      return false
    end
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

local function rotateBy(rotation)
  rotation = rotationOffsetBy(rotation, 0)
  if rotation == 3 then return turtleRaw.turn.left() end
  for i = 1, rotation do
    if not turtleRaw.turn.right() then return false end
  end
  return true
end

local function rotateTo(rotation)
  return rotateBy(rotationOffsetTo(rotation, globalRotation))
end

local function moveStepBy(go, vector)
  local step = vector:step()
  local rotationOffset = rotationOffsetTo(step:xzRotation(), globalRotation)
  
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

function goStepXZ(xzPosition, dig, attack, wait, alternate)
  local forceGo = turtleForceGo(dig, attack)
  return moveStepBy(forceGo, xzPosition:withY(nil))
end

function goStepY(y, dig, attack, wait)
  local forceGo = turtleForceGo(dig, attack)
  return moveStepBy(forceGo, Vec(nil, y, nil))
end

function goTo(position, rotation, dig, attack, wait, straight)
 if dig == nil then dig = false end
 if attack == nil then attack = true end
 if wait == nil then wait = true end
 if straight == nil then straight = false end
 local oldY = position.y
 while not isAt(position) do
  if not isAt(position:withY(nil)) then
   local alternate = 0
   local dodge = -1
   if straight then alternate = 2 end
   if position.y >= oldY then dodge = dodge * -1 end
   while not goStepXZ(offsetTo(position), dig and alternate == 2, attack, false) and not goStepXZ(offsetTo(position), dig and alternate == 2, attack, false, true) do
    if not goStepY(dodge, dig and alternate == 2, attack, false) then
	 if alternate == 0 then
	  alternate = alternate + 1
	  dodge = dodge * -1
	 elseif alternate == 1 then
	  alternate = alternate + 1
	 elseif alternate >= 2 then
	  if not wait then
	   return false
	  else
	   alternate = 0
	   dodge = dodge * -1
	   if straight then alternate = 2 end
	  end
	 end
	end
    sleep(0.2)
   end
  elseif not isAt(Vec(nil, position.y, nil)) then
   if not goStepY(position.y - globalPosition.y, true, attack, false) and not wait then return false end
  end
  sleep(0.2)
 end
 if rotation ~= nil then rotateTo(rotation) end
 return true
end

loadCoords()

-- constants
slot_dump = 1
slot_ignore = 0
minFuelLevel = 10000

-- global vars
local function DigStack()
  return {
    size = function(self)
      local i = 1
      while self[i] ~= nil do i = i + 1 end
      return i - 1
    end,
    push = function(self, position, rotation)
      local i = 1
      while self[i] ~= nil do
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
      local i = sizeDigTask()
      local position, rotation = self[i] and Vec(self[i].x, self[i].y, self[i].z), self[i] and self[i].r
      if self[i] then self[i] = nil end
      return position, rotation
    end,
  }
end

digStack = DigStack()

function init()
 slot_ignore_max = slot_ignore
 for i = slot_ignore, 16, 1 do
  if turtle.getItemCount(i) > 0 then
   slot_ignore_max = i
  end
 end
 slot_items = slot_ignore_max + 1
end

function dumpItems()
 if turtle.getFuelLevel() <= minFuelLevel then refuel() end
 turtle.select(slot_dump)
 placeUp(true)
 repeat
  for i = slot_items, 16, 1 do
   turtle.select(i)
   turtle.dropUp()
  end
 until not shouldDump()
 turtle.select(slot_dump)
 digUp()
end

function shouldDump()
 for slot = slot_items, 16, 1 do
  if turtle.getItemCount(slot) == 0 then return false end
 end
 return true
end

function dumpIfNeeded()
 if shouldDump() then dumpItems() end
end

local isOre = (function()
  local function isOre(dir)
    if not turtleRaw.detect[dir]() then return false end
    for i = slot_ignore, slot_ignore_max, 1 do
      turtle.select(i)
      if turtleRaw.compare[dir]() then
        turtle.select(slot_items)
        return false
      end
    end
    turtle.select(slot_items)
    return true
  end
  
  return {
    forward = function() return isOre("forward") end,
    up = function() return isOre("up") end,
    down = function() return isOre("down") end,
  }
end)()

function checkAround()
 for i = 1, 4 do
   if isOre.forward() then digStack:push(offsetBy(offset.forward())) end
   rotateBy(1)
 end
 if isOre.up() then digStack:push(offsetBy(offset.up())) end
 if isOre.down() then digStack:push(offsetBy(offset.down())) end
end

function dig(count, up)
 if count == nil then count = 1 end
 local ret = false
 for i = 1, count, 1 do
  if up == nil then up = true end
  pushDigTask(getX() + getRotationOffsetX(), getY(), getZ() + getRotationOffsetZ(), getRotation())
  local x, y, z, r
  local oldY = getY()
  local check = true
  while true do
   if check and sizeDigTask()>0 then checkAround(getY() ~= oldY) end
   oldY = getY()
   dumpIfNeeded()
   turtle.select(slot_items)
   if up and x==nil then digUp() end
   position, r = digStack:pop()
   if x==nil then break end
   check = goTo(position.x, position.y, position.z, r, true, true, false, true)
  end
 end
 return ret
end

function getSlotDump()
 return slot_dump
end

function getSlotIgnore()
 return slot_ignore
end

function getSlotIgnoreMax()
 return slot_ignore_max
end

function getSlotItems()
 return slot_items
end

function getMinFuelLevel()
 return minFuelLevel
end

function getDigStack()
 return digStack
end

function setSlotDump(slot)
 slot_dump = slot
end

function setSlotIgnore(slot)
 slot_ignore = slot
end

function setSlotIgnoreMax(slot)
 slot_ignore_max = slot
end

function setSlotItems(slot)
 slot_items = slot
end

function setDigStack(stack)
 digStack = stack
end

local function printInfo()
 print("intelliMine by LolHens")
 print("Slot "..getSlotDump()..":      Ender Chest")
 print("Slot "..getSlotIgnore().." - "..getSlotIgnoreMax()..":  Ignored Blocks")
 print("Slot "..getSlotItems().." - 16: Empty Slots")
 sleep(2)
end

local function saveMinePos(count, i)
 local file = io.open(".intelliMinePos", "w")
 file:write(getX().."\n")
 file:write(getY().."\n")
 file:write(getZ().."\n")
 file:write(getRotation().."\n")
 file:write(count.."\n")
 file:write(i.."\n")
 file:write(getSlotDump().."\n")
 file:write(getSlotIgnore().."\n")
 file:write(getSlotIgnoreMax().."\n")
 file:write(getSlotItems().."\n")
 file:flush()
 file:close()
end

local function loadMinePos()
 if not fs.exists(".intelliMinePos") then
  return
 end
 local file = io.open(".intelliMinePos", "r")
 local x = tonumber(file:read("*l"))
 local y = tonumber(file:read("*l"))
 local z = tonumber(file:read("*l"))
 local r = tonumber(file:read("*l"))
 local count = tonumber(file:read("*l"))
 local i = tonumber(file:read("*l"))
 setSlotDump(tonumber(file:read("*l")))
 setSlotIgnore(tonumber(file:read("*l")))
 setSlotIgnoreMax(tonumber(file:read("*l")))
 setSlotItems(tonumber(file:read("*l")))
 file:close()
 goTo(x, y, z, r, true, true, false, true)
end

function stripmine(count, depth)
 while true do
  saveMinePos(count, i)
  i = i + 1
  digUp()
  dig()
  turnRight(2)
  dig()
  turnLeft()
  dig(depth)
  turnLeft()
  dig(3)
  turnLeft()
  dig(depth)
  turnLeft()
  dig()
  turnRight(2)
  dig(4)
 end
end

function main()
 count=tonumber(tArgs[1])
 depth=tonumber(tArgs[2])
 if count==nil then count=-1 end
 if depth==nil then depth=30 end
 init()
 loadMinePos()
 printInfo()
 stripmine(count, depth)
end

main()