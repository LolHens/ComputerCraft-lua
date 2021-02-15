-- intelliMine
-- by LolHens

tArgs = {...}

-- global vars
x, y, z = gps.locate()

-- TODO: compute rotation
r = 0

local function getRotationFor(arg_x, arg_z, alternate)
 if alternate == nil then alternate = false end
 if (not alternate and math.abs(arg_x) > math.abs(arg_z)) or (alternate and math.abs(arg_x) <= math.abs(arg_z)) then
  arg_x = arg_x / math.abs(arg_x)
  arg_z = 0
 else
  arg_z = arg_z / math.abs(arg_z)
  arg_x = 0
 end
 if arg_x==0 and arg_z>0 then return 0 end
 if arg_x<0 and arg_z==0 then return 1 end
 if arg_x==0 and arg_z<0 then return 2 end
 if arg_x>0 and arg_z==0 then return 3 end
 return 0
end

local function getRawAction(action, dir)
 if dir==nil then dir="" end
 if dir=="" then
  if action=="inspect" then
   return turtle.inspect, false
  elseif action=="detect" then
   return turtle.detect, false
  elseif action=="compare" then
   return turtle.compare, false
  elseif action=="drop" then
   return turtle.drop, false
  elseif action=="suck" then
   return turtle.suck, false
  elseif action=="place" then
   return turtle.place, false
  elseif action=="dig" then
   return turtle.dig, false
  elseif action=="go" then
   return turtle.forward, true
  elseif action=="attack" then
   return turtle.attack, false
  end
 elseif dir=="up" then
  if action=="inspect" then
   return turtle.inspectUp, false
  elseif action=="detect" then
   return turtle.detectUp, false
  elseif action=="compare" then
   return turtle.compareUp, false
  elseif action=="drop" then
   return turtle.dropUp, false
  elseif action=="suck" then
   return turtle.suckUp, false
  elseif action=="place" then
   return turtle.placeUp, false
  elseif action=="dig" then
   return turtle.digUp, false
  elseif action=="go" then
   return turtle.up, true
  elseif action=="attack" then
   return turtle.attackUp, false
  end
 elseif dir=="down" then
  if action=="inspect" then
   return turtle.inspectDown, false
  elseif action=="detect" then
   return turtle.detectDown, false
  elseif action=="compare" then
   return turtle.compareDown, false
  elseif action=="drop" then
   return turtle.dropDown, false
  elseif action=="suck" then
   return turtle.suckDown, false
  elseif action=="place" then
   return turtle.placeDown, false
  elseif action=="dig" then
   return turtle.digDown, false
  elseif action=="go" then
   return turtle.down, true
  elseif action=="attack" then
   return turtle.attackDown, false
  end
 end
 return nil
end

local function forceAction(action, dir, dig, attack, wait)
 if dig == nil then dig = false end
 if attack == nil then attack = true end
 if wait == nil then wait = false end
 actionFunc, fuelNeeded = getRawAction(action, dir)
 if fuelNeeded and not hasFuel() then return false end
 while not actionFunc() do
  if getRawAction("detect", dir)() then
   if (not dig or not getRawAction("dig", dir)()) and not wait then
    return false
   end
  else
   if attack then
    getRawAction("attack", dir)()
   elseif not wait then
    return false
   end
  end
  sleep(0.2)
 end
 return true
end

-- globals
function setRefuelHandler(handler)
 moveRefuelHandler = handler
end

function getRotationOffsetX(arg_r)
 if arg_r==nil then arg_r = r end
 if arg_r==0 then
  return 0
 elseif arg_r==1 then
  return -1
 elseif arg_r==2 then
  return 0
 elseif arg_r==3 then
  return 1
 end
 return 0
end

function getRotationOffsetZ(arg_r)
 if arg_r==nil then arg_r = r end
 if arg_r==0 then
  return 1
 elseif arg_r==1 then
  return 0
 elseif arg_r==2 then
  return -1
 elseif arg_r==3 then
  return 0
 end
 return 0
end

function getRotationOffset(arg_r)
 return getRotationOffsetX(arg_r), getRotationOffsetZ(arg_r)
end

function setCoords(arg_x, arg_y, arg_z, arg_r)
 x = arg_x
 y = arg_y
 z = arg_z
 if arg_r ~= nil then r = arg_r end
 saveCoords()
end

function addCoords(arg_x, arg_y, arg_z, arg_r)
 x = x + arg_x
 y = y + arg_y
 z = z + arg_z
 if arg_r ~= nil then r = r + arg_r end
 saveCoords()
end
 
function setRotation(arg_r)
 r = arg_r
 saveCoords()
end

function addRotation(arg_r)
 r = r + arg_r
 if r<0 then r = r + 4 end
 if r>3 then r = r - 4 end
 saveCoords()
end
 
function getCoords()
 return x, y, z, r
end

function getX()
 return x
end

function getY()
 return y
end

function getZ()
 return z
end
 
function getRotation()
 return r
end

function isAt(arg_x, arg_y, arg_z)
 if arg_z==nil and arg_y==nil then
  return arg_x==y
 elseif arg_z==nil then
  return arg_x==x and arg_y==z
 end
 return arg_x==x and arg_y==y and arg_z==z
end
   
function go(dig, attack, wait)
 if forceAction("go", "", dig, attack, wait) then
  xAdd, zAdd = getRotationOffset(r)
  addCoords(xAdd, 0, zAdd)
  return true
 end
 return false
end

function up(dig, attack, wait)
 if forceAction("go", "up", dig, attack, wait) then
  addCoords(0, 1, 0)
  return true
 end
 return false
end

function down(dig, attack, wait)
 if forceAction("go", "down", dig, attack, wait) then
  addCoords(0, -1, 0)
  return true
 end
 return false
end

function place(dig, attack, wait)
 return forceAction("place", "", dig, attack, wait)
end

function placeUp(dig, attack, wait)
 return forceAction("place", "up", dig, attack, wait)
end

function placeDown(dig, attack, wait)
 return forceAction("place", "down", dig, attack, wait)
end

function dig()
 turtle.dig()
end

function digUp()
 turtle.digUp()
end

function digDown()
 turtle.digDown()
end

function getAction(action, dir)
 if dir==nil then dir="" end
 if dir=="" then
  if action=="inspect" then
   return turtle.inspect, false
  elseif action=="detect" then
   return turtle.detect, false
  elseif action=="compare" then
   return turtle.compare, false
  elseif action=="drop" then
   return turtle.drop, false
  elseif action=="suck" then
   return turtle.suck, false
  elseif action=="place" then
   return place, false
  elseif action=="dig" then
   return dig, false
  elseif action=="go" then
   return go, true
  elseif action=="attack" then
   return turtle.attack, false
  end
 elseif dir=="up" then
  if action=="inspect" then
   return turtle.inspectUp, false
  elseif action=="detect" then
   return turtle.detectUp, false
  elseif action=="compare" then
   return turtle.compareUp, false
  elseif action=="drop" then
   return turtle.dropUp, false
  elseif action=="suck" then
   return turtle.suckUp, false
  elseif action=="place" then
   return placeUp, false
  elseif action=="dig" then
   return digUp, false
  elseif action=="go" then
   return up, true
  elseif action=="attack" then
   return turtle.attackUp, false
  end
 elseif dir=="down" then
  if action=="inspect" then
   return turtle.inspectDown, false
  elseif action=="detect" then
   return turtle.detectDown, false
  elseif action=="compare" then
   return turtle.compareDown, false
  elseif action=="drop" then
   return turtle.dropDown, false
  elseif action=="suck" then
   return turtle.suckDown, false
  elseif action=="place" then
   return placeDown, false
  elseif action=="dig" then
   return digDown, false
  elseif action=="go" then
   return down, true
  elseif action=="attack" then
   return turtle.attackDown, false
  end
 end
 return nil
end

function back()
 if not hasFuel() then return false end
 if turtle.back() then
  xAdd, zAdd = getRotationOffset(r)
  addCoords(xAdd * -1, 0, zAdd * -1)
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

function hasFuel()
 if turtle.getFuelLevel() <= 1 and moveRefuelHandler ~= nil then
  moveRefuelHandler()
 end
 if turtle.getFuelLevel() > 1 then
  return true
 end
 return false
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

function refuel()
 repeat
  for i = slot_items, 16, 1 do
   turtle.select(i)
   turtle.refuel(64)
  end
  sleep(0.2)
 until turtle.getFuelLevel() > 1
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