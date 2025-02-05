




require("love.math")
local socket = require("socket")
ffi = require("ffi")
require("CDefs")
require("Utils")

-----------------------------------
-----------------------------------

local MapMem, ModuleDataMem = ...


Map = ffi.cast("MapTile *", MapMem:getFFIPointer())
ModuleData = ffi.cast("ModuleData *", ModuleDataMem:getFFIPointer())


-----------------------------------
-----------------------------------





-----------------------------------------------------------
-----------------------------------------------------------
-----------------------------------------------------------
-----------------------------------------------------------


local MoveUnits = ffi.load("C:/Users/theki/Desktop/LIFE MACHINE/Game/Libraries/MoveUnits.dll")



ffi.cdef[[
	unsigned int Process(float dt, MapTile *Map, struct ModuleData *MD);
]]


while true do
	
	--local DesiredTime = 1 / 30
	local Msg = love.thread.getChannel("Thread Updates"):demand()

	if Msg ~= nil then
		local dt = Msg[1]
		local DesiredTime = Msg[2]		
		t = socket.gettime()
		
		local ISZ = ffi.sizeof("unsigned int")

		ModuleData.CellRenderCount = 0
		ModuleData.DebrisRenderCount = 0
		ModuleData.EffectRenderCount = 0		
		
		local i = MoveUnits.Process(dt, Map, ModuleData)

		ModuleData.Safe_CellRenderCount = ModuleData.CellRenderCount
		ModuleData.Safe_DebrisRenderCount = ModuleData.DebrisRenderCount
		ModuleData.Safe_EffectRenderCount = ModuleData.EffectRenderCount

		
		--print("ran "..i.." times")
		diff = math.abs(t - socket.gettime())
		--print(diff, "Desired: " .. DesiredTime, math.floor(100 * (diff / DesiredTime)) .. "% Time")
		love.thread.getChannel("Thread Times"):push(string.format("%.2f", math.floor(100 * (diff / DesiredTime))) .. "% Time")
		
		
		love.thread.getChannel("Thread Finishes"):push(true)

	end




end



