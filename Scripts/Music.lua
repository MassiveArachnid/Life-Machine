






local Music = {}









local Tracks = {}


for k, Name in pairs(love.filesystem.getDirectoryItems("Assets/Music")) do
	Tracks[#Tracks+1] = love.audio.newSource("Assets/Music/"..Name, "stream")
end




local MusicVolMod = 1
local MusicVolume = 1
local SongIndex = nil
local QuietTimer = 0
local RestartTimer = 0
Music.PlayMix = function(dt)

	if love.keyboard.isDown("m") then
		MusicVolMod = 0
		MusicVolume = 0
	end
	
	if QuietTimer > 0 then
		QuietTimer = QuietTimer - dt
	else
		-- Start music
		if SongIndex == nil then
			table.shuffle(Tracks)
			SongIndex = 1
			RestartTimer = math.random(60, 240)
		end
		
		
		RestartTimer = RestartTimer - dt
		-- fade in new song, out old
		local Duration = Tracks[SongIndex]:getDuration()
		local Progress = Tracks[SongIndex]:tell()
		local SecLeft = Duration-Progress
		if RestartTimer <= 15 then
			MusicVolume = (RestartTimer/15) * MusicVolMod
		elseif Progress <= 15 then
			MusicVolume = (Progress/15) * MusicVolMod
		end
		Tracks[SongIndex]:setVolume(MusicVolume)
		
		if not Tracks[SongIndex]:isPlaying() then
			if Progress == 0 then
				Tracks[SongIndex]:play()
			end
		end
		
		if RestartTimer <= 0 then
			RestartTimer = math.random(60, 240)
			Tracks[SongIndex]:stop()
			Tracks[SongIndex]:seek(0)
			SongIndex = SongIndex + 1
			QuietTimer = math.random(2, 5)
			if Tracks[SongIndex] == nil then -- Start over
				SongIndex = nil
			end
		end
	end


end










return
Music