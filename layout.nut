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


//******************************************************************************
// Background
//******************************************************************************
fe.add_image("backgrounds/[Name].png", 0, 0, flw, flh)


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
galleryargs.itemwidth = flw * 0.1
galleryargs.itemwidthwide = flw * 0.12
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
wheelimages.push(WheelImage(0.100, -0.255,  0.18,  -9, 150)) 
wheelimages.push(WheelImage(0.153,   0.13,  0.18,  -7, 150))   
wheelimages.push(WheelImage(0.180,   0.31,  0.18,  -5, 150)) 
wheelimages.push(WheelImage(0.193,    0.5, 0.215,   0, 255))
wheelimages.push(WheelImage(0.188,   0.69,  0.18,   5, 150))
wheelimages.push(WheelImage(0.164,   0.87,  0.18,   7, 150))
wheelimages.push(WheelImage(0.100,  1.255,  0.18,   9, 150))

local slots = [];
for (local i=0;i<wheelimages.len();i++)
	slots.push(WheelEntry(flw, flh, wheelimages, imgratio, imgpath))

local conveyor = Conveyor();
conveyor.set_slots(slots);
conveyor.transition_ms = 200;


//******************************************************************************
// Callbacks
//******************************************************************************

local current_ttime = 0
function ticks_callback(ttime)
{
	current_ttime = ttime

	gallery.swap(ttime)
	jukebox.swap(ttime)
}

function transition_callback(ttype, var, ttime) 
{
	switch(ttype) 
	{
		case Transition.ToNewList:
			jukebox.reset(var)
			break
	
		case Transition.ToNewSelection:	
			gallery.reset(current_ttime)
			jukebox.reset(var)
			break
	}
}

fe.add_ticks_callback("ticks_callback");
fe.add_transition_callback("transition_callback")