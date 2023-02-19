//******************************************************************************
// Gallery arguments
//******************************************************************************
class ManufacturerGalleryArgs
{
	gameImages = null
	gamePath = null
	gameTransitionFactor = null
	getRetries = 20
	loadDelay = 0
	manufacturerImage = null
	manufacturerPath = null
	manufacturerTransitionFactor = null
	swapDelay = 0
	systemCodes = null
	wheelImages = null
	wheelTransitionFactor = null
	wheelPath = null
	
	
	constructor(_manufacturerPath, _systemCodes, )
	{
		manufacturerPath = _manufacturerPath
		systemCodes = _systemCodes
	}
	
	function WithManufacturerImage(_manufacturerTransitionFactor, _manufacturerImage)
	{
		manufacturerImage = _manufacturerImage
		if (_manufacturerTransitionFactor != null)
			manufacturerTransitionFactor = _manufacturerTransitionFactor / 100.0
		
		return this
	}
	
	function WithGameImages(_gamePath, _gameTransitionFactor, _gameImages)
	{
		gamePath = _gamePath
		gameImages = _gameImages
		if (_gameTransitionFactor != null)
			gameTransitionFactor = _gameTransitionFactor / 100.0
			
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
	
	function WithWheelImages(_wheelPath, _wheelTransitionFactor, _wheelImages)
	{
		wheelPath = _wheelPath
		wheelImages = _wheelImages
		if (_wheelTransitionFactor != null)
			wheelTransitionFactor = _wheelTransitionFactor / 100.0
		
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
	manufacturerGames = null
	previousLoad = -1
	previousSwap = -1
	swapping = 0
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
			
			args.manufacturerImage.GetLayoutImage().x = -args.manufacturerImage.rect.width
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
	
	
	// Swap manufacturer
	function SwapManufacturer(_ttime)
	{	
		switch (swapping)
		{
			case 0:
				if (args.systemCodes.find(fe.game_info(Info.Name)) == null)
				{
					Clear()
					previousLoad = 0
				}
				else
				{
					currentManufacturer = GetNextManufacturer()
					manufacturerGames = GetManufacturerGames()
				
					if (SwapManufacturerImage_Out())
						swapping = -1
				}
				break
						
			case -1:
				local done = true
			
				if (args.wheelImages != null)
					foreach (index, wheelImage in args.wheelImages)
						if (!SwapImage_Shrink(index, wheelImage, args.wheelPath, args.wheelTransitionFactor))
							done = false
						
				if (args.gameImages != null)
					foreach (index, gameImage in args.gameImages)
						if (!SwapImage_Shrink(index, gameImage, args.gamePath, args.gameTransitionFactor))
							done = false

				if (done) swapping = 1
				break
				
			case 1:
				if (SwapManufacturerImage_In())
					swapping = 2
				break
			
			case 2:
				local done = true
			
				if (args.wheelImages != null)
					foreach (index, wheelImage in args.wheelImages)
						if (!SwapImage_Enlarge(index, wheelImage, args.wheelPath, args.wheelTransitionFactor))
							done = false
						
				if (args.gameImages != null)
					foreach (index, gameImage in args.gameImages)
						if (!SwapImage_Enlarge(index, gameImage, args.gamePath, args.gameTransitionFactor))
							done = false

				if (done)
				{
					swapping = 0
					previousLoad = 0
					previousSwap = _ttime
				}
				break
		}
	}
	
	
	function SwapManufacturerImage_Out()
	{
		if (args.manufacturerImage != null)
		{
			local layoutImage = args.manufacturerImage.GetLayoutImage();
		
			if (args.manufacturerTransitionFactor == null)
			{
				layoutImage.x = args.manufacturerImage.rect.x
			}
			else 
			{
				local diff = (args.manufacturerImage.rect.x + args.manufacturerImage.rect.width) * args.manufacturerTransitionFactor
			
				if (layoutImage.x - diff + args.manufacturerImage.rect.width > 0)
				{
					layoutImage.x -= diff
					return false
				}
				else
				{
					layoutImage.x = -args.manufacturerImage.rect.width
				}
			}
		}
		
		args.manufacturerImage.SetName(args.manufacturerPath + "/" + currentManufacturer + imageExtension)
		args.manufacturerImage.Visible(true)
		
		return true
	}
	
	
	function SwapManufacturerImage_In()
	{
		if (args.manufacturerImage != null && args.manufacturerTransitionFactor != null)
		{
			local layoutImage = args.manufacturerImage.GetLayoutImage();
			local diff = (args.manufacturerImage.rect.x + args.manufacturerImage.rect.width) * args.manufacturerTransitionFactor
		
			if (layoutImage.x + diff < args.manufacturerImage.rect.x)
			{
				layoutImage.x = layoutImage.x + diff
				return false
			}
			else
			{
				layoutImage.x = args.manufacturerImage.rect.x
			}
		}
		
		return true
	}
	
	
	function SwapImage_Shrink(_index, _image, _path, _factor)
	{
		if (_factor == null)
		{
			_image.Visible(false);
			
			return true
		}
		else
		{
			local layoutImage = _image.GetLayoutImage()
		
			if (layoutImage.width > 0)
			{
				local diffWidth = _image.rect.width * _factor
				local diffHeight = _image.rect.height * _factor
			
				if (layoutImage.width - diffWidth > 0)
				{
					layoutImage.width = layoutImage.width - diffWidth
					layoutImage.height = layoutImage.height - diffHeight
					layoutImage.x = _image.rect.x + _image.rect.width / 2 - layoutImage.width / 2
					layoutImage.y = _image.rect.y + _image.rect.height / 2 - layoutImage.height / 2
				}
				else
				{
					layoutImage.width = 0
					layoutImage.height = 0
					layoutImage.x = _image.rect.x
					layoutImage.y = _image.rect.y
					layoutImage.visible = false
				}
			}
			else if (layoutImage.width == 0)
			{
				layoutImage.width = _image.rect.width
				layoutImage.height = _image.rect.height
				_image.SetName(_path + "/" + manufacturerGames[_index].name + imageExtension)
				layoutImage.width = 0
				layoutImage.height = 0
				
				_image.Visible(true)
				
				return true
			}
			
			return false
		}
	}
	
	
	function SwapImage_Enlarge(_index, _image, _path, _factor)
	{
		if (_factor == null)
		{
			_image.Create(_path + "/" + manufacturerGames[_index].name + imageExtension)
			
			return true
		}
		else
		{
			local layoutImage = _image.GetLayoutImage()
			local diffWidth = _image.rect.width * _factor
			local diffHeight = _image.rect.height * _factor
		
			if (layoutImage.width + diffWidth < _image.rect.width)
			{
				layoutImage.visible = true
			
				layoutImage.width += diffWidth
				layoutImage.height += diffHeight
				
				layoutImage.x = _image.rect.x + _image.rect.width / 2 - layoutImage.width / 2
				layoutImage.y = _image.rect.y + _image.rect.height / 2 - layoutImage.height / 2
			}
			else
			{
				layoutImage.width = _image.rect.width 
				layoutImage.height = _image.rect.height
				layoutImage.x = _image.rect.x
				layoutImage.y = _image.rect.y
				
				return true
			}
			
			return false
		}
	}
	

	function Update(_ttime) 
	{
		if (previousLoad == 0)
		{
			if (currentManufacturer == null)
				return
				
			if (args.swapDelay != 0 && _ttime > previousSwap + args.swapDelay)
				SwapManufacturer(_ttime)
		}
		else if (_ttime > previousLoad + args.loadDelay)
		{
			SwapManufacturer(_ttime)
		}
	}
	
	
	function Reset(_ttime)
	{	
		Clear()
	
		previousLoad = _ttime
	}
}