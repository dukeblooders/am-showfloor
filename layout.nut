//******************************************************************************
// Modules
//******************************************************************************

fe.load_module("animate");
fe.load_module("conveyor");
fe.load_module("file");

fe.do_nut("tools.nut");
fe.do_nut("preserve.nut");
fe.do_nut("arcadeGallery.nut");
fe.do_nut("imageGallery.nut");
fe.do_nut("jukebox.nut");
fe.do_nut("wheel.nut");

local flw = fe.layout.width;
local flh = fe.layout.height;
local current_ttime = 0
local ignoredcodes = [ "arcade", "various", "serie", "genre" ]

fe.layout.font = "OpenSans-Bold.ttf"

function resize(size)
{
	return size * flw / 1920 // Calculated from HD screen
}

//******************************************************************************
// Game list
//******************************************************************************
local gamelist = []
local file = ReadTextFile("romlists/All.txt")
local values = null
local temp = null, index = null, index1 = null, index2 = null

while (!file.eos())
{
	if (values == null) file.read_line() // Headers
	
	values = []
	values.resize(21, null)
	temp = file.read_line()
	
	index = 0
	index1 = 0
	while ((index2 = temp.find(";", index1)) != null)
	{
		if (index1 != index2)
			values[index] = temp.slice(index1, index2)
	
		index1 = index2 + 1
		index++
	}

	gamelist.append(Game(values[0], values[5], values[15]))
}


//******************************************************************************
// Background + System
//******************************************************************************
local background = fe.add_image("", 0, 0, flw, flh)


function resetBackground(var)
{
	background.file_name = "backgrounds/" + fe.game_info(Info.Name, var) + ".png"
}


//******************************************************************************
// Game count
//******************************************************************************
local gamecount = fe.add_text("", flw * 0.535, flh * 0.715, flw * 0.26, flh * 0.045)
gamecount.align = Align.Centre
gamecount.charsize = resize(30)
gamecount.style = Style.Bold

function resetGameCount(var)
{
	local count = 0
	local system = fe.game_info(Info.Name, var)
		
	for (local i = 0; i < ignoredcodes.len(); i++)
		if (ignoredcodes[i] == system || ignoredcodes[i] == fe.list.name)
		{
			gamecount.visible = false
			return
		}	
	
	foreach (game in gamelist)
		if (game.extra == system)
			count++

	gamecount.msg = count + " JEUX DISPONIBLES"
	gamecount.visible = true
}



//******************************************************************************
// Image gallery
//******************************************************************************
local imgGalleryArgs = ImageGalleryArgs()
imgGalleryArgs.basepath = "../../../Roms/%s/media/box"
imgGalleryArgs.itemwidthnarrow = resize(150)
imgGalleryArgs.itemwidth = resize(192)
imgGalleryArgs.itemwidthwide = resize(230)
imgGalleryArgs.narrowcodes = [ "saturn", "psp" ]
imgGalleryArgs.widecodes = [ "snes", "n64" ]
imgGalleryArgs.ignoredcodes = ignoredcodes
imgGalleryArgs.space = resize(19)

local imgGalleryRect = Rectangle(flw * 0.33, flh * 0.79, flw * 0.66, flh * 0.19)
local imgGallery = ImageGallery(imgGalleryArgs, imgGalleryRect)


//******************************************************************************
// Arcade gallery
//******************************************************************************
local arcadeGalleryArgs = ArcadeGalleryArgs()
arcadeGalleryArgs.manufacturercodepath = "arcade"
arcadeGalleryArgs.imagepath = "../../../Roms/arcade/media/images/%s.png"
arcadeGalleryArgs.wheelpath = "../../../Roms/arcade/media/wheel/%s.png"

local arcadeGallery = ArcadeGallery(arcadeGalleryArgs, gamelist, flw, flh)



//******************************************************************************
// Jukebox
//******************************************************************************
local jukeboxargs = JukeboxArgs()
jukeboxargs.basepath = "music/%s"
jukeboxargs.title_charsize = resize(26)
jukeboxargs.title_leftpadding = flw * 0.035

local jukeboxRect = Rectangle(flw * 0.43, flh * 0.91, flw * 0.47, flh * 0.06)
local jukebox = Jukebox(flw, jukeboxargs, jukeboxRect)


//******************************************************************************
// Wheel
//******************************************************************************
local imgratio = 0.5
local imgpath = "platforms/[Name].png"

local wheelimages = []
wheelimages.push(WheelImage(0.100, -0.255,  0.18,  -9, 165)) 
wheelimages.push(WheelImage(0.153,   0.13,  0.18,  -7, 190))   
wheelimages.push(WheelImage(0.180,   0.31,  0.18,  -5, 215)) 
wheelimages.push(WheelImage(0.193,    0.5, 0.215,   0, 255))
wheelimages.push(WheelImage(0.188,   0.69,  0.18,   5, 215))
wheelimages.push(WheelImage(0.164,   0.87,  0.18,   7, 190))
wheelimages.push(WheelImage(0.100,  1.255,  0.18,   9, 165))

local slots = [];
for (local i=0;i<wheelimages.len();i++)
	slots.push(WheelEntry(flw, flh, wheelimages, imgratio, imgpath))

local conveyor = Conveyor();
conveyor.set_slots(slots);
conveyor.transition_ms = 200;

//******************************************************************************
// Background + System
//******************************************************************************
local system = PreserveImage("", flw * 0.32, flh * 0.07, flw * 0.68, flh * 0.65)
local allSystemPaths = DirectoryListing("systems", false).results
local currentSystemPaths
local currentSystemIndex
local previousSystemSwap = 0
local systemSwapDelay = 7500


function resetSystem(var)
{
	previousSystemSwap = current_ttime
	currentSystemPaths = []
	system.file_name = ""
	
	getSystemPaths(fe.game_info(Info.Name, var))
	
	if (currentSystemPaths.len() != 0)
	{
		currentSystemIndex = rand() % currentSystemPaths.len()
		setSystem()
	}
}

function getSystemPaths(name)
{
	for (local i=0; i<allSystemPaths.len(); i++ )
	{
		local r = regexp(name)
		local t = r.capture(allSystemPaths[i])
		
		if (t != null)
			if (allSystemPaths[i].len() >= name.len() + 4) // + Extension
			{
				if (allSystemPaths[i] == name + ".png") // Match name exactly
					currentSystemPaths.push(allSystemPaths[i])
				else if (allSystemPaths[i][name.len()] == 95) // Match name_? (95 = _ )
					currentSystemPaths.push(allSystemPaths[i])
			}
	}
}

function setSystem()
{
	system.file_name = "systems/" + currentSystemPaths[currentSystemIndex]
	system.update()
}

function swapSystem(ttime)
{
	if (currentSystemPaths == null || currentSystemPaths.len() == 0)
		return

	if (ttime > previousSystemSwap + systemSwapDelay)
	{
		currentSystemIndex = currentSystemIndex + 1
		if (currentSystemIndex >= currentSystemPaths.len())
			currentSystemIndex = 0		
		
		setSystem()
		previousSystemSwap = ttime
	}
}


//******************************************************************************
// Callbacks
//******************************************************************************

function ticks_callback(ttime)
{
	current_ttime = ttime

	swapSystem(ttime)
	imgGallery.swap(ttime)
	arcadeGallery.swap(ttime)
	jukebox.swap(ttime)
}

function transition_callback(ttype, var, ttime) 
{
	switch(ttype) 
	{
		case Transition.ToNewList:
			resetBackground(var)
			resetGameCount(var)
			jukebox.reset(var)
			resetSystem(var)
			break
	
		case Transition.ToNewSelection:	
			resetBackground(var)
			resetGameCount(var)
			jukebox.reset(var)
			imgGallery.reset(current_ttime)
			arcadeGallery.reset(current_ttime)
			resetSystem(var)
			break
	}
}

fe.add_ticks_callback("ticks_callback");
fe.add_transition_callback("transition_callback")