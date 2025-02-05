




local Types = {}
local IDs = {}
local Mutations = {}
local Groupings = {}
local UpdateFuncs = {}

local function NewEntry(Name, Class, Data)
	
	-- TEMP
	if Class == "Singlet" then return end
	
	if Types[Class] == nil then Types[Class] = {} end
	if IDs[Class] == nil then IDs[Class] = {} end
	------------- Add new a type to the class
	local NewIndex = #IDs[Class]+1
	Types[Class][Name] = Data
	Types[Class][Name].ID = NewIndex	
	Types[Class][Name].Name = Name	
	IDs[Class][NewIndex] = Name
	------------- Mutations for cells
	if Class == "Cell" then
		local U = Data.UpdateType
		if Mutations[U] == nil then
			Mutations[U] = {}
			Groupings[#Groupings+1] = U
		end
		Mutations[U][#Mutations[U]+1] = Name	
	end
	------------- Assets
	Types[Class][Name].Image = love.graphics.newImage("Assets/"..Class.."/"..Name..".png", {mipmaps = true})
	--Types[Class][Name].Image2 = love.graphics.newImage("Assets/"..Class.."/"..Name.."_2.png", {mipmaps = true})
	Types[Class][Name].Image:setMipmapFilter("nearest", 1)
	Types[Class][Name].Image:setFilter("nearest", "nearest")
	--Types[Class][Name].Image2:setMipmapFilter("nearest", 0)
end



local sin = math.sin
local cos = math.cos
local rad = math.rad
local abs = math.abs


UpdateFuncs["None"] = {
	ID = 0,
	CustomDataToArray = function(Data)
		return{
			0, 
			0, 
			0, 
			0}
	end,		
	Passive = function(Org1, Cell, dt)
	end,
	OnTouch = function(Org1, Org2, Cell, OtherCell)
	end,
}
UpdateFuncs["Root"] = {
	ID = 1,
	CustomDataToArray = function(Data)
		return{
			0, 
			0, 
			0, 
			0}
	end,		
	Passive = function()
	end,
	OnTouch = function()
	end,
}
UpdateFuncs["Digestive"] = {
	ID = 2,
	CustomDataToArray = function(Data)
		return{
			Types["Debris"][Data.Input].ID, 
			Types["Debris"][Data.Output].ID, 
			Data.EnergyCost, 
			0}
	end,		
	Passive = function(Org1, Cell, dt)
	end,
	OnTouch = function(Org1, Org2, Cell, OtherCell)
		if OtherCell.Category == "Debris" then
			if OtherCell.Type == Cell.CustomData.Input then
				OtherCell.Type = Cell.CustomData.Output
				NewEffect("Convert", Cell.x, Cell.y)
			end
		end
	end,
}
UpdateFuncs["Spike"] = {
	ID = 3,
	CustomDataToArray = function(Data)
		return{
			Data.Damage, 
			Data.Cooldown, 
			0, 
			0}
	end,	
	Passive = function(Org1, Cell, dt)
	end,
	OnTouch = function(Org1, Org2, Cell, OtherCell)
		if OtherCell.Category == "Cell" and Cell.CustomData.PokeCooldown <= 0 then
			NewEffect("Poke", Cell.x, Cell.y)
			OtherCell.HP = OtherCell.HP - clamp(Cell.CustomData.PokeDamage - Types["Cell"][OtherCell.Type].Armor, 0, 9999999)
			Cell.CustomData.PokeCooldown = Cell.CustomData.AttackSpeed
		end
	end,
}
UpdateFuncs["Swimmer"] = {
	ID = 4,
	CustomDataToArray = function(Data)
		return{
			Data.Strength, 
			0, 
			0, 
			0}
	end,	
	Passive = function(Org1, Cell, dt)
		Org1.XVel = Org1.XVel - sin(rad(Cell.Rot)) * dt * (2.45 * Cell.CustomData.Strength)
		Org1.YVel = Org1.YVel + cos(rad(Cell.Rot)) * dt * (2.45 * Cell.CustomData.Strength)
	end,
	OnTouch = function(Org1, Org2, Cell, OtherCell)
	end,
}
UpdateFuncs["Filter"] = {
	ID = 6,
	CustomDataToArray = function(Data)
		return{
			Types["Debris"][Data.Input].ID, 
			Data.EnergyProduced, 
			0, 
			0}
	end,		
}
UpdateFuncs["Muscle"] = {
	ID = 7,
	CustomDataToArray = function(Data)
		return{
			0, 
			0, 
			0, 
			0}
	end,		
	Passive = function(Org1, Cell, dt)
		if Cell.CustomData.RotBase == nil then
			Cell.CustomData.RotBase = Cell.RotBase
		end
		Cell.CustomData.SinVal = Cell.CustomData.SinVal + dt * 2
		Cell.CustomData.Bend = 30 * sin(Cell.CustomData.SinVal)
		Cell.Bend = Cell.CustomData.Bend + Cell.CustomData.Bend
		
	end,
	OnTouch = function(Org1, Org2, Cell, OtherCell)

	end,
}
UpdateFuncs["Photosynth"] = {
	ID = 8,
	CustomDataToArray = function(Data)
		return{
			0, 
			0, 
			0, 
			0}
	end,			
	Passive = function(Org1, Cell, dt)
		Org1.Energy = Org1.Energy + Sunlight[(Cell.tx * Settings.MapSize) + Cell.ty] * 2.5 * dt
		--Cell.DebugPrint = "Energy: "..Org1.Energy
	end,
	OnTouch = function(Org1, Org2, Cell, OtherCell)
	end,
}




-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

NewEntry("Core", "Cell", {		
	UpdateType = "None",
	Light = {0, 0, 0, 0},
	Description = [[]],
	EnergyCostPerSec = 1,
	EnergyCapacity = 10,
	Health = 25,
	Armor = 0,
	CustomData = {

	},
	CustomCData = {},-- CustomData will automatrically be parsed and made suitable for the c script. then stored here
})

NewEntry("Algae Filter", "Cell", {		
	UpdateType = "Filter",
	Light = {0, 0, 0, 0},
	Description = [[]],
	EnergyCostPerSec = 1,
	EnergyCapacity = 20,
	Health = 25,
	Armor = 0,
	CustomData = {
		Input = "Algae",
		EnergyProduced = 100,
	},
	CustomCData = {},-- CustomData will automatrically be parsed and made suitable for the c script. then stored here
})

NewEntry("Light Muscle", "Cell", {		
	UpdateType = "Muscle",
	Light = {0, 0, 0, 0},
	Description = [[]],
	EnergyCostPerSec = 1,
	EnergyCapacity = 30,
	Health = 25,
	Armor = 0,
	CustomData = {
		MovementCostPerSecond = 10,
		Bend = 0,
		SinVal = 0,
		RotBase = nil,
	},
	CustomCData = {},-- CustomData will automatrically be parsed and made suitable for the c script. then stored here
})

NewEntry("Cillia", "Cell", {		
	UpdateType = "Swimmer",
	Light = {0, 0, 0, 0},
	Description = [[]],
	EnergyCostPerSec = 1,
	EnergyCapacity = 30,
	Health = 25,
	Armor = 0,
	CustomData = {
		Strength = 1.2,
	},
	CustomCData = {},-- CustomData will automatrically be parsed and made suitable for the c script. then stored here
})

NewEntry("Algae Digester", "Cell", {		
	UpdateType = "Digestive",
	Light = {0, 0, 0, 0},
	Description = [[Converts algae it touches into easily digestable sugar.]],
	EnergyCostPerSec = 1,
	EnergyCapacity = 20,
	Health = 25,
	Armor = 0,
	CustomData = {
		Input = "Algae",
		Output = "Sugar",
		EnergyCost = 75,
	},
	CustomCData = {},-- CustomData will automatrically be parsed and made suitable for the c script. then stored here
})

NewEntry("Fat Cell", "Cell", {		
	UpdateType = "None",
	Light = {0, 0, 0, 0},
	Description = [[]],
	EnergyCostPerSec = 1,
	EnergyCapacity = 40,
	Health = 10,
	Armor = 0,
	CustomData = {},
	CustomCData = {},-- CustomData will automatrically be parsed and made suitable for the c script. then stored here
})

NewEntry("Cellulose", "Cell", {		
	UpdateType = "None",
	Light = {0, 0, 0, 0},
	Description = [[]],
	EnergyCostPerSec = 1,
	EnergyCapacity = 10,
	Health = 25,
	Armor = 0,
	CustomData = {
		Input = "Glucose",
		Output = "",
		EnergyPerSec = 75,
	},
	CustomCData = {},-- CustomData will automatrically be parsed and made suitable for the c script. then stored here
})

NewEntry("Coral", "Cell", {		
	UpdateType = "None",
	Light = {0, 0, 0, 0},
	Description = [[]],
	EnergyCostPerSec = 1,
	EnergyCapacity = 10,
	Health = 25,
	Armor = 0,
	CustomData = {
		Input = "Glucose",
		Output = "",
		EnergyPerSec = 75,
	},
	CustomCData = {},-- CustomData will automatrically be parsed and made suitable for the c script. then stored here
})

NewEntry("Photocell", "Cell", {		
	UpdateType = "Photosynth",
	Light = {0, 0, 0, 0},
	Description = [[]],
	EnergyCostPerSec = 1,
	EnergyCapacity = 20,
	Health = 25,
	Armor = 0,
	CustomData = {
		Input = "Glucose",
		Output = "",
		EnergyPerSec = 75,
	},
	CustomCData = {},-- CustomData will automatrically be parsed and made suitable for the c script. then stored here
})

NewEntry("Root", "Cell", {		
	UpdateType = "Root",
	Light = {0, 0, 0, 0},
	Description = [[]],
	EnergyCostPerSec = 1,
	EnergyCapacity = 10,
	Health = 25,
	Armor = 0,
	CustomData = {
		Input = "Glucose",
		Output = "",
		EnergyPerSec = 75,
	},
	CustomCData = {},-- CustomData will automatrically be parsed and made suitable for the c script. then stored here
})

NewEntry("Dense Cellulose", "Cell", {		
	UpdateType = "None",
	Light = {0, 0, 0, 0},
	Description = [[]],
	EnergyCostPerSec = 1,
	EnergyCapacity = 10,
	Health = 25,
	Armor = 0,
	CustomData = {
		Input = "Glucose",
		Output = "",
		EnergyPerSec = 75,
	},
	CustomCData = {},-- CustomData will automatrically be parsed and made suitable for the c script. then stored here
})

NewEntry("Dentin Cell", "Cell", {		
	UpdateType = "Spike",
	Light = {0, 0, 0, 0},
	Description = [[]],
	EnergyCostPerSec = 1,
	EnergyCapacity = 10,
	Health = 25,
	Armor = 0,
	CustomData = {
		Damage = 5,
		Cooldown = 1,
	},
	CustomCData = {},-- CustomData will automatrically be parsed and made suitable for the c script. then stored here
})




-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

NewEntry("Horned Thresher", "Singlet", {
	Description = [[]],
	Light = {0, 0, 0, 0},
	Diet = {},
	Output = {},
	PhotoSynth = false,
	Energy = 250,
	Movement = {TimerMin = 0.1, TimerMax = 0.8, RotChangeAvg = 10, SpeedAvg = 5, IdlePercentChance = 15},
	Health = 140,
	Armor = 1,
	BirthEnergyMinimum = 100,
})

NewEntry("Protozol", "Singlet", {
	Description = [[]],
	Light = {0, 0, 0, 0},
	Diet = {},
	Output = {},
	PhotoSynth = false,
	Energy = 250,
	Movement = {TimerMin = 0.1, TimerMax = 0.8, RotChangeAvg = 10, SpeedAvg = 5, IdlePercentChance = 15},
	Health = 140,
	Armor = 1,
	BirthEnergyMinimum = 100,
})

NewEntry("Quid", "Singlet", {
	Description = [[]],
	Light = {0, 0, 0, 0},
	Diet = {},
	Output = {},
	PhotoSynth = false,
	Energy = 250,
	Movement = {TimerMin = 0.1, TimerMax = 0.8, RotChangeAvg = 10, SpeedAvg = 5, IdlePercentChance = 15},
	Health = 140,
	Armor = 1,
	BirthEnergyMinimum = 100,
})


-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

NewEntry("Soft Egg", "Debris", {		
	Weight = 1,
	Light = {0, 0, 0, 0},
	StartingDensity = 50,
	Energy = 14,
	Armor = 1,
	LifeTime = 100,
})

NewEntry("Algae", "Debris", {
	Weight = 1,
	Light = {0, 0, 0, 0},
	StartingDensity = 50,
	Energy = 14,
	Armor = 1,
	LifeTime = 100,
})

NewEntry("Meat", "Debris", {
	Weight = 2.5,
	Light = {0, 0, 0, 0},
	StartingDensity = 50,
	Energy = 14,
	Armor = 1,
	LifeTime = 100,
})

NewEntry("Sugar", "Debris", {
	Weight = 0.5,
	Light = {0, 0, 0, 0},
	StartingDensity = 50,
	Energy = 14,
	Armor = 1,
	LifeTime = 100,
})

NewEntry("Veggie", "Debris", {
	Weight = 1,
	Light = {0, 0, 0, 0},
	StartingDensity = 50,
	Energy = 14,
	Armor = 1,
	LifeTime = 100,
})







for k, v in pairs(Types["Cell"]) do
	-- Create CustomCData arrays
	v.CustomCData = UpdateFuncs[v.UpdateType].CustomDataToArray(v.CustomData)
end



return
{Types, IDs, Mutations, Groupings, UpdateFuncs}













