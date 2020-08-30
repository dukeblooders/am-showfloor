//******************************************************************************
// Jukebox arguments
//******************************************************************************
class JukeboxArgs
{
	basepath = ""					// Use %s for current system/game
	input_previous = "custom1"		// Previous sound
	input_next = "custom2"			// Next sound
	input_stop_play = "custom3"		// Stop/Play sound
	input_delay = 200				// Delay between inputs
	text_charsize = 22				// Size of sound title
}


//******************************************************************************
// Jukebox
//******************************************************************************
class Jukebox
{
	args = null; image = null; text = null
	paths = null; sounds = null
	sounditem = null; soundcount = 0; index = 0; playing = false
	previoustick = 0


	constructor(flw, _args, rectangle, textrectangle)
	{
		args = _args
		
		sounditem = fe.add_sound("")
		sounditem.loop = false
		
		image = fe.add_image("backgrounds/jukebox.png", rectangle.x, rectangle.y, rectangle.width, rectangle.height)
		image.visible = false
		
		text = fe.add_text("", textrectangle.x, textrectangle.y, textrectangle.width, textrectangle.height)
		text.charsize = args.text_charsize * flw / 1920 // Calculated from HD screen
		text.align = Align.Left
		text.style = Style.Bold
		text.visible = false
		
		if (fe.nv.rawin("jukeboxplaying"))
			playing = fe.nv.rawget("jukeboxplaying")
	}


	function init(var) 
	{
		sounds = []
					
		getPaths(fe.game_info(Info.Name, var))
		
		if (soundcount != 0)
			if (playing) 
				play()
	}
	
	
	function getPaths(name)
	{
		local pathlist = DirectoryListing(format(args.basepath, name)).results
	
		paths = []
		for (local i=0; i<pathlist.len(); i++ )
		{
			local r = regexp(".mp3")
			local t = r.capture(pathlist[i])
			
			if (t != null)
				paths.push(pathlist[i])
		}
		
		soundcount = paths.len()
	}
	
	
	function previous() 
	{
		if (soundcount == 1)
			return;
	
		index = index == 0 ? soundcount - 1 : index - 1	
		sounditem.file_name = paths[index]
		text.msg = parseName(paths[index])
		
		if (playing) sounditem.playing = playing
	}
	
	
	function next() 
	{
		if (soundcount == 1)
			return;
	
		index = index == soundcount - 1 ? 0 : index + 1
		sounditem.file_name = paths[index]
		text.msg = parseName(paths[index])
		
		if (playing) sounditem.playing = playing
	}
	

	function stop() 
	{
		playing = false
		updatePlaying()
	}
	
	
	function play() 
	{
		if (sounditem.file_name == "")
		{
			sounditem.file_name = paths[index]
			text.msg = parseName(paths[index])
		}	
	
		playing = true
		updatePlaying()
	}

	
	function parseName(name) 
	{
		local values = split(name, "/")
	
		name = values[values.len() - 1]
	
		return name.slice(0, name.len() - 4)
	}
	
	
	function updatePlaying() 
	{
		sounditem.playing = playing
		image.visible = playing
		text.visible = playing
		
		fe.nv.rawset("jukeboxplaying", playing)
	}
	
	
	function swap(ttime) 
	{
		if (soundcount == 0)
			return

		if (fe.get_input_state(args.input_stop_play))
		{		
			if (ttime > previoustick + args.input_delay)
			{
				if (playing) stop()
				else play()	
				previoustick = ttime
			}
		}
		else if (fe.get_input_state(args.input_previous))
		{
			if (ttime > previoustick + args.input_delay)
			{
				previous()
				previoustick = ttime
			}
		}
		else if (fe.get_input_state(args.input_next))
		{
			if (ttime > previoustick + args.input_delay)
			{
				next()
				previoustick = ttime
			}
		}
	}
	
	
	function reset(var) 
	{
		text.visible = false
		image.visible = false
	
		sounditem.file_name = ""
		sounditem.playing = false
		soundcount = 0
		index = 0
		
		init(var)
	}
}