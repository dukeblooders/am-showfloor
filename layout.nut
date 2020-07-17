//******************************************************************************
// Modules
//******************************************************************************

fe.load_module("animate");
fe.load_module("conveyor");
fe.load_module("file");

fe.do_nut("tools.nut");
fe.do_nut("preserve.nut");
fe.do_nut("imageGallery.nut");
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
local args = ImageGalleryArgs()
args.basepath = "../../../Roms/%s/media/box"
args.itemwidth = flw * 0.1
args.itemwidthwide = flw * 0.12
args.widecodes = [ "snes", "n64" ]
args.ignoredcodes = [ "arcade", "various" ]
args.space = 15

local galleryRect = Rectangle(flw * 0.33, flh * 0.77, flw * 0.66, flh * 0.2)
local gallery = ImageGallery(args, galleryRect)


//******************************************************************************
// Wheel
//******************************************************************************
local imgratio = 0.5
local imgpath = "platforms/[Name].png"

local wheelimages = []
wheelimages.push(WheelImage(0.100, -0.255,  0.18, -15, 150)) 
wheelimages.push(WheelImage( 0.15,   0.14,  0.18, -10, 150))   
wheelimages.push(WheelImage(0.171,   0.31,  0.18,  -5, 150)) 
wheelimages.push(WheelImage( 0.19,    0.5, 0.215,   0, 255))
wheelimages.push(WheelImage(0.185,   0.69,  0.18,   5, 150))
wheelimages.push(WheelImage(0.168,   0.86,  0.18,  10, 150))
wheelimages.push(WheelImage(0.100,  1.255,  0.18,  15, 150))

local slots = [];
for ( local i=0; i<wheelimages.len(); i++ )
	slots.push(WheelEntry(flw, flh, wheelimages, imgratio, imgpath))

local conveyor = Conveyor();
conveyor.set_slots( slots );
conveyor.transition_ms = 200;


//******************************************************************************
// Callbacks
//******************************************************************************

local current_ttime = 0
function ticks_callback(ttime)
{
	current_ttime = ttime

	gallery.swap(ttime)
}

function transition_callback(ttype, var, ttime) 
{
	switch(ttype) 
	{
		case Transition.ToNewSelection:	
			gallery.reset(current_ttime)
			break;
	}
}

fe.add_ticks_callback("ticks_callback");
fe.add_transition_callback("transition_callback")