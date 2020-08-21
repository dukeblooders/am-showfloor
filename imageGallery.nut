//******************************************************************************
// Gallery arguments
//******************************************************************************
class ImageGalleryArgs
{
	basepath = ""			// Use %s for current system/game
	itemwidth = 100			// Default width
	itemwidthwide = 150		// Width for wide items
	loaddelay = 400			// Delay before image load
	swapdelay = 1500		// Delay before image swap (100 = ~1 second)
	widecodes = null		// Items matching these codes are considered wide
	ignoredcodes = null		// Items matching these codes are ignored
	space = 10				// Space between items
}


//******************************************************************************
// Gallery
//******************************************************************************
class ImageGallery
{
	args = null; rectangle = null
	paths = null; images = null; lastswapindex = null
	previousload = 0; previousswap = 0
	
	
	constructor(_args, _rectangle)
	{
		args = _args
		rectangle = _rectangle
	}


	function init() 
	{
		images = []
	
		local name = fe.game_info(Info.Name)
		if (isIgnored(name))
			return
			
		getPaths(name)
		if (paths.len() == 0) return
			
		local width = isWide(name) ? args.itemwidthwide : args.itemwidth
		local imgcount = (rectangle.width / (width + args.space)).tointeger()
					
		// Center the gallery inside the rectangle
		local currentx = rectangle.x + (rectangle.width - (imgcount * width) - (args.space * (imgcount - 1))) / 2

		for ( local i=0; i<imgcount; i++ )
		{
			// Create an image in the middle of item width
			local img = ImageGalleryItem(getImagePath(), currentx, rectangle.y, width, rectangle.height)
		
			images.append(img)
			currentx += width + (i == imgcount - 1 ? 0 : args.space)
		}
	}
	
	
	function getPaths(name)
	{
		local pathlist = DirectoryListing(format(args.basepath, name)).results
	
		paths = []
		for (local i=0; i<pathlist.len(); i++ )
		{
			local r = regexp(".png")
			local t = r.capture(pathlist[i])
			
			if (t != null)
				paths.push(pathlist[i])
		}
	}
	
	
	function isIgnored(name)
	{
		if (args.ignoredcodes != null)
			for (local i=0; i<args.ignoredcodes.len(); i++)
				if (args.ignoredcodes[i] == name)
					return true
			
		return false
	}
	
	
	function isWide(name)
	{
		if (args.widecodes != null)
			for (local i=0; i<args.widecodes.len(); i++)
				if (args.widecodes[i] == name)
					return true
			
		return false
	}

	
	// Get a random image, but not one which is already displayed (if possible)
	function getImagePath()
	{
		local path = null
		for (local i=0; i<20; i++) // retries until keeping the current path
		{
			path = paths[rand() % paths.len()]
			
			if (!isImageDisplayed(path))
				return path
		}
	
		return path	
	}
	
	
	function isImageDisplayed(path)
	{
		for (local i=0; i<images.len(); i++) 
			if (images[i].path == path)
				return true
	
		return false	
	}
	
	
	// Swap image, but not the previous swapped image
	function swap(ttime) 
	{
		if (previousload == -1)
		{
			if (images == null || images.len() == 0)
				return
			
			if (ttime > previousswap + args.swapdelay)
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
		else if (ttime > previousload + args.loaddelay)
		{
			previousload = -1
			previousswap = ttime
			init()
		}
	}
	
	
	function reset(ttime)
	{	
		if (images != null)
			for (local i=0; i<images.len(); i++) 
				images[i].clear()
				
		previousload = ttime
	}
}



//******************************************************************************
// Gallery Item
//******************************************************************************
class ImageGalleryItem
{
	path = null; x = null; y = null; width = null; height = null
	img = null

	constructor(_path, _x, _y, _width, _height)
	{
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
		img = PreserveImage(path, x, y, width, height) 		
		img.update()
	}
	
	function clear()
	{
		img.art.visible = false
	}
}