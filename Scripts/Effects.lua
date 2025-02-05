








local Effects = {}














Effects[1] = {
	Color = {1, 1, 1},
	Texture = love.graphics.newImage("Assets/Effects/Convert.png"),
	Sound = love.audio.newSource("Assets/Effects/Convert.wav", "static"),
	Text = "Filter",
}
Effects[2] = {
	Color = {0.6, 1, 1},
	Texture = love.graphics.newImage("Assets/Effects/Convert.png"),
	Sound = love.audio.newSource("Assets/Effects/Convert.wav", "static"),
	Text = "Digested",
}

Effects[3] = {
	Color = {0.4, 0.2, 0.2},
	Texture = love.graphics.newImage("Assets/Effects/Convert.png"),
	Sound = love.audio.newSource("Assets/Effects/Convert.wav", "static"),
	Text = "STARVED",
}

Effects[4] = {
	Color = {1, 0.4, 0.2},
	Texture = love.graphics.newImage("Assets/Effects/Convert.png"),
	Sound = love.audio.newSource("Assets/Effects/Convert.wav", "static"),
	Text = "STAB",
}

Effects[5] = {
	Color = {0.7, 0.2, 0.2},
	Texture = love.graphics.newImage("Assets/Effects/Convert.png"),
	Sound = love.audio.newSource("Assets/Effects/Convert.wav", "static"),
	Text = "WOUNDED TO DEATH",
}








for k, v in pairs(Effects) do
	v.Texture:setFilter("nearest", "nearest")
end










return
Effects