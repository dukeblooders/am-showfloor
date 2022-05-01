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
	
	
	constructor(_args, gamelist, logorect, wheelrects, imagerects)
	{
		args = _args
		previousload = -1
		previousswap = -1
		
		logo = PreserveImage("", logorect.x, logorect.y, logorect.width, logorect.height)
		logo.rotation = -90
		logo.art.visible = false
		
		wheels = []
		images = []
			
		local tempimg = null
		foreach	(imagerect in imagerects)
		{
			tempimg = PreserveImage("", imagerect.x, imagerect.y, imagerect.width, imagerect.height)
			tempimg.art.visible = false
		
			images.append(tempimg)
		}
		
		local tempwheel = null
		foreach	(wheelrect in wheelrects)
		{
			tempwheel = PreserveImage("", wheelrect.x, wheelrect.y, wheelrect.width, wheelrect.height)
			tempwheel.art.visible = false
		
			wheels.append(tempwheel)
		}
			
		getCodes()
		
		games = []
		foreach (game in gamelist)
			if (game.extra == args.systemcode)
				games.append(game)
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