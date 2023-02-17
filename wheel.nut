//******************************************************************************
// Wheel arguments
//******************************************************************************
class WheelArgs
{
	transition_delay = null
	wheelImages = null
	wheelPath = null	

	constructor(_wheelPath, _wheelImages)
	{
		wheelPath = _wheelPath
		wheelImages = _wheelImages
	}
	
	function WithTransition(_transition_delay)
	{
		transition_delay = _transition_delay
		
		return this
	}
}

//******************************************************************************
// Wheel
//******************************************************************************
class WheelSlot extends ConveyorSlot
{
	args = null
	imageCount = null
	maxImageIndex = null


	constructor(_args, _imageExtension)
	{
		args = _args

		base.constructor(fe.add_image(args.wheelPath + _imageExtension));
	
		imageCount = args.wheelImages.len() 
		maxImageIndex = imageCount - 1
	}
	
	
	function on_progress(_progress, _var)
	{
		local progress = _progress * imageCount
		if (progress < 0) return  // Ignore the first image moving to top
		
		local index = progress.tointeger()		
		if (index >= maxImageIndex) 
			index = maxImageIndex
		
		// The middle image is not at index zero, we must fix the progress manually 
		_progress -= index * 1.0 / imageCount
			
		local width = GetWidth(index, _progress)
		local height = width * args.wheelImages[index].rect.height / args.wheelImages[index].rect.width

		m_obj.x = GetX(index, width, _progress)
		m_obj.y = GetY(index, height, _progress)
		m_obj.width = width
		m_obj.height = height
		m_obj.rotation = GetRotation(index, _progress)
		m_obj.alpha = GetAlpha(index, _progress)
	}
	
	
	function GetX(_index, _width, _progress)
	{
		local x1 = args.wheelImages[_index].rect.x - _width / 2
		local x2 = _index == maxImageIndex ? x1 : args.wheelImages[_index + 1].rect.x - _width / 2
		
		return x1 + (x2 - x1) * _progress * imageCount
	}
	
	
	function GetY(_index, _height, _progress)
	{
		local y1 = args.wheelImages[_index].rect.y - _height / 2
		local y2 = _index == maxImageIndex ? y1 : args.wheelImages[_index + 1].rect.y - _height / 2
				
		return y1 + (y2 - y1) * _progress * imageCount
	}
	

	function GetWidth(_index, _progress)
	{
		local w1 = args.wheelImages[_index].rect.width
	
		if (_progress == 0 || _index != maxImageIndex / 2) // Don't apply on the middle object when moving
			return w1
		else
			return _index == maxImageIndex ? w1 : args.wheelImages[_index + 1].rect.width
	}
	
	
	function GetRotation(_index, _progress)
	{
		local r1 = args.wheelImages[_index].rotation
		local r2 = _index == maxImageIndex ? r1 : args.wheelImages[_index + 1].rotation
	
		return r1 + (r2 - r1) * _progress * imageCount
	}	
	
	
	function GetAlpha(_index, _progress)
	{
		local a1 = args.wheelImages[_index].rect.width
	
		if (_progress == 0 || _index != maxImageIndex / 2) // Don't apply on the middle object when moving
			return args.wheelImages[_index].alpha
		else 
			return _index == maxImageIndex ? a1 : args.wheelImages[_index + 1].alpha
	}
}