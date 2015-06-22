-- mine
-- by LolHens

-- constants
slot_dump = 1
slot_ignore = 2
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
 move.setRefuelHandler(refuel)
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
 move.placeUp(true)
 repeat
  for i = slot_items, 16, 1 do
   turtle.select(i)
   turtle.dropUp()
  end
 until not shouldDump()
 turtle.select(slot_dump)
 move.digUp()
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
 if not move.getAction("detect", dir)() then return false end
 for i = slot_ignore, slot_ignore_max, 1 do
  turtle.select(i)
  if move.getAction("compare", dir)() then
   turtle.select(slot_items)
   return false
  end
 end
 turtle.select(slot_items)
 return true
end

function checkAround(back)
 if back==nil then back = false end
 if isOre() then pushDigTask(move.getX() + move.getRotationOffsetX(), move.getY(), move.getZ() + move.getRotationOffsetZ()) end
 if isOre("up") then pushDigTask(move.getX(), move.getY() + 1, move.getZ()) end
 if isOre("down") then pushDigTask(move.getX(), move.getY() - 1, move.getZ()) end
 move.turnLeft()
 if isOre() then pushDigTask(move.getX() + move.getRotationOffsetX(), move.getY(), move.getZ() + move.getRotationOffsetZ()) end
 move.turnRight(2)
 if isOre() then pushDigTask(move.getX() + move.getRotationOffsetX(), move.getY(), move.getZ() + move.getRotationOffsetZ()) end
 if back then
  move.turnRight()
  if isOre() then pushDigTask(move.getX() + move.getRotationOffsetX(), move.getY(), move.getZ() + move.getRotationOffsetZ()) end
  move.turnLeft()
 end
 move.turnLeft()
end

function dig(count, up)
 if count == nil then count = 1 end
 local ret = false
 for i = 1, count, 1 do
  if up == nil then up = true end
  pushDigTask(move.getX() + move.getRotationOffsetX(), move.getY(), move.getZ() + move.getRotationOffsetZ(), move.getRotation())
  local x, y, z, r
  local oldY = move.getY()
  local check = true
  while true do
   if check and sizeDigTask()>0 then checkAround(move.getY() ~= oldY) end
   oldY = move.getY()
   dumpIfNeeded()
   turtle.select(slot_items)
   if up and x==nil then move.digUp() end
   x, y, z, r = popDigTask()
   if x==nil then break end
   check = move.goTo(x, y, z, r, true, true, false, true)
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