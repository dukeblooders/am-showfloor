//******************************************************************************
// Jukebox arguments
//******************************************************************************
class JukeboxArgs
{
	inputDelay = 0
	input_next = null
	input_playStop = null
	input_previous = null
	imagePath = null
	jukeboxTransitionFactor = null
	soundExtension = null
	soundPath = null
	persistentValue = "jukeboxplaying"
	rect = null
	imagePath = null
	image = null
	text = null
	
	
	constructor(_soundPath, _soundExtension, _x, _y, _width, _height, _input_playStop, _inputDelay)
	{
		soundPath = _soundPath
		soundExtension = _soundExtension
		rect = Rectangle(_x, _y, _width, _height)
		input_playStop = _input_playStop
		inputDelay = _inputDelay
	}
	
	
	function WithBackgroundImage(_imagePath, _image)	// Inner rectangle values!
	{
		imagePath = _imagePath
		image = _image
		
		return this
	}
	
	
	function WithInputPreviousNext(_input_previous, _input_next)
	{
		input_previous = _input_previous
		input_next = _input_next
		
		return this
	}
	
	
	function WithText(_text)	// Inner rectangle values!
	{
		text = _text
		
		return this
	}
	
	
	function WithTransition(_jukeboxTransitionFactor)
	{
		jukeboxTransitionFactor = fe.layout.width * _jukeboxTransitionFactor
		
		return this
	}
}


//******************************************************************************
// Jukebox
//******************************************************************************
class Jukebox
{
	args = null
	jukebox = null
	playing = null
	previousTick = 0
	text = null
	sound = null
	soundIndex = 0
	soundPaths = null
	soundCount = null


	constructor(_args)
	{
		args = _args
		
		sound = fe.add_sound("")
		sound.loop = false
		
		jukebox = fe.add_surface(args.rect.width, args.rect.height)
		jukebox.x = args.rect.x
		jukebox.y = fe.layout.height
		jukebox.visible = false
		
		if (args.image != null)
			args.image.Create(args.imagePath == null ? "" : args.imagePath, jukebox)
		
		if (args.text != null)
			args.text.Create("", jukebox)

		if (fe.nv.rawin(args.persistentValue))
			playing = fe.nv.rawget(args.persistentValue)
	}
	
	
	function Reload(_var)
	{
		soundPaths = []
	
		GetPaths(fe.game_info(Info.Name, _var))
		
		if (soundPaths.len() != 0)
			if (playing)
				Play()
	}
	
	
	function GetPaths(name)
	{
		local paths = DirectoryListing(args.soundPath + "/" + name).results
	
		foreach	(path in paths)
		{
			local regex = regexp(args.soundExtension)
			
			if (regex.capture(path) != null)
				soundPaths.push(path)
		}
	}
	
	
	function Play() 
	{
		if (sound.file_name == "")
		{
			sound.file_name = soundPaths[soundIndex]
			if (args.text != null)
				args.text.SetMessage(ParseName(soundPaths[soundIndex]))
		}	
				
		jukebox.visible = true
		playing = true
		
		UpdatePlaying()
		
		if (args.jukeboxTransitionFactor == null)									
			jukebox.y = args.rect.y
	}
	
	
	function Stop() 
	{
		if (args.jukeboxTransitionFactor == null)
			jukebox.visible = false
	
		playing = false
		UpdatePlaying()
	}
	
	
	function Previous() 
	{
		if (soundPaths.len() == 1)
			return;
	
		soundIndex = soundIndex == 0 ? soundPaths.len - 1 : soundIndex - 1	
		sound.file_name = soundPaths[soundIndex]
		
		if (args.text != null)
			args.text.SetMessage(ParseName(soundPaths[soundIndex]))
		
		if (playing) 
			sound.playing = playing
	}
	
	
	function Next() 
	{
		if (soundPaths.len() == 1)
			return;
	
		soundIndex = soundIndex == soundPaths.len() - 1 ? 0 : soundIndex + 1
		sound.file_name = soundPaths[soundIndex]
		
		if (args.text != null)
			args.text.SetMessage(ParseName(soundPaths[soundIndex]))
			
		if (playing) 
			sound.playing = playing
	}
	
	
	function ParseName(_name) 
	{
		local values = split(_name, "/")
		local name = values[values.len() - 1]
	
		return name.slice(0, name.len() - args.soundExtension.len())
	}
	
	
	function UpdatePlaying() 
	{
		sound.playing = playing
		
		fe.nv.rawset(args.persistentValue, playing)
	}
	

	function Clear()
	{
		sound.file_name = ""
		sound.playing = false
		soundIndex = 0
	
		if (args.text != null)
			args.text.SetMessage("")
	}


	function Update(_ttime)
	{
		if (soundPaths.len() == 0)
			return			
			
		if (playing)
		{
			if (!sound.playing)
				Next()
				
			if (fe.get_input_state(args.input_playStop))
			{
				if (_ttime > previousTick + args.inputDelay)
				{
					Stop()
					previousTick = _ttime
				}
			}
			else if (fe.get_input_state(args.input_previous))
			{
				if (_ttime > previousTick + args.inputDelay)
				{
					Previous()
					previousTick = _ttime
				}
			}
			else if (fe.get_input_state(args.input_next))
			{
				if (_ttime > previousTick + args.inputDelay)
				{
					Next()
					previousTick = _ttime
				}
			}

			// Jukebox transition
			if (args.jukeboxTransitionFactor != null)
				if (jukebox.y > args.rect.y)
					jukebox.y = jukebox.y - args.jukeboxTransitionFactor < args.rect.y ? args.rect.y : jukebox.y - args.jukeboxTransitionFactor
		}
		else
		{
			if (fe.get_input_state(args.input_playStop))					
				if (_ttime > previousTick + args.inputDelay)
				{
					Play()
					previousTick = _ttime
				}
		
			// Jukebox transition
			if (args.jukeboxTransitionFactor != null)	
				if (jukebox.y < fe.layout.height)
				{
					jukebox.y = jukebox.y + args.jukeboxTransitionFactor > fe.layout.height ? fe.layout.height : jukebox.y + args.jukeboxTransitionFactor
					
					if (jukebox.y == fe.layout.height)
						jukebox.visible = false
				}
		}
	}
	
	
	function Reset(_var)
	{
		Clear()
		
		Reload(_var)
	}
}