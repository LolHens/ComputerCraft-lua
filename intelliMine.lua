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

local function refuel(refuelMin)
  local limit = turtle.getFuelLimit()
  local refuelMax = limit - 100
  local refuelThreshold = refuelMin
  if refuelThreshold == nil then refuelThreshold = limit / 2 end
  if refuelMin == nil then refuelMin = 1 end
  
  if turtle.getFuelLevel() < refuelThreshold then
    local selected = turtle.getSelectedSlot()
    for i = 1, 16 do
      turtle.select(i)
      if true then -- TODO: is in refuel whitelist
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
 
  return {
    forward = function() return forceGo("forward") end,
    up = function() return forceGo("up") end,
    down = function() return forceGo("down") end,
    back = function()
      if not refuel(1) then return false end
      
      if turtleRaw.go.back() then return true end
      
      turtleRaw.turn.right()
      turtleRaw.turn.right()
      local result = forceGo("forward")
      turtleRaw.turn.left()
      turtleRaw.turn.left()
      return result
    end,
  }
end

local function Vec(x, y, z)
  if x == nil and y == nil and z == nil then
    x, y, z = 0, 0, 0
  elseif y == nil and z == nil then
    y, z = x, x
  elseif z == nil then
    return nil
  end
  
  return {
    x = x,
    y = y,
    z = z,
    copy = function(self)
      return Vec(self.x, self.y, self.z)
    end,
    isNull = function(self)
      return self.x == 0 and self.y == 0 and self.z == 0
    end,
    offset = function(self, other)
      return Vec(self.x + other.x, self.y + other.y, self.z + other.z)
    end,
    to = function(self, other)
      return Vec(other.x - self.x, other.y - self.y, other.z - self.z)
    end,
    xzRotation = function(self)
      if self.x == 0 and self.z < 0 then return 0 end
      if self.x > 0 and self.z == 0 then return 1 end
      if self.x == 0 and self.z > 0 then return 2 end
      if self.x < 0 and self.z == 0 then return 3 end
      return nil
    end,
    offsetByRotation = function(self, rotation)
      rotation = rotation % 4
      if rotation == 0 then return Vec(self.x, self.y, self.z - 1) end
      if rotation == 1 then return Vec(self.x + 1, self.y, self.z) end
      if rotation == 2 then return Vec(self.x, self.y, self.z + 1) end
      if rotation == 3 then return Vec(self.x - 1, self.y, self.z) end
      return nil
    end,
    string = function(self)
      return "{x="..self.x..",y="..self.y..",z="..self.z.."}"
    end,
  }
end

local function moveRaw(x, y, z)
  print("test")
end

local function locate()
  local position = Vec(gps.locate())
  
  local function rotationByMove(go, rotationOffset)
    if rotationOffset == nil then rotationOffset = 0 end
    
    if not refuel(2) then return nil end
    
    local offsetPosition = position:copy()
    
    if go.forward() then
      offsetPosition = Vec(gps.locate())
      go.back()
    elseif go.back() then
      offsetPosition = Vec(gps.locate())
      rotationOffset = rotationOffset + 2
      go.forward()
    end
    
    local rotation = position:to(offsetPosition):xzRotation()
    return rotation and (rotation + rotationOffset) % 4
  end
  
  local rotation = rotationByMove(turtleRaw.go)
  if rotation == nil then
    turtleRaw.turn.right()
    rotation = rotationByMove(turtleRaw.go, 3)
    turtleRaw.turn.left()
  end
  if rotation == nil then
    local forceGo = turtleForceGo(true)
    
    rotation = rotationByMove(forceGo)
    if rotation == nil then
      turtleRaw.turn.right()
      rotation = rotationByMove(forceGo, 3)
      turtleRaw.turn.left()
    end
  end
  
  return position, rotation
end

globalPosition, globalRotation = locate()

local updateGlobalPositionAndRotation = {
  forward = function()
    globalPosition = globalPosition:offsetByRotation(globalRotation)
  end,
  up = function()
    globalPosition = globalPosition:offset(Vec(0, 1, 0))
  end,
  down = function()
    globalPosition = globalPosition:offset(Vec(0, -1, 0))
  end,
  back = function()
    globalPosition = globalPosition:offsetByRotation((globalRotation + 2) % 4)
  end,
  left = function()
    globalRotation = (globalRotation + 3) % 4
  end,
  right = function()
    globalRotation = (globalRotation + 1) % 4
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
  rotation = rotation % 4
  if (rotation == 3) then return turtleRaw.turn.left() end
  for i = 1, rotation do
    if not turtleRaw.turn.right() then return false end
  end
  return true
end

local function rotateTo(rotation)
  return rotateBy(rotation - globalRotation)
end

--local function moveBy(vector) end




function go(dig, attack, wait)
 if forceAction("go", "", dig, attack, wait) then
  xAdd, zAdd = getRotationOffset(r)
  addCoords(xAdd, 0, zAdd)
  return true
 end
 return false
end

function turn(arg_r)
 diff = arg_r - r
 if math.abs(diff)==3 then
 diff = diff / -3
 end
 for i=1,math.abs(diff),1 do
  if diff>0 then
   turnRight()
  else
   turnLeft()
  end
 end
end

function turnRight(count)
 if count == nil then count = 1 end
 for i = 1, count, 1 do
  turtle.turnRight()
  addRotation(1)
 end
end

function turnLeft()
 if count == nil then count = 1 end
 for i = 1, count, 1 do
  turtle.turnLeft()
  addRotation(-1)
 end
end

function goStep(arg_x, arg_z, dig, attack, wait, alternate)
 if alternate == nil then alternate = false end
 if arg_x == 0 or arg_z == 0 then alternate = false end
 turn(getRotationFor(arg_x, arg_z, alternate))
 return go(dig, attack, wait)
end

function goStepY(arg_y, dig, attack, wait)
 if arg_y > 0 then
  return up(dig, attack, wait)
 elseif arg_y < 0 then
  return down(dig, attack, wait)
 end
 return true
end

function goTo(arg_x, arg_y, arg_z, arg_r, dig, attack, wait, straight)
 if arg_z == nil then
  arg_z = arg_y
  arg_y = y
 end
 if dig == nil then dig = false end
 if attack == nil then attack = true end
 if wait == nil then wait = true end
 if straight == nil then straight = false end
 local oldY = y
 while not isAt(arg_x, arg_y, arg_z) do
  if not isAt(arg_x, arg_z) then
   local alternate = 0
   local dodge = -1
   if straight then alternate = 2 end
   if arg_y >= oldY then dodge = dodge * -1 end
   while not goStep(arg_x - x, arg_z - z, dig and alternate == 2, attack, false) and not goStep(arg_x - x, arg_z - z, dig and alternate == 2, attack, false, true) do
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
  elseif not isAt(arg_y) then
   if not goStepY(arg_y - y, true, attack, false) and not wait then return false end
  end
  sleep(0.2)
 end
 if arg_r ~= nil then turn(arg_r) end
 return true
end

loadCoords()

-- constants
slot_dump = 1
slot_ignore = 0
minFuelLevel = 10000

-- global vars
digStack = {}

local function sizeDigTask()
 local i = 1
 while digStack[i] ~= nil do
  i = i + 1
 end
 return i - 1
end

local function pushDigTask(x, y, z, r)
 local i = 1
 while digStack[i] ~= nil do
  if digStack[i][1]==x and digStack[i][2]==y and digStack[i][3]==z then
   if digStack[i][4]==nil then digStack[i][4]=r end
   return
  end
  i = i + 1
 end
 digStack[i] = {}
 digStack[i][1] = x
 digStack[i][2] = y
 digStack[i][3] = z
 digStack[i][4] = r
end

local function popDigTask()
 local i = sizeDigTask()
 if digStack[i] == nil then return end
 local x, y, z, r = digStack[i][1], digStack[i][2], digStack[i][3], digStack[i][4]
 digStack[i] = nil
 return x, y, z, r
end

function init()
 setRefuelHandler(refuel)
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

function isOre(dir)
 if dir==nil then dir="" end
 if not getAction("detect", dir)() then return false end
 for i = slot_ignore, slot_ignore_max, 1 do
  turtle.select(i)
  if getAction("compare", dir)() then
   turtle.select(slot_items)
   return false
  end
 end
 turtle.select(slot_items)
 return true
end

function checkAround(back)
 if back==nil then back = false end
 if isOre() then pushDigTask(getX() + getRotationOffsetX(), getY(), getZ() + getRotationOffsetZ()) end
 if isOre("up") then pushDigTask(getX(), getY() + 1, getZ()) end
 if isOre("down") then pushDigTask(getX(), getY() - 1, getZ()) end
 turnLeft()
 if isOre() then pushDigTask(getX() + getRotationOffsetX(), getY(), getZ() + getRotationOffsetZ()) end
 turnRight(2)
 if isOre() then pushDigTask(getX() + getRotationOffsetX(), getY(), getZ() + getRotationOffsetZ()) end
 if back then
  turnRight()
  if isOre() then pushDigTask(getX() + getRotationOffsetX(), getY(), getZ() + getRotationOffsetZ()) end
  turnLeft()
 end
 turnLeft()
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
   x, y, z, r = popDigTask()
   if x==nil then break end
   check = goTo(x, y, z, r, true, true, false, true)
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