//******************************************************************************
// Modules
//******************************************************************************

fe.load_module("animate");
fe.load_module("conveyor");
fe.load_module("file");

fe.do_nut("tools.nut");
fe.do_nut("preserve.nut");
fe.do_nut("imageGallery.nut");
fe.do_nut("jukebox.nut");
fe.do_nut("wheel.nut");

local flw = fe.layout.width;
local flh = fe.layout.height;
local current_ttime = 0


//******************************************************************************
// Background + System
//******************************************************************************

local background = fe.add_image("", 0, 0, flw, flh)
local system = PreserveImage("", flw * 0.32, flh * 0.087, flw * 0.68, flh * 0.65)
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
	
	local name = fe.game_info(Info.Name, var)
	background.file_name = "backgrounds/" + name + ".png"

	getSystemPaths(name)
	
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
// Overview
//******************************************************************************
fe.layout.font = "lucon.ttf"

local text = fe.add_text("[Overview]", flw * 0.5, flh * 0.02, flw * 0.495, flh * 0.15)
text.align = Align.Right
text.charsize  = 18 * flw / 1920 // Calculated from HD screen
text.word_wrap = true


//******************************************************************************
// Image gallery
//******************************************************************************
local galleryargs = ImageGalleryArgs()
galleryargs.basepath = "../../../Roms/%s/media/box"
galleryargs.itemwidthnarrow = flw * 0.08
galleryargs.itemwidth = flw * 0.1
galleryargs.itemwidthwide = flw * 0.12
galleryargs.narrowcodes = [ "psp" ]
galleryargs.widecodes = [ "snes", "n64" ]
galleryargs.ignoredcodes = [ "arcade", "various" ]
galleryargs.space = flw * 0.01

local galleryRect = Rectangle(flw * 0.33, flh * 0.77, flw * 0.66, flh * 0.2)
local gallery = ImageGallery(galleryargs, galleryRect)


//******************************************************************************
// Jukebox
//******************************************************************************
local jukeboxargs = JukeboxArgs()
jukeboxargs.basepath = "music/%s"

local jukeboxRect = Rectangle(flw * 0.43, flh * 0.02, flw * 0.47, flh * 0.05)
local jukeboxTextRect = Rectangle(flw * 0.47, flh * 0.02, flw * 0.395, flh * 0.045)
local jukebox = Jukebox(flw, jukeboxargs, jukeboxRect, jukeboxTextRect)


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
// Callbacks
//******************************************************************************

function ticks_callback(ttime)
{
	current_ttime = ttime

	swapSystem(ttime)
	gallery.swap(ttime)
	jukebox.swap(ttime)
}

function transition_callback(ttype, var, ttime) 
{
	switch(ttype) 
	{
		case Transition.ToNewList:
			resetSystem(var)
			jukebox.reset(var)
			break
	
		case Transition.ToNewSelection:	
			resetSystem(var)
			gallery.reset(current_ttime)
			jukebox.reset(var)
			break
	}
}

fe.add_ticks_callback("ticks_callback");
fe.add_transition_callback("transition_callback")