//******************************************************************************
// Gallery arguments
//******************************************************************************
class ArcadeGalleryArgs
{
	systemcode = "arcade"
	imagepath = ""			// Use %s for game name
	wheelpath = ""			// Use %s for game name
	manufacturercodepath = ""
	loaddelay = 300			// Delay before items load
	swapdelay = 7000		// Delay before items swap (100 = ~1 second)
}


//******************************************************************************
// Gallery
//******************************************************************************
class ArcadeGallery
{
	args = null
	
	codes = null
	games = null
	currentcode = null
	logo = null
	images = null
	wheels = null
	previousload = null
	previousswap = null
	
	
	constructor(_args, gamelist, flw, flh)
	{
		args = _args
		previousload = -1
		previousswap = -1
		
		logo = PreserveImage("", flw * 0.007, flh * 0.65, flw * 0.17, flh * 0.072)
		logo.rotation = -90
		logo.art.visible = false
		
		wheels = []
		images = []
			
		// Screen - Left to right
		images.append(addImage(flw * 0.394, flh * 0.46, flw * 0.1065, flh * 0.174, -29, 7, -3, -15, -2.2))
		images.append(addImage(flw * 0.567, flh * 0.42, flw * 0.14, flh * 0.213, -37, 7, -2, -20, -1.8))
		images.append(addImage(flw * 0.794, flh * 0.366, flw * 0.185, flh * 0.266, -45, 9, -5, -22, -1.4))
			
			
		// Wheel - Left to right
		wheels.append(addImage(flw * 0.370, flh * 0.333, flw * 0.12, flh * 0.062, -9, -5, 0, -7, -8))	
		wheels.append(addImage(flw * 0.535, flh * 0.26, flw * 0.158, flh * 0.076, -11, -2, 0, -10, -8))		
		wheels.append(addImage(flw * 0.751, flh * 0.169, flw * 0.21, flh * 0.096, -13, 0, 0, -12, -8))			
					
		getCodes()
		
		games = []
		foreach (game in gamelist)
			if (game.extra == args.systemcode)
				games.append(game)
	}
	
	
	function addImage(x, y, width, height, skew_x, skew_y, pinch_x, pinch_y, rotation)
	{
		local tempimg = PreserveImage("", x, y, width, height)
		tempimg.art.visible = false

		tempimg.skew_x = skew_x
		tempimg.skew_y = skew_y
		tempimg.pinch_x = pinch_x
		tempimg.pinch_y = pinch_y
		tempimg.rotation = rotation
		
		return tempimg
	}
	
	
	function getCodes()
	{
		local pathlist = DirectoryListing(args.manufacturercodepath, false).results
	
		codes = []
		for (local i = 0; i < pathlist.len(); i++)
		{
			local r = regexp(".png")
			local t = r.capture(pathlist[i])
			
			if (t != null)
				codes.push(pathlist[i])
		}
	}


	function reload(var)
	{
		local name = fe.game_info(Info.Name, var)
		
		if (name == args.systemcode)
		{
			currentcode = getCodePath()
				
			logo.art.file_name = args.manufacturercodepath + "/" + currentcode
			logo.update()
			logo.art.visible = true
		
			local gamelist = getGames()
			for (local i = 0; i < images.len(); i++)
			{			
				images[i].art.file_name = format(args.imagepath, gamelist[i].name)
				images[i].update()
				images[i].art.visible = true
				
				wheels[i].art.file_name = format(args.wheelpath, gamelist[i].name)
				wheels[i].update()
				wheels[i].art.visible = true
			}
		}
		else
		{
			clear()
		}
	}
	
	
	function clear()
	{
		logo.art.visible = false
		
		foreach (image in images)
			image.art.visible = false
		foreach (wheel in wheels)
			wheel.art.visible = false
	}
	
	
	// Get a random code, but not one which is already displayed (if possible)
	function getCodePath()
	{
		local code = null
		for (local i = 0; i < 20; i++) // retries until keeping the current code
		{
			code = codes[rand() % codes.len()]
			
			if (currentcode != code)
				break
		}
	
		return code	
	}
	
	
	// Get X random games for the current code
	function getGames()
	{
		local gamelist = []
		local selection = []		
		local code = currentcode.slice(0, currentcode.len() - 4) // Remove extension
		local capture = null
		local game = null
		
		foreach (game in games)
		{
			capture = regexp(code).capture(game.manufacturer)
			if (capture != null)
				gamelist.append(game)
		}

		for (local i = 0; i < images.len(); i++)
			for (local j = 0; j < 20; j++) // retries until keeping the current game
			{
				game = gamelist[rand() % gamelist.len()]
				
				if (selection.find(game) == null)
				{	
					selection.append(game)
					break
				}
			}
			
		return selection
	}
	
	
	function swap(ttime) 
	{
		if (previousload == 0)
		{
			if (currentcode == null)
				return
			
			if (ttime > previousswap + args.swapdelay)
			{
				reload(0)
			
				previousswap = ttime
			}		
		}
		else if (ttime > previousload + args.loaddelay)
		{
			previousload = 0
			previousswap = ttime
			reload(0)
		}
	}
	
	
	function reset(ttime)
	{	
		clear()
	
		previousload = ttime
	}
}