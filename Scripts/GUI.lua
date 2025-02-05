








local GUI = {}


GUI.DebrisMenuOpen = false
GUI.HeldDebris = ""

GUI.SelectedOrganism = nil
GUI.JustToNewOrganismTimer = 0

love.mouse.setVisible(false)

local LoadingScreen = love.graphics.newImage("Assets/GUI/Loading Screen.png")
local TitleFont = love.graphics.newFont("Assets/Fonts/DungeonFont.ttf")
TitleFont:setFilter("nearest")


GUI.StartupPlayed = false
GUI.StartupTimer = 0
function GUI.DrawStartupScreen(dt)
	
	GUI.StartupTimer = GUI.StartupTimer - dt
	if GUI.StartupTimer <= 0 then
		GUI.StartupPlayed = true
	end
	
	local Alpha = 1
	if GUI.StartupTimer <= 1 then
		Alpha = GUI.StartupTimer
	end
	love.graphics.setColor(1, 1, 1, Alpha)
	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()
	local scale = (sh / LoadingScreen:getWidth()) * 0.9
	local w = LoadingScreen:getWidth() * scale
	love.graphics.draw(LoadingScreen, (sw/2)-(w/2), (sh/2)-(w/2), 0, scale, scale)

end



GUI.Wiping = false
function GUI.DrawWipeScreen()
	
	if GUI.Wiping then
	
	
	
	end


end



function GUI.DrawGameScreen(texture)
	
	love.graphics.setColor(1, 1, 1, 1)
	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()
	local scale = (sh / texture:getWidth()) * 0.9
	local w = texture:getWidth() * scale
	love.graphics.draw(texture, (sw/2)-(w/2), (sh/2)-(w/2), 0, scale, scale)

end

function disp_time(time)
  local days = math.floor(time/86400)
  local hours = math.floor(math.mod(time, 86400)/3600)
  local minutes = math.floor(math.mod(time,3600)/60)
  local seconds = math.floor(math.mod(time,60))
  return string.format("%d:%02d:%02d:%02d",days,hours,minutes,seconds)
end

local Crosshair = love.graphics.newImage("Assets/GUI/Crosshair.png")
local HUDFont = love.graphics.newFont("Assets/Fonts/PixeloidMono.ttf")
HUDFont:setFilter("nearest")

function GUI.DrawHUD(dt)
	
	if not GUI.Wiping and GUI.StartupPlayed then
		
		local floor = math.floor
		
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setFont(HUDFont)

		local sw = love.graphics.getWidth()
		local sh = love.graphics.getHeight()		
		local scale = (sh / LoadingScreen:getWidth()) * 0.9
		local w = LoadingScreen:getWidth() * scale
		
		local TX, TY = Camera:toWorldCoords(w/2, w/2)
		TX = clamp(math.floor(TX), 0, Settings.MapSize)
		TY = clamp(math.floor(TY), 0, Settings.MapSize)
		local Tile = Map[(TX * Settings.MapSize) + TY]
		
		love.graphics.print("[ Tile: "..TX.." - "..TY, sh*0.05, sh*0.1, 0, 1, 1)
		love.graphics.print("Oxygen: "..string.format("%.3f",Tile.Oxygen), sh*0.05, sh*0.14, 0, 1, 1)
		love.graphics.print("Sunlight: "..string.format("%.3f",Tile.Sunlight), sh*0.05, sh*0.18, 0, 1, 1)
		love.graphics.print("Temperature: "..Tile.Temperature.."F", sh*0.05, sh*0.22, 0, 1, 1)
		love.graphics.print("Pressure: "..Tile.Pressure, sh*0.05, sh*0.26, 0, 1, 1)
		love.graphics.print("Salinity: "..string.format("%.3f",Tile.Salinity), sh*0.05, sh*0.30, 0, 1, 1)
		
		love.graphics.print("Cell Count: "..ModuleData.CellCount, sh*0.05, sh*0.42, 0, 1, 1)
		love.graphics.print("Debris Count: "..ModuleData.DebrisCount, sh*0.05, sh*0.46, 0, 1, 1)
		love.graphics.print("Organism Count: "..ModuleData.OrganismCount, sh*0.05, sh*0.5, 0, 1, 1)
		
		love.graphics.print("World Lifetime: "..disp_time(MapDuration), sh*0.05, sh*0.62, 0, 1, 1)
		
		local buttontext
		if TURBO then 
			buttontext = "Turbo Enabled"
			love.graphics.setColor(1, 1, 1, 1)
		else 
			buttontext = "Turbo Disabled"
			love.graphics.setColor(1, 1, 1, 0.5)
		end		
		
		
		RenderClickableText(buttontext, sh*0.05, sh*0.25, sh*0.7, sh*0.76, function()
			TURBO = not TURBO
		
		end)
		
		if WATCHMODE then
			love.graphics.setColor(1, 1, 1, 1)		
		else
			love.graphics.setColor(1, 1, 1, 0.5)
		end
		RenderClickableText("Watch Mode", sh*0.05, sh*0.25, sh*0.86, sh*0.9, function()
			WATCHMODE = not WATCHMODE
		end)
		
		
		
		local OverlayType = EnvironmentOverlays[EnvironmentOverlayIndex]
		
		if OverlayType == "None" then
			love.graphics.setColor(1, 1, 1, 0.5)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
		RenderClickableText("Overlay ["..OverlayType.."]", sh*0.05, sh*0.25, sh*0.8, sh*0.84, function()
			EnvironmentOverlayIndex = EnvironmentOverlayIndex + 1
			if EnvironmentOverlayIndex > #EnvironmentOverlays then			
				EnvironmentOverlayIndex = 1
			end	
		end)		
		
		

		
		if GUI.SelectedOrganism ~= nil then
			if GUI.SelectedOrganism.Alive == 0 then
				GUI.SelectedOrganism = nil
				GUI.JustToNewOrganismTimer = 1.5
			end
			
			local Org = GUI.SelectedOrganism
			local OrgGenome = Genomes[Org.GenomeIndex]
			
			love.graphics.print("< "..OrgGenome.Name.." >", sw*0.85, sh*0.2, 0, 1, 1)				
			love.graphics.print("Energy "..floor(Org.Energy).."/"..floor(Org.EnergyMax).." >", sw*0.85, sh*0.24, 0, 1, 1)
			love.graphics.print("Energy Loss Per Sec "..Org.EnergyLossSec.." >", sw*0.85, sh*0.28, 0, 1, 1)
			love.graphics.print("Age: "..disp_time(Org.Age).." >", sw*0.85, sh*0.32, 0, 1, 1)
			love.graphics.print("Health: "..floor(Org.Health).."/"..floor(Org.HealthMax).." >", sw*0.85, sh*0.36, 0, 1, 1)
			
			love.graphics.rectangle("line", sw*0.85, sh*0.45, sw*0.1, sw*0.1)
			OrgGenome:Draw(sw*0.9, sh*0.5, sw*0.1)		


			if WATCHMODE then
				Camera:follow(Cells[Org.CoreIndex].ix, Cells[Org.CoreIndex].iy)
			else
				Camera.target_x = nil
				Camera.target_y = nil
			end
				
		end
		
		if WATCHMODE and GUI.SelectedOrganism == nil and GUI.JustToNewOrganismTimer <= 0 then
			love.graphics.printf("Searching for a new organism ...", sw*0.45, sh*0.05, sw*0.1, "center")			
			for i=1, 1000 do
				local Index = math.random(1, ModuleData.OrganismListSize)
				if Organisms[Index].Alive == 1 then
					GUI.SelectedOrganism = Organisms[Index]
				end
			end
		end
	
		if WATCHMODE then
			RenderClickableText2("Find New", sh*1.5, sh*0.66, sh*0.15, sh*0.05, function()
				GUI.SelectedOrganism = nil
				GUI.JustToNewOrganismTimer = 0
			end)	
		end







		if GUI.DebrisMenuOpen then
			love.graphics.setColor(1, 1, 1, 1)
		else
			love.graphics.setColor(1, 1, 1, 0.5)
		end
		RenderClickableText2("Debris Menu", sh*1.5, sh*0.8, sh*0.2, sh*0.07, function()
			GUI.DebrisMenuOpen = not GUI.DebrisMenuOpen
		end)	

		



		-- DBERIS MENU
		if GUI.DebrisMenuOpen then		
			GUI.ShowDebrisMenu()		
		end
		
		
		local CrossX, CrossY = love.mouse.getX(), love.mouse.getY()
		
		
		
		-- CROSSHAIR
		love.graphics.setColor(1, 1, 1, 1)		
		local scale = 0.2
		local w = Crosshair:getWidth()*scale
		love.graphics.draw(Crosshair, CrossX, CrossY, 0, scale, scale)
		--love.graphics.draw(Crosshair, sw*0.5-(w*0.5), sh*0.5-(w*0.5), 0, scale, scale)


		
	end


end





local DebrisMenu = {
	{"Algae", "Meat", "Sugar", "Veggie", "Veggie"}, 
	{"", "", "Sugar", "", ""}, 
	{"", "", "", "", ""}, 
	{"", "", "", "", ""}, 
	{"", "", "", "", ""}, 
}
function GUI.ShowDebrisMenu()	
	
	
	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()		
	local MenuSz = sh*0.65
	local MenuX = sw*0.5 - (MenuSz/2)
	local MenuY = sh*0.5 - (MenuSz/2)
	local EntrySpacing = sh*0.1
	
	love.graphics.setColor(0.1, 0.1, 0.1, 1)
	love.graphics.rectangle("fill", MenuX, MenuY, MenuSz, MenuSz)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", MenuX, MenuY, MenuSz, MenuSz)	
	
	for y, v in pairs(DebrisMenu) do
		for x, b in pairs(v) do
			local DrawX, DrawY = MenuX+(x*EntrySpacing), MenuY+(y*EntrySpacing)
			local Img
			local Type = b
			if b == "" then
				love.graphics.setColor(1, 1, 1, 0.5)
				love.graphics.print("XXX", DrawX, DrawY, 0, 1, 1)
			else
				if GUI.HeldDebris == b then
					love.graphics.setColor(1, 1, 1, 1)
				else
					love.graphics.setColor(1, 1, 1, 0.5)
				end
				
				love.graphics.printf(b, DrawX-(EntrySpacing*0.4), DrawY+sh*0.015, EntrySpacing*0.8, "center")
				love.graphics.draw(Types["Debris"][b].Image, DrawX, DrawY-sh*0.007, 0, 2, 2, 8, 8)
				RenderClickableBox("", DrawX, DrawY, EntrySpacing*0.8, EntrySpacing*0.8, function()
					GUI.HeldDebris = b
				end)		
			end
		end
	end



end




















return
GUI