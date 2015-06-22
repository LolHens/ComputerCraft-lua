-- craft
-- by LolHens

tArgs = {...}

if tArgs[1] == nil then
 dropFunc = turtle.drop
 suckFunc1 = turtle.suckUp
 suckFunc2 = turtle.suckDown
 dropFunc1 = turtle.dropUp
 dropFunc2 = turtle.dropDown
elseif tArgs[1] == "up" then
 dropFunc = turtle.dropUp
 suckFunc1 = turtle.suck
 suckFunc2 = turtle.suckDown
 dropFunc1 = turtle.drop
 dropFunc2 = turtle.dropDown
elseif tArgs[1] == "down" then
 dropFunc = turtle.dropDown
 suckFunc1 = turtle.suckUp
 suckFunc2 = turtle.suck
 dropFunc1 = turtle.dropUp
 dropFunc2 = turtle.drop
end

function main()
 while true do
  if isValid() and not isTemplate() then craft() end
  sleep(0.1)
 end
end

function craft()
 emptySlot = getFirstEmptySlot()
 if emptySlot > -1 then
  turtle.select(emptySlot)
  turtle.craft(1)
  dropFunc()
 end
end

function getFirstEmptySlot()
 for i = 1, 16 do
  if turtle.getItemCount(i) == 0 then return i end
 end
 return -1
end

function getFirstEmptySlotAt(slot)
 for i = slot, 16 do
  if turtle.getItemCount(i) == 0 then return i end
 end
 return -1
end

function isValid()
 return turtle.craft(0)
end

function isTemplate()
 i = 0
 while i < 11 do
  i = i + 1
  if i == 4 or i == 8 then i = i + 1 end
  
  if turtle.getItemCount(i) == 1 then
   if not tryToFill(i) then return true end
  end
 end
end

function tryToFill(slot)
 for i = 1, 16 do
  if i ~= slot and turtle.getItemCount(i) > 2 then
   turtle.select(slot)
   if turtle.compareTo(i) then
    turtle.select(i)
    return turtle.transferTo(slot, 1)
   end
  end
 end
 
 tryToPull(slot)
 
 return false
end

function tryToPull(slot)
 emptySlot = getFirstEmptySlotAt(slot)
 
 turtle.select(slot)
 if suckFunc1() then
  if emptySlot > -1 and turtle.getItemCount(emptySlot) > 0 then
   turtle.select(emptySlot)
   dropFunc1()
  else
   return true
  end
 end
 
 turtle.select(slot)
 if suckFunc2() then
  if emptySlot > -1 and turtle.getItemCount(emptySlot) > 0 then
   turtle.select(emptySlot)
   dropFunc2()
  else
   return true
  end
 end
 
 return false
end

main()