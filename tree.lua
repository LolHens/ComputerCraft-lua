-- tree
-- by LolHens

tArgs = {...}

function fellTree(height)
 turtle.select(1)
 if turtle.detect() then
  move.go(true)
  num = 1
  while turtle.compareUp() and (height==nil or num<height) do
   num = num + 1
   move.up(true) 
  end
  for i=2, num, 1 do
   move.down()
  end
 end
end

function isTree()
 turtle.select(1)
 return turtle.detect() and (turtle.getItemCount(1)==0 or turtle.compare())
end

function findTree(sub)
 move.turnLeft()
 if isTree() then return true end
 move.turnRight()
 if isTree() then return true end
 move.turnRight()
 if isTree() then return true end
 move.turnRight()
 if isTree() then return true end
 if not sub and not turtle.detect() then
  move.go()
  return findTree(true)
 end
 return false
end

function main(height)
 if height~= nil then height=tonumber(height) end
 if turtle.detect() then fellTree(height) end
 while findTree(false) do
  fellTree(height)
 end
end

main(tArgs[1])