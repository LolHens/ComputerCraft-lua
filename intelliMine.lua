-- intelliMine
-- by LolHens

tArgs = {...}

local function printInfo()
 print("Libraries:   move")
 print("Slot "..mine.getSlotDump()..":      Ender Chest")
 print("Slot "..mine.getSlotIgnore().." - "..mine.getSlotIgnoreMax()..":  Ignored Blocks")
 print("Slot "..mine.getSlotItems().." - 16: Empty Slots")
 sleep(2)
end

local function save(count, i)
 local file = io.open("intelliMinePos", "w")
 file:write(move.getX().."\n")
 file:write(move.getY().."\n")
 file:write(move.getZ().."\n")
 file:write(move.getRotation().."\n")
 file:write(count.."\n")
 file:write(i.."\n")
 file:write(mine.getSlotDump().."\n")
 file:write(mine.getSlotIgnore().."\n")
 file:write(mine.getSlotIgnoreMax().."\n")
 file:write(mine.getSlotItems().."\n")
 file:flush()
 file:close()
end

local function load()
 if not fs.exists("intelliMinePos") then
  return
 end
 local file = io.open("intelliMinePos", "r")
 local x = tonumber(file:read("*l"))
 local y = tonumber(file:read("*l"))
 local z = tonumber(file:read("*l"))
 local r = tonumber(file:read("*l"))
 local count = tonumber(file:read("*l"))
 local i = tonumber(file:read("*l"))
 mine.setSlotDump(tonumber(file:read("*l")))
 mine.setSlotIgnore(tonumber(file:read("*l")))
 mine.setSlotIgnoreMax(tonumber(file:read("*l")))
 mine.setSlotItems(tonumber(file:read("*l")))
 file:close()
 move.goTo(x, y, z, r, true, true, false, true)
end

function stripmine(count, depth, i)
 if i == nil then i = 1 end
 while i <= count or count == -1 do
  save(count, i)
  i = i + 1
  move.digUp()
  mine.dig()
  move.turnRight(2)
  mine.dig()
  move.turnLeft()
  mine.dig(depth)
  move.turnLeft()
  mine.dig(3)
  move.turnLeft()
  mine.dig(depth)
  move.turnLeft()
  mine.dig()
  move.turnRight(2)
  mine.dig(4)
 end
end

function main()
 count=tonumber(tArgs[1])
 depth=tonumber(tArgs[2])
 if count==nil then count=-1 end
 if depth==nil then depth=30 end
 mine.init()
 local loadedCount, loadedI = load()
 if loadedCount ~= nil then count = loadedCount end
 printInfo()
 stripmine(count, depth, loadedI)
end

main()