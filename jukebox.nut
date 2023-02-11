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
	title_charsize = 26				// Size of sound title
	title_leftpadding = 0.035		// Left padding for text
	slidevalue = 5					// Speed of slide effect
}


//******************************************************************************
// Jukebox
//******************************************************************************
class Jukebox
{
	args = null; rectangle = null
	image = null; title = null; number = null
	paths = null; sounds = null
	jukebox = null
	sounditem = null; soundcount = 0; index = 0; playing = false
	previoustick = 0


	constructor(flw, _args, _rectangle)
	{
		args = _args
		rectangle = _rectangle
		
		sounditem = fe.add_sound("")
		sounditem.loop = false
		
		jukebox = fe.add_surface(_rectangle.width, _rectangle.height)
		jukebox.x = _rectangle.x
		jukebox.y = fe.layout.height
		jukebox.visible = false
		
		image = jukebox.add_image("backgrounds/jukebox.png", 0, 0, _rectangle.width, _rectangle.height)
		
		title = jukebox.add_text("", args.title_leftpadding, 0, _rectangle.width - args.title_leftpadding, _rectangle.height)
		title.charsize = args.title_charsize
		title.align = Align.Left
		title.style = Style.Bold
		
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
		title.msg = parseName(paths[index])
		
		if (playing) sounditem.playing = playing
	}
	
	
	function next() 
	{
		if (soundcount == 1)
			return;
	
		index = index == soundcount - 1 ? 0 : index + 1
		sounditem.file_name = paths[index]
		title.msg = parseName(paths[index])
		
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
			title.msg = parseName(paths[index])
		}	
		
		jukebox.visible = true
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
		
		fe.nv.rawset("jukeboxplaying", playing)
	}
	
	
	function swap(ttime) 
	{
		if (soundcount == 0)
			return
			
		if (playing)
		{
			if (!sounditem.playing)
				next()
				
			if (fe.get_input_state(args.input_stop_play))
			{
				if (ttime > previoustick + args.input_delay)
				{
					stop()
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

			if (jukebox.y > rectangle.y)
				jukebox.y -= args.slidevalue
		}
		else
		{
			if (fe.get_input_state(args.input_stop_play))
				if (ttime > previoustick + args.input_delay)
				{
					play()
					previoustick = ttime
				}
		
			if (jukebox.y < fe.layout.height)
			{
				jukebox.y += args.slidevalue
				
				if (jukebox.y >= fe.layout.height)
					jukebox.visible = false
			}
		}
	}
	
	
	function reset(var) 
	{
		title.msg = ""
		sounditem.file_name = ""
		sounditem.playing = false
		soundcount = 0
		index = 0
		
		init(var)
	}
}