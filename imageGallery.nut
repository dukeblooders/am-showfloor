//******************************************************************************
// Gallery arguments
//******************************************************************************
class ImageGalleryArgs
{
	basepath = ""			// Use %s for current system/game
	itemwidthnarrow = 75	// Width for narrow items
	itemwidth = 100			// Default width
	itemwidthwide = 150		// Width for wide items
	loaddelay = 500			// Delay before image load
	swapdelay = 1500		// Delay before image swap (100 = ~1 second)
	narrowcodes = null		// Items matching these codes are considered narrow
	widecodes = null		// Items matching these codes are considered wide
	ignoredcodes = null		// Items matching these codes are ignored
	space = 10				// Space between items
	slidevalue = 100		// Speed of slide effect
}


//******************************************************************************
// Gallery
//******************************************************************************
class ImageGallery
{
	args = null 
	rectangle = null
	
	images = null
	paths = null 
	gallery = null
	lastswapindex = null
	previousload = null
	previousswap = null
	
	
	constructor(_args, _rectangle)
	{
		args = _args
		rectangle = _rectangle
		previousload = -1
		previousswap = -1
		
		gallery = fe.add_surface(rectangle.width, rectangle.height)
		gallery.x = gallery.x = fe.layout.width
		gallery.y = rectangle.y
	}


	function init() 
	{
		images = []
	
		local name = fe.game_info(Info.Name)
		if (isIgnored(name))
			return
			
		getPaths(name)
		if (paths.len() == 0) return
					
		local width = isWide(name) ? args.itemwidthwide : 
			isNarrow(name) ? args.itemwidthnarrow : args.itemwidth
		local imgcount = (rectangle.width / (width + args.space)).tointeger()
					
		// Center the gallery inside the rectangle
		local currentx = (rectangle.width - (imgcount * width) - (args.space * (imgcount - 1))) / 2

		for (local i = 0; i < imgcount; i++)
		{
			// Create an image in the middle of item width
			local img = ImageGalleryItem(gallery, getImagePath(), currentx, 0, width, rectangle.height)
		
			images.append(img)
			currentx += width + (i == imgcount - 1 ? 0 : args.space)
		}
	}
	
	
	function getPaths(name)
	{
		local pathlist = DirectoryListing(format(args.basepath, name)).results
	
		paths = []
		for (local i = 0; i < pathlist.len(); i++)
		{
			local r = regexp(".png")
			local t = r.capture(pathlist[i])
			
			if (t != null)
				if (pathlist[i].find("_") == null) // Ignore gallery objects (files with _)
					paths.push(pathlist[i])
		}
	}
	
	
	function isIgnored(name)
	{
		if (args.ignoredcodes != null)
			for (local i = 0; i < args.ignoredcodes.len(); i++)
				if (args.ignoredcodes[i] == name)
					return true
			
		return false
	}
	
	
	// Has a box with a wide format (ex. SNES) ?
	function isWide(name)
	{
		if (args.widecodes != null)
			for (local i = 0; i < args.widecodes.len(); i++)
				if (args.widecodes[i] == name)
					return true
			
		return false
	}
	
	
	// Has a box with a narrow format (ex. PSP) ?
	function isNarrow(name)
	{
		if (args.narrowcodes != null)
			for (local i = 0; i < args.narrowcodes.len(); i++)
				if (args.narrowcodes[i] == name)
					return true
			
		return false
	}

	
	// Get a random image that is not already displayed (if possible)
	function getImagePath()
	{
		local path = null
		for (local i = 0; i < 20; i++) // retries until keeping the current path
		{
			path = paths[rand() % paths.len()]
			
			if (!isImageDisplayed(path))
				return path
		}
	
		return path	
	}
	
	
	function isImageDisplayed(path)
	{
		for (local i = 0; i < images.len(); i++) 
			if (images[i].path == path)
				return true
	
		return false	
	}
	
	
	// Swap image, but not the previous swapped image
	function swap(ttime) 
	{
		if (previousload == 0)
		{
			if (images == null || images.len() == 0)
				return
				
			// Slide gallery (right to left)
			if (gallery.x > rectangle.x)
				gallery.x -= args.slidevalue
				
			// Swap image (not the same as the last)
			else if (ttime > previousswap + args.swapdelay)
			{
				local index = null
				do {
					index = rand() % images.len()
				} while (index == lastswapindex)	
			
				images[index].path = getImagePath()
				images[index].clear()
				images[index].create()
				
				lastswapindex = index
				previousswap = ttime
			}	
		}
		
		// Wait for the load delay and init the gallery
		else if (ttime > previousload + args.loaddelay)
		{
			previousload = 0
			previousswap = ttime
			init()
		}
	}
	
	
	function reset(ttime)
	{	
		if (images != null)
			for (local i = 0; i < images.len(); i++) 
				images[i].clear()
				
		gallery.x = fe.layout.width
		previousload = ttime
	}
}



//******************************************************************************
// Gallery Item
//******************************************************************************
class ImageGalleryItem
{
	parent = null; path = null; x = null; y = null; width = null; height = null
	img = null

	constructor(_parent, _path, _x, _y, _width, _height)
	{
		parent = _parent
		path = _path
		x = _x
		y = _y
		width = _width
		height = _height
		
		create()
	}
	
	// Fixed height, width is auto
	function create()
	{
		img = PreserveImage(path, x, y, width, height, parent) 		
		img.update()
	}
	
	function clear()
	{
		img.art.visible = false
	}
}