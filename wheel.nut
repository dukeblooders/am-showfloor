//******************************************************************************
// Slot
//******************************************************************************
class WheelEntry extends ConveyorSlot
{
	flw = null; flh = null; wheelimages = null; imgratio = null
	imgcount = null; maxcount = null

	constructor(_flw, _flh, _wheelimages, _imgratio, _imgpath)
	{
		flw = _flw
		flh = _flh
		wheelimages = _wheelimages
		imgratio = _imgratio

		base.constructor(fe.add_image(_imgpath));
	
		imgcount = wheelimages.len() 
		maxcount = imgcount - 1
	}

	function on_progress( progress, var )
	{
		local p = progress * imgcount
		if (p < 0) return // Ignore first image moving to top
		
		local index = p.tointeger()		
		if (index >= maxcount) 
			index = maxcount
		
		// The middle image is not at index zero, we must fix the progress manually 
		progress -= index * 1.0 / imgcount
			
		local width = getWidth(index, progress)
		local height = width * imgratio

		m_obj.x = getX(index, width, progress)
		m_obj.y = getY(index, height, progress)
		m_obj.width =  width
		m_obj.height = height
		m_obj.rotation = getRotation(index, progress)
		m_obj.alpha = getAlpha(index, progress)
	}
	
	function getX(index, width, progress)
	{
		local x1 = flw * wheelimages[index].x - width / 2
		local x2 = index == maxcount ? x1 : flw * wheelimages[index + 1].x - width / 2
		
		return x1 + (x2 - x1) * progress * imgcount
	}
	
	function getY(index, height, progress)
	{
		local y1 = flh * wheelimages[index].y - height / 2
		local y2 = index == maxcount? y1 : flh * wheelimages[index + 1].y - height / 2
				
		return y1 + (y2 - y1) * progress * imgcount
	}
	
	function getWidth(index, progress)
	{
		local w1 = flw * wheelimages[index].width
	
		if (progress == 0 || index != maxcount/2) // Don't apply on the middle object when moving
			return w1
		else
			return index == maxcount ? w1 : flw * wheelimages[index + 1].width
	}
	
	function getRotation(index, progress)
	{
		local r1 = wheelimages[index].rotation
		local r2 = index == maxcount ? r1 : wheelimages[index + 1].rotation
	
		return r1 + (r2 - r1) * progress * imgcount
	}
	
	function getAlpha(index, progress)
	{
		local a1 = flw * wheelimages[index].width
	
		if (progress == 0 || index != maxcount/2) // Don't apply on the middle object when moving
			return wheelimages[index].alpha
		else 
			return index == maxcount ? a1 : wheelimages[index + 1].alpha
	}
}


//******************************************************************************
// Image
//******************************************************************************
class WheelImage
{
	x = null; y = null; width = null; alpha = null; rotation = null
	
	constructor(_x, _y, _width,_rotation, _alpha)
	{
		x = _x
		y = _y
		width = _width
		rotation = _rotation
		alpha = _alpha
	}
}