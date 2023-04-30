//******************************************************************************
// Color
//******************************************************************************
class Color
{
	red = 0
	blue = 0
	green = 0
	alpha = 0
		
	constructor(_red, _green, _blue, _alpha = 255)
	{
		red = _red
		green = _green
		blue = _blue
		alpha = _alpha
	}
	
	function Apply(_obj)
	{
		_obj.red = red
		_obj.blue = blue
		_obj.green = green
		_obj.alpha = alpha
	}
}


//******************************************************************************
// Game
//******************************************************************************
class Game
{
	name = null
	manufacturer = null
	extra = null
}


//******************************************************************************
// Image
//******************************************************************************
class Image
{
	alpha = 255
	image = null
	name = null
	pinch_x = 0
	pinch_y = 0
	preserve = null
	rect = null
	rotation = 0
	skew_x = 0
	skew_y = 0
	
	
	constructor(_x, _y, _width, _height, _preserve, _fixedRect = false)
	{
		preserve = _preserve
		rect = _fixedRect ? FixedRectangle(_x, _y, _width, _height) : Rectangle(_x, _y, _width, _height)
	}
	
	function WithAlpha(_alpha)
	{
		alpha = _alpha
	
		return this
	}
	
	function WithPinch(_pinch_x, _pinch_y, _baseWidth)
	{
		pinch_x = fe.layout.width * _pinch_x / _baseWidth
		pinch_y = fe.layout.width * _pinch_y / _baseWidth
	
		return this
	}
	
	function WithSkew(_skew_x, _skew_y, _baseWidth)
	{
		skew_x = fe.layout.width * _skew_x / _baseWidth
		skew_y = fe.layout.width * _skew_y / _baseWidth
	
		return this
	}
	
	function WithRotation(_rotation)
	{
		rotation = _rotation
	
		return this
	}
	
	function Create(_name, _parent = ::fe)
	{
		if (_name == null)
			_name = ""
		name = _name
	
		if (preserve)
			image = PreserveImage(_name, rect.x, rect.y, rect.width, rect.height, _parent)
		else
			image = _parent.add_image(_name, rect.x, rect.y, rect.width, rect.height)
		
		image.alpha = alpha
		image.pinch_x = pinch_x
		image.pinch_y = pinch_y
		image.skew_x = skew_x
		image.skew_y = skew_y
		image.rotation = rotation
		
		if (preserve)
			image.update()
	}
	
	function GetLayoutImage()
	{
		return preserve ? image.surface : image
	}
	
	function SetName(_name)
	{
		name = _name
	
		if (preserve)
		{
			image.art.file_name = _name
			image.update()
		}
		else
			image.file_name = _name
	}
	
	function Visible(_value)
	{
		if (preserve)
			image.art.visible = _value
		else
			image.visible = _value
	}
}


//******************************************************************************
// Rectangle
//******************************************************************************
class Rectangle
{
	x = null
	y = null
	width = null
	height = null
	
	constructor(_x, _y, _width, _height)
	{
		x = fe.layout.width * _x
		y = fe.layout.height * _y
		width = fe.layout.width * _width
		height = fe.layout.height * _height
	}
}


class FixedRectangle extends Rectangle
{
	constructor(_x, _y, _width, _height)
	{
		x = _x
		y = _y
		width = _width
		height = _height
	}
}


//******************************************************************************
// Text
//******************************************************************************
class Text
{
	align = null
	charSize = null
	color = null
	rect = null
	style = null
	text = null
	
	
	constructor(_x, _y, _width, _height, _fixedRect = false)
	{
		rect = _fixedRect ? FixedRectangle(_x, _y, _width, _height) : Rectangle(_x, _y, _width, _height)
	}
	
	function WithAlign(_align)
	{
		align = _align
	
		return this
	}
	
	function WithCharSize(_charSize, _baseWidth)
	{
		charSize = fe.layout.width * _charSize / _baseWidth
	
		return this
	}
	
	function WithColor(_red, _green, _blue)
	{
		color = Color(_red, _green, _blue)
	
		return this
	}
	
	function WithStyle(_style)
	{
		style = _style
	
		return this
	}
	
	function Create(_msg, _parent = ::fe)
	{
		if (_msg == null)
			_msg = ""	
	
		text = _parent.add_text(_msg, rect.x, rect.y, rect.width, rect.height)
		if (align != null) text.align = align
		if (color != null) color.Apply(text)
		if (charSize != null) text.charsize = charSize
		if (style != null) text.style = style
	}
	
	function SetMessage(_msg)
	{
		text.msg = _msg
	}
	
	function Visible(_value)
	{
		text.visible = _value
	}
}