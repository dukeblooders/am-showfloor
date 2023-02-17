//******************************************************************************
// Modules
//******************************************************************************
fe.load_module("conveyor");
fe.load_module("file")

fe.do_nut("preserve.nut")		// Clone of preserve-art: transitions removed
fe.do_nut("tools.nut")
fe.do_nut("jukebox.nut")
fe.do_nut("manufacturerGallery.nut")
fe.do_nut("systemGallery.nut")
fe.do_nut("wheel.nut")


//******************************************************************************
// Settings
//******************************************************************************
local arcadeGallery_args = ManufacturerGalleryArgs("./arcade", [ "arcade" ])
	.WithManufacturerImage(
		Image(0.007, 0.65, 0.17, 0.072, true)
			.WithRotation(-90))
	.WithWheelImages("../../../Roms/arcade/media/wheel", [ 
		Image(0.370, 0.333, 0.12, 0.062, true)	// Left cab
			.WithPinch(0, -7)
			.WithSkew(-9, -5)
			.WithRotation(-8),
		Image(0.535, 0.26, 0.158, 0.076, true)	// Middle cab
			.WithPinch(0, -10)
			.WithSkew(-11, -2)
			.WithRotation(-8),
		Image(0.751, 0.169, 0.21, 0.096, true)	// Right cab
			.WithPinch(0, -12)
			.WithSkew(-13, 0)
			.WithRotation(-8)])
	.WithGameImages("../../../Roms/arcade/media/images", [ 
		Image(0.394, 0.46, 0.1065, 0.174, true)	// Left cab
			.WithPinch(-3, -15)
			.WithSkew(-29, 7)
			.WithRotation(-2.2),
		Image(0.567, 0.42, 0.14, 0.213, true)	// Middle cab
			.WithPinch(-2, -20)
			.WithSkew(-37, 7)
			.WithRotation(-1.8),
		Image(0.794, 0.366, 0.185, 0.266, true)	// Right cab
			.WithPinch(-5, -22)
			.WithSkew(-45, 9)
			.WithRotation(-1.4)])	
	.WithLoadDelay(300)
	.WithSwapDelay(7000)	
local backgroundImage = Image(0, 0, 1, 1, false)
local backgroundImage_path = "./backgrounds"
local baseWidth = 1920							// Calculated from HD screen
local font_path = "OpenSans-Bold.ttf"
local gameCountText_displayMsg = "%s JEUX DISPONIBLES"
local gameCountText_ignoredSystemCodes = [ "arcade", "various", "serie", "genre" ]
local gameCountText = Text(0.535, 0.715, 0.26, 0.045)
	.WithAlign(Align.Centre)
	.WithCharSize(30)
	.WithStyle(Style.Bold)
local gameList_columnCount = 21
local gameList_columnIndex_name = 0
local gameList_columnIndex_manufacturer = 5		// For the arcade gallery
local gameList_columnIndex_extra = 15			// 'Extra' is used instead of 'emulator' to regroup some systems
local gameList_columnSeparator = ";"
local gameList_path = "./romlists/All.txt"
local imageExtension = ".png"
local imageSeparator = 95						// Multiple images for a game (95 = '_'): name.png, name_2.png, name_3.png
local jukebox_args = JukeboxArgs("./music", ".mp3", 0.43, 0.91, 0.47, 0.06, "custom3", 300)
	.WithBackgroundImage("./backgrounds/jukebox.png", Image(0, 0, 0.47, 0.06, true))		// Inner rectangle values
	.WithInputPreviousNext("custom1", "custom2")
	.WithTransition(0.003)
	.WithText(Text(0.04, 0, 0.43, 0.06)														// Inner rectangle values
		.WithAlign(Align.Left)
		.WithCharSize(26)
		.WithStyle(Style.Bold))
local systemImage = Image(0.32, 0.07, 0.68, 0.65, true)
local systemImage_path = "./systems"
local systemImage_swapDelay = 7500
local systemGallery_args = SystemGalleryArguments(0.32, 0.785, 0.68, 0.20, "../../../Roms/%s/media/box", 0.1, 0.01)
	.WithSystemCodes_Ignored([ "arcade", "various", "serie", "genre" ])
	.WithSystemCodes_Narrow([ "saturn", "psp" ], 0.08)
	.WithSystemCodes_Wide([ "snes", "n64" ], 0.12)
	.WithImageTransition(0.005)
	.WithGalleryTransition(0.05)
	.WithLoadDelay(500)
	.WithSwapDelay(1750)
local wheel_args = WheelArgs("./platforms/[Name]", [
		Image(0.100, -0.255, 0.18, 0.16, false)	// Out of screen (top)
			.WithAlpha(165)
			.WithRotation(-9),
		Image(0.153, 0.13, 0.18, 0.16, false)
			.WithAlpha(190)
			.WithRotation(-7),
		Image(0.180, 0.31, 0.18, 0.16, false)
			.WithAlpha(215)
			.WithRotation(-5),
		Image(0.193, 0.5, 0.215, 0.19, false)	// Middle
			.WithAlpha(255),
		Image(0.188, 0.69, 0.18, 0.16, false)
			.WithAlpha(215)
			.WithRotation(5),
		Image(0.164, 0.87, 0.18, 0.16, false)
			.WithAlpha(190)
			.WithRotation(7),
		Image(0.100, 1.255, 0.18, 0.16, false)	// Out of screen (bottom)
			.WithAlpha(165)
			.WithRotation(9)
		])
	.WithTransition(200)


//******************************************************************************
// Variables
//******************************************************************************
local arcadeGallery = null
local current_ttime = null
local gameList = null
local jukebox = null
local systemImage_allPaths = null
local systemImage_currentIndex = null
local systemImage_currentPaths = null
local systemImage_previouSwap = null
local systemGallery = null


//******************************************************************************
// Background
//******************************************************************************
function ResetBackground(_var)
{
	backgroundImage.SetName(backgroundImage_path + "/" + fe.game_info(Info.Name, _var) + imageExtension)
}


//******************************************************************************
// Game count
//******************************************************************************
function ResetGameCount(_var)
{
	local count = 0
	local system = fe.game_info(Info.Name, _var)
		
	if (gameCountText_ignoredSystemCodes.find(system) != null)
	{
		gameCountText.Visible(false)
		return
	}
	
	foreach (game in gameList)
		if (game.extra == system)
			count++

	gameCountText.SetMessage(format(gameCountText_displayMsg, count.tostring()))
	gameCountText.Visible(count != 0)
}


//******************************************************************************
// Game list
//******************************************************************************
function InitGameList()
{
	gameList = []

	local file = ReadTextFile(gameList_path)
	local line = null
	local nextSeparatorIndex = null

	while (!file.eos())
	{
		if (line == null) 	// First line: Headers
			file.read_line() 
		
		line = file.read_line()
		
		local values = []
		values.resize(gameList_columnCount, null)
		
		local valueIndex = 0
		local lastSeparatorIndex = 0
		while ((nextSeparatorIndex = line.find(gameList_columnSeparator, lastSeparatorIndex)) != null)
		{
			if (nextSeparatorIndex != lastSeparatorIndex)
				values[valueIndex] = line.slice(lastSeparatorIndex, nextSeparatorIndex)
		
			lastSeparatorIndex = nextSeparatorIndex + 1
			valueIndex++
		}
		
		local game = Game()
		game.name = values[gameList_columnIndex_name]
		game.manufacturer = values[gameList_columnIndex_manufacturer]
		game.extra = values[gameList_columnIndex_extra]
		
		gameList.append(game)
	}
}


//******************************************************************************
// System
//******************************************************************************
function ResetSystem(_var)
{
	systemImage.SetName("")

	systemImage_previouSwap = current_ttime
	systemImage_currentPaths = []
	
	GetSystemPaths(fe.game_info(Info.Name, _var))
	
	if (systemImage_currentPaths.len() != 0)
	{
		systemImage_currentIndex = rand() % systemImage_currentPaths.len()
		SetSystem()
	}
}


function GetSystemPaths(_name)
{
	foreach (systemImage_path in systemImage_allPaths)
	{
		local regex = regexp(_name)
		
		if (regex.capture(systemImage_path) != null)
			if (systemImage_path.len() >= _name.len() + imageExtension.len())
				if (systemImage_path == _name + imageExtension || 		// Matches the name exactly
					systemImage_path[_name.len()] == imageSeparator) 	// Matches the name + separator (ex. name_2)
					systemImage_currentPaths.push(systemImage_path)
	}
}


function SetSystem()
{
	systemImage.SetName(systemImage_path + "/" + systemImage_currentPaths[systemImage_currentIndex])
}


function UpdateSystem(_ttime)
{
	if (systemImage_currentPaths == null || systemImage_currentPaths.len() == 0)
		return

	if (_ttime > systemImage_previouSwap + systemImage_swapDelay)
	{
		systemImage_currentIndex = systemImage_currentIndex + 1
		if (systemImage_currentIndex >= systemImage_currentPaths.len())
			systemImage_currentIndex = 0		
		
		SetSystem()
		systemImage_previouSwap = _ttime
	}
}


//******************************************************************************
// Wheel
//******************************************************************************
function InitWheel()
{
	local slots = []
	for (local i = 0; i < wheel_args.wheelImages.len(); i++)
		slots.push(WheelSlot(wheel_args, imageExtension))

	local conveyor = Conveyor()
	conveyor.set_slots(slots)
	conveyor.transition_ms = wheel_args.transition_delay
}


//******************************************************************************
// Init
//******************************************************************************
fe.layout.font = font_path

InitGameList()

backgroundImage.Create("")
InitWheel()

gameCountText.Create("")
systemGallery = SystemGallery(systemGallery_args, imageSeparator, imageExtension)
arcadeGallery = ManufacturerGallery(arcadeGallery_args, gameList, imageExtension)

systemImage.Create("")
systemImage_allPaths = DirectoryListing(systemImage_path, false).results
systemImage_previouSwap = 0

jukebox = Jukebox(jukebox_args)

current_ttime = 0
fe.add_ticks_callback("TicksCallback")
fe.add_ticks_callback("TicksCallbackSystem")
fe.add_transition_callback("TransitionCallback")


//******************************************************************************
// Callbacks
//******************************************************************************
function TicksCallback(_ttime)
{
	current_ttime = _ttime

	systemGallery.Update(_ttime)
	arcadeGallery.Update(_ttime)
	jukebox.Update(_ttime)
}


function TicksCallbackSystem(_ttime)
{
	UpdateSystem(_ttime)
}


function TransitionCallback(_ttype, _var, _ttime) 
{
	switch(_ttype) 
	{
		case Transition.ToNewList:
			ResetBackground(_var)
			ResetGameCount(_var)
			ResetSystem(_var)
			jukebox.Reset(_var)
			break
	
		case Transition.ToNewSelection:	
			ResetBackground(_var)
			ResetGameCount(_var)
			systemGallery.Reset(current_ttime)
			arcadeGallery.Reset(current_ttime)
			ResetSystem(_var)
			jukebox.Reset(_var)
			break
	}
}