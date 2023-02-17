//******************************************************************************
// Gallery arguments
//******************************************************************************
class ManufacturerGalleryArgs
{
	gameImages = null
	gamePath = null
	getRetries = 20
	loadDelay = 0
	manufacturerImage = null
	manufacturerPath = null
	swapDelay = 0
	systemCodes = null
	wheelImages = null
	wheelPath = null
	
	
	constructor(_manufacturerPath, _systemCodes, )
	{
		manufacturerPath = _manufacturerPath
		systemCodes = _systemCodes
	}
	
	function WithManufacturerImage(_manufacturerImage)
	{
		manufacturerImage = _manufacturerImage
		
		return this
	}
	
	function WithWheelImages(_wheelPath, _wheelImages)
	{
		wheelPath = _wheelPath
		wheelImages = _wheelImages
		
		return this
	}
	
	function WithGameImages(_gamePath, _gameImages)
	{
		gamePath = _gamePath
		gameImages = _gameImages
		
		return this
	}
	
	function WithLoadDelay(_loadDelay)
	{
		loadDelay = _loadDelay
		
		return this
	}
	
	function WithSwapDelay(_swapDelay)
	{
		swapDelay = _swapDelay
		
		return this
	}
}


//******************************************************************************
// Gallery
//******************************************************************************
class ManufacturerGallery
{
	args = null
	currentManufacturer = null
	imageExtension = null
	gameList = null
	manufacturers = null
	previousLoad = -1
	previousSwap = -1
	systemGames = []


	constructor(_args, _gameList, _imageExtension)
	{
		args = _args
		gameList = _gameList
		imageExtension = _imageExtension
			
		GetAllManufacturers()
		
		systemGames = []
		foreach (game in gameList)
			if (args.systemCodes.find(game.extra) != null)
				systemGames.append(game)
			
		if (args.manufacturerImage != null)
		{
			args.manufacturerImage.Create("")
			args.manufacturerImage.Visible(false)
		}
		
		if (args.wheelImages != null)
			foreach (wheelImage in args.wheelImages)
			{
				wheelImage.Create("")
				wheelImage.Visible(false)
			}
			
		if (args.gameImages != null)
			foreach (gameImage in args.gameImages)
			{
				gameImage.Create("")
				gameImage.Visible(false)
			}
	}
	
	
	function GetAllManufacturers()
	{
		local paths = DirectoryListing(args.manufacturerPath, false).results
	
		manufacturers = []
		foreach (path in paths)
		{
			local regex = regexp(imageExtension)
			
			if (regex.capture(path) != null)
				manufacturers.push(path.slice(0, path.len() - imageExtension.len()))
		}
	}
	
	
	function Reload()
	{
		local name = fe.game_info(Info.Name)
		
		if (args.systemCodes.find(name) != null)
		{
			currentManufacturer = GetNextManufacturer()
		
			if (args.manufacturerImage != null)
			{
				args.manufacturerImage.SetName(args.manufacturerPath + "/" + currentManufacturer + imageExtension)
				args.manufacturerImage.Visible(true)
			}
			
			local games = GetManufacturerGames()
			
			if (args.wheelImages != null)
				foreach (index, wheelImage in args.wheelImages)
				{
					args.wheelImages[index].SetName(args.wheelPath + "/" + games[index].name + imageExtension)
					args.wheelImages[index].Visible(true)
				}
				
				
			if (args.gameImages != null)
				foreach (index, gameImage in args.gameImages)
				{
					args.gameImages[index].SetName(args.gamePath + "/" + games[index].name + imageExtension)
					args.gameImages[index].Visible(true)
				}
		}
		else
		{
			Clear()
		}
	}
	
	
	// Get a random manufacturer, but not the one that is already displayed (if possible)
	function GetNextManufacturer()
	{
		local next = null
		for (local i = 0; i < args.getRetries; i++) // Retries until current manufacturer is retained
		{
			next = manufacturers[rand() % manufacturers.len()]
			
			if (currentManufacturer != next)
				break
		}
	
		return next	
	}
	
	
	// Get X random games for the current manufacturer
	function GetManufacturerGames()
	{
		local games = []
		local selection = []	
		local gameCount = 0
		
		if (args.gameImages != null)
			gameCount = args.gameImages.len()
		
		if (args.wheelImages != null)
			if (args.wheelImages.len() > gameCount)
				gameCount = args.wheelImages.len()

		foreach (game in systemGames)
			if (regexp(currentManufacturer).capture(game.manufacturer) != null)
				games.append(game)

		for (local i = 0; i < gameCount; i++)
			for (local j = 0; j < args.getRetries; j++)	// Retries until current game is retained
			{
				local game = games[rand() % games.len()]
				
				if (selection.find(game) == null)
				{	
					selection.append(game)
					break
				}
			}
			
		return selection
	}
	
	
	function Clear()
	{
		if (args.manufacturerImage != null)
			args.manufacturerImage.Visible(false)
			
		if (args.wheelImages != null)
			foreach (wheelImage in args.wheelImages)
				wheelImage.Visible(false)
		
		if (args.gameImages != null)
			foreach (gameImage in args.gameImages)
				gameImage.Visible(false)
				
		currentManufacturer = null
	}
	
	
	// Swap to the next manufacturer
	function Update(_ttime) 
	{
		if (previousLoad == 0)
		{
			if (currentManufacturer == null)
				return
				
			if (args.swapDelay != 0 && _ttime > previousSwap + args.swapDelay)
			{
				Reload()
			
				previousSwap = _ttime
			}		
		}
		else if (_ttime > previousLoad + args.loadDelay)
		{
			previousLoad = 0
			previousSwap = _ttime
			Reload()
		}
	}
	
	
	function Reset(_ttime)
	{	
		Clear()
	
		previousLoad = _ttime
	}
}