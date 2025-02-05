


















local Tiles = {}
local TileIDs = {}









for k, Name in pairs(love.filesystem.getDirectoryItems("Assets/Tiles")) do
	
	local NewInd = #TileIDs+1
	local TileName = Name:sub(0, -5)
	Tiles[TileName] = {
		Img = love.graphics.newImage("Assets/Tiles/"..Name), 
		ID = NewInd,
	}
	TileIDs[NewInd] = TileName
end




















return
{Tiles, TileIDs}