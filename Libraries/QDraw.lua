



local QDraw = {}









local MouseRefreshed = true
QDraw.Image = function(Image, X, Y, Scale, Func, Settings)
	

	local SW = love.graphics.getWidth()	
	local SH = love.graphics.getHeight()	
	local IW = Image:getWidth()
	local IH = Image:getHeight()
	
	local DrawScale = (SW * Scale) / IW

	local Rot = 0
	if Settings.Rot ~= nil then
		Rot = Settings.Rot
	end
	
	love.graphics.draw(Image, (SW*X)+((IW/2)*DrawScale), (SH*Y)+((IH/2)*DrawScale), Rot, DrawScale, DrawScale, IW/2, IH/2)
	
	if Func ~= nil then
		--love.graphics.rectangle("line", SW*X, SH*Y, IW*DrawScale, IH*DrawScale)
	end
	
	if love.mouse.isDown(1) then
		if MouseRefreshed then
			MouseRefreshed = false
			local mx, my = love.mouse.getPosition()
			if mx >= SW*X and mx <= (SW*X)+IW and my >= SH*Y and my <= (SH*Y)+IH then
				Func()
			end
		end
	else
		MouseRefreshed = true
	end
	
end



QDraw.Text = function(Text, X, Y, Scale, Func, Settings)
	

	local SW = love.graphics.getWidth()	
	local SH = love.graphics.getHeight()	
	local IW = Image:getWidth()
	local IH = Image:getHeight()
	
	local DrawScale = (SW * Scale) / IW

	local Rot = 0
	if Settings.Rot ~= nil then
		Rot = Settings.Rot
	end
	
	love.graphics.text(Text, SW*X, SH*Y, Rot, DrawScale, DrawScale, 100000, 100000)
	
	if Func ~= nil then
		--love.graphics.rectangle("line", SW*X, SH*Y, IW*DrawScale, IH*DrawScale)
	end
	
	if love.mouse.isDown(1) then
		if MouseRefreshed then
			MouseRefreshed = false
			local mx, my = love.mouse.getPosition()
			if mx >= SW*X and mx <= (SW*X)+IW and my >= SH*Y and my <= (SH*Y)+IH then
				Func()
			end
		end
	else
		MouseRefreshed = true
	end
	
end



QDraw.MouseInArea = function(x, y, size)

	local mx, my = love.mouse.getPosition()
	if mx >= x and mx <= x+size and my >= y and my <= y+size then
		return true
	else
		return false
	end

end

QDraw.MousePressedInArea = function(x, y, size)

	if love.mouse.isDown(1) then
		local mx, my = love.mouse.getPosition()
		if mx >= x and mx <= x+size and my >= y and my <= y+size then
			if MouseRefreshed then
				MouseRefreshed = false
				return true
			end
		end
	else
		MouseRefreshed = true
	end

return false
end




return
QDraw