function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

-- _getCursorPosition = getCursorPosition;

-- function getCursorPosition()
--     local x, y = _getCursorPosition();
--     return (x * screen.x), (y * screen.y)
-- end

_dxDrawText = dxDrawText

function dxDrawText(text, x, y, w, h, ...)
    return _dxDrawText(text, x, y, w + x, h + y, ...)
end

local fonts = {};
_dxCreateFont = dxCreateFont;

function dxCreateFont(path, size, ...)
	if not fonts[path][size] then
		fonts[path][size] = _dxCreateFont(path, size, ...)
	end
	return fonts[path][size] or "default"
end