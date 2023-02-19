//******************************************************************************
// Gallery arguments
//******************************************************************************
class SystemGalleryArguments
{
	galleryTransitionFactor = null
	getRetries = 20
	imageTransitionFactor = null
	imagePath = null
	itemSpace = null
	itemWidth = null
	itemWidth_narrow = null
	itemWidth_wide = null
	loadDelay = 0
	rect = null
	systemCodes_ignored = null
	systemCodes_narrow = null
	systemCodes_wide = null
	swapDelay = 0
	
	
	constructor(_x, _y, _width, _height, _imagePath, _itemWidth, _itemSpace)
	{
		imagePath = _imagePath
		itemSpace = fe.layout.width * _itemSpace
		itemWidth = fe.layout.width * _itemWidth
		rect = Rectangle(_x, _y, _width, _height)
	}
	
	function WithGalleryTransition(_galleryTransitionFactor)
	{
		galleryTransitionFactor = _galleryTransitionFactor / 100.0
		
		return this
	}
		
	function WithImageTransition(_imageTransitionFactor)
	{
		imageTransitionFactor = _imageTransitionFactor / 100.0
		
		return this
	}

	function WithLoadDelay(_loadDelay)
	{
		loadDelay = _loadDelay
		
		return this
	}
	
	function WithSystemCodes_Ignored(_systemCodes_ignored)
	{
		systemCodes_ignored = _systemCodes_ignored
		
		return this
	}
	
	function WithSystemCodes_Narrow(_systemCodes_narrow, _itemWidth_narrow)
	{
		systemCodes_narrow = _systemCodes_narrow
		itemWidth_narrow = fe.layout.width * _itemWidth_narrow
		
		return this
	}
	
	function WithSystemCodes_Wide(_systemCodes_wide, _itemWidth_wide)
	{
		systemCodes_wide = _systemCodes_wide
		itemWidth_wide = fe.layout.width * _itemWidth_wide
		
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
class SystemGallery
{
	args = null
	gallery = null
	images = null
	imageExtension = null
	imageSeparator = null
	imagePaths = null
	previousLoad = -1
	previousSwap = -1
	swapping = 0
	swappingIndex = null
	
	
	constructor(_args, _imageSeparator, _imageExtension)
	{
		args = _args
		imageSeparator = _imageSeparator
		imageExtension = _imageExtension
		
		gallery = fe.add_surface(args.rect.width, args.rect.height)
		gallery.x = fe.layout.width
		gallery.y = args.rect.y
		gallery.visible = false
	}
	

	function Reload()
	{
		images = []
		imagePaths = []
	
		local name = fe.game_info(Info.Name)
		if (args.systemCodes_ignored != null && args.systemCodes_ignored.find(name) != null)
			return
				
		GetAllImagePaths(name)
		if (imagePaths.len() == 0) 
			return
				
		local itemWidth = 
			args.systemCodes_wide != null && args.systemCodes_wide.find(name) != null ?  args.itemWidth_wide :
			args.systemCodes_narrow != null && args.systemCodes_narrow.find(name) != null ?  args.itemWidth_narrow : 
			args.itemWidth
						
		local itemCount = (args.rect.width / (itemWidth + args.itemSpace)).tointeger()
		local currentX = (args.rect.width - (itemCount * itemWidth) - (args.itemSpace * (itemCount - 1))) / 2			// Center the gallery inside the rectangle
						
		for (local i = 0; i < itemCount; i++)
		{
			local image = Image(currentX, 0, itemWidth, args.rect.height, true, true)			// Create an image in the middle of item width
			image.Create(GetImagePath(), gallery)
			
			images.push(image)
			currentX += itemWidth + (i == itemCount - 1 ? 0 : args.itemSpace)
		}
		
		gallery.visible = true
	}
	
	
	function GetAllImagePaths(_name)
	{
		local paths = DirectoryListing(format(args.imagePath, _name)).results
	
		foreach (path in paths)
		{
			local regex = regexp(imageExtension)

			if (regex.capture(path) != null)
				if (path.find(imageSeparator.tochar()) == null) 		// Ignore images with separator (ex. name_2, name_3, ...)
					imagePaths.push(path)	
		}
	}
	
	
	// Get a random image, but not one that is already displayed (if possible)
	function GetImagePath()
	{
		local path = null
		for (local i = 0; i < args.getRetries; i++) 	// Retries until the current path is retained
		{
			path = imagePaths[rand() % imagePaths.len()]
			
			if (!IsImageDisplayed(path))
				break
		}
	
		return path	
	}
	
	
	function IsImageDisplayed(path)
	{
		foreach (image in images)
			if (image.name == path)
				return true
	
		return false	
	}
	
	
	// Swap one image (not the same as the previous one)
	function SwapImage(_ttime)
	{
		switch (swapping)
		{
			case 0:
				SwapImage_Init(_ttime)
				break
		
			case -1:
				SwapImage_Shrink()
				break
			
			case 1: 
				SwapImage_Enlarge(_ttime)		
				break
		}
	}


	function SwapImage_Init(_ttime)
	{
		local index = null
		do {
			index = rand() % images.len()
		} while (index == swappingIndex)	
		
		swappingIndex = index
		
		if (args.imageTransitionFactor == null)
		{
			images[swappingIndex].Visible(false)
			images[swappingIndex].Create(GetImagePath(), gallery)
			
			previousSwap = _ttime
		}
		else
		{
			swapping = -1
		}
	}


	function SwapImage_Shrink()
	{
		local layoutImage = images[swappingIndex].GetLayoutImage();
	
		if (layoutImage.width > 0)
		{
			local diff = images[swappingIndex].rect.width * args.imageTransitionFactor
		
			if (layoutImage.width - diff > 0)
			{
				layoutImage.width = layoutImage.width - diff
				layoutImage.x = images[swappingIndex].rect.x + images[swappingIndex].rect.width / 2 - layoutImage.width / 2
			}
			else
			{
				layoutImage.width = 0
				layoutImage.x = images[swappingIndex].rect.x
				layoutImage.visible = false
			}
		}
		else if (layoutImage.width == 0)
		{				
			layoutImage.width = images[swappingIndex].rect.width
			images[swappingIndex].SetName(GetImagePath())
			layoutImage.width = 0
			
			swapping = 1
		}
	}


	function SwapImage_Enlarge(_ttime)
	{
		local layoutImage = images[swappingIndex].GetLayoutImage();
		local diff = images[swappingIndex].rect.width * args.imageTransitionFactor
			
		if (layoutImage.width + diff < images[swappingIndex].rect.width)
		{
			layoutImage.visible = true
		
			layoutImage.width += diff
			layoutImage.x =  images[swappingIndex].rect.x + images[swappingIndex].rect.width / 2 - layoutImage.width / 2
		}
		else
		{
			layoutImage.width = images[swappingIndex].rect.width 
			layoutImage.x = images[swappingIndex].rect.x
			
			swapping = 0
			previousSwap = _ttime
		}
	}


	function Clear()
	{
		if (images != null)
		{
			foreach (image in images)
				image.Visible(false)

			images = null
		}
				
		gallery.x = fe.layout.width
		gallery.visible = false
		swapping = 0
	}


	function Update(_ttime) 
	{
		if (previousLoad == 0)
		{
			if (images == null || images.len() == 0)
				return
		
			// Gallery transition
			if (args.galleryTransitionFactor == null)
				gallery.x = args.rect.x
			else if (gallery.x > args.rect.x)
			{
				local diff = (fe.layout.width - args.rect.x) * args.galleryTransitionFactor
				
				gallery.x = gallery.x - diff < args.rect.x ? args.rect.x : gallery.x - diff
			}
			
			// Swap image
			else if (args.swapDelay != 0 && _ttime > previousSwap + args.swapDelay)
				SwapImage(_ttime)
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