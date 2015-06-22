-- pack
-- by LolHens

tArgs = {...}

local function arraySize(array)
 local i = 1
 while array[i] ~= nil do
  i = i + 1
 end
 return i - 1
end

local function arrayAdd(array, obj)
 array[arraySize(array) + 1] = obj
end

local function arrayContains(array, obj)
 for i = 0, arraySize(array) do
  if array[i + 1] == obj then return true end
 end
 return false
end

local function pack(path, file_stream, out, excluded)
 if not arrayContains(excluded, path) then
  if fs.isDir(path) then
   file_stream:write(" {")
   file_stream:write("1")
   file_stream:write(", \""..path.."\"")
   file_stream:write("},\n")
   for _, file in pairs(fs.list(path)) do
    pack(fs.combine(path, file), file_stream, out, excluded)
   end
  else
   print(path)
   file_stream:write(" {")
   file_stream:write("2")
   file_stream:write(", \""..path.."\"")
   local file = io.open(path, "r")
   local file_line = file:read("*l")
   while file_line ~= nil do
    file_line = file_line:gsub("(\\)", "\\%0")
    file_line = file_line:gsub("(\")", "\\%0")
    file_stream:write(", \""..file_line.."\"")
    file_line = file:read("*l")
   end
   file:close()
   file_stream:write("},\n")
  end
 end
end

function main(path, out)
 print("Packing \""..path.."\" into \""..out.."\"...")
 local excluded = {"rom", fs.combine(out, "/")}
 local merged = {}
 local autostart
 local jmpArgs = 2
 for i, arg in pairs(tArgs) do
  if jmpArgs == 0 then
   if arg=="-ex" then
    arrayAdd(excluded, fs.combine(tArgs[i + 1], "/"))
	jmpArgs = 1
   elseif arg=="-merge" then
    local file_merged = fs.combine(tArgs[i + 1], "/")
    if fs.exists(file_merged) and not fs.isDir(file_merged) then
     arrayAdd(merged, file_merged)
	end
    jmpArgs = 1
   elseif arg=="-start" then
    autostart = fs.combine(tArgs[i + 1], "/")
	jmpArgs = 1
   end
  else
   jmpArgs = jmpArgs - 1
  end
 end
 local file_stream = io.open(out, "w")
 file_stream:write("-- unpack\n-- by LolHens\n\n")
 file_stream:write("tArgs = {...}\n\n")
 file_stream:write("-- constants\n")
 file_stream:write("packed = {\n")
 pack(fs.combine(path, "/"), file_stream, out, excluded)
 file_stream:write("}\n\n")
 file_stream:write("merged = {")
 for _, file_merged in pairs(merged) do
  file_stream:write("\""..file_merged.."\", ")
 end
 file_stream:write("}\n\n")
 file_stream:write("autostart = ")
 if autostart==nil then file_stream:write("nil") else file_stream:write("\""..autostart.."\"") end
 file_stream:write("\n\n")
 file_stream:write("local function arraySize(array)\n")
 file_stream:write(" local i = 1\n")
 file_stream:write(" while array[i] ~= nil do\n")
 file_stream:write("  i = i + 1\n")
 file_stream:write(" end\n")
 file_stream:write(" return i - 1\n")
 file_stream:write("end\n\n")
 file_stream:write("local function arrayContains(array, obj)\n")
 file_stream:write(" for i = 0, arraySize(array) do\n")
 file_stream:write("  if array[i + 1] == obj then return true end\n")
 file_stream:write(" end\n")
 file_stream:write(" return false\n")
 file_stream:write("end\n\n")
 file_stream:write("local function doFile(num, out)\n")
 file_stream:write(" local file = packed[num]\n")
 file_stream:write(" local file_type = file[1]\n")
 file_stream:write(" local file_path = fs.combine(out, file[2])\n")
 file_stream:write(" if (file_type == 1) then\n")
 file_stream:write("  if not fs.exists(file_path) or not fs.isDir(file_path) then\n")
 file_stream:write("   fs.makeDir(file_path)\n")
 file_stream:write("  end\n")
 file_stream:write(" elseif (file_type == 2) then\n")
 file_stream:write("  print(file_path)\n")
 file_stream:write("  local file_mode = \"w\"\n")
 file_stream:write("  if arrayContains(merged, file_path) then file_mode = \"a\" end\n")
 file_stream:write("  local file_stream = io.open(file_path, file_mode)\n")
 file_stream:write("  for i, file_line in pairs(packed[num]) do\n")
 file_stream:write("   if i > 2 then file_stream:write(file_line..\"\\n\") end\n")
 file_stream:write("  end\n")
 file_stream:write("  file_stream:flush()\n")
 file_stream:write("  file_stream:close()\n")
 file_stream:write(" end\n")
 file_stream:write("end\n\n")
 file_stream:write("function main(out)\n")
 file_stream:write(" if out==nil then\n")
 file_stream:write("  out=\"./\"\n")
 file_stream:write(" elseif out:sub(out:len()) ~= \"/\" then\n")
 file_stream:write("  out = out..\"/\"\n")
 file_stream:write(" end\n")
 file_stream:write(" print(\"Unpacking to \\\"\"..out..\"\\\"...\")\n")
 file_stream:write(" for i in pairs(packed) do\n")
 file_stream:write("  doFile(i, out)\n")
 file_stream:write(" end\n")
 file_stream:write(" if autostart ~= nil then shell.run(autostart) end\n")
 file_stream:write("end\n\n")
 file_stream:write("main(tArgs[1])")
 file_stream:flush()
 file_stream:close()
end

main(tArgs[1], tArgs[2])