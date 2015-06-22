-- move
-- by LolHens

-- global vars
x = 0
y = 0
z = 0
r = 0

-- locals
local function save()
 local file = io.open("coords", "w")
 file:write(x.."\n")
 file:write(y.."\n")
 file:write(z.."\n")
 file:write(r.."\n")
 file:flush()
 file:close()
end
 
local function load()
 if not fs.exists("coords") then
  return
 end
 local file = io.open("coords", "r")
 x = tonumber(file:read("*l"))
 y = tonumber(file:read("*l"))
 z = tonumber(file:read("*l"))
 r = tonumber(file:read("*l"))
 file:close()
end

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
  if action=="detect" then
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
  if action=="detect" then
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
  if action=="detect" then
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
 save()
end

function addCoords(arg_x, arg_y, arg_z, arg_r)
 x = x + arg_x
 y = y + arg_y
 z = z + arg_z
 if arg_r ~= nil then r = r + arg_r end
 save()
end
 
function setRotation(arg_r)
 r = arg_r
 save()
end

function addRotation(arg_r)
 r = r + arg_r
 if r<0 then r = r + 4 end
 if r>3 then r = r - 4 end
 save()
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
  if action=="detect" then
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
  if action=="detect" then
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
  if action=="detect" then
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

load()