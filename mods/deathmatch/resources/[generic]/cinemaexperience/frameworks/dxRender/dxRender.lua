-- Scripted by G&T Mapping & Loki

RES		            		=   {guiGetScreenSize()}
local SCRIPTER_RESOLUTION   =   {1280,1024} -- do not change
local X,Y                   =   RES[1] / SCRIPTER_RESOLUTION[1], RES[2] / SCRIPTER_RESOLUTION[2]
local SCALE                 =   (1 / SCRIPTER_RESOLUTION[1]) * RES[1]

local drawText, drawRectangle, drawImage = dxDrawText, dxDrawRectangle, dxDrawImage
local createBrowser, createStaticImage = guiCreateBrowser, guiCreateStaticImage
local createScrollPane, createLabel = guiCreateScrollPane, guiCreateLabel

function Text(...)
    arg[2], arg[3], arg[4], arg[5], arg[7] = arg[2] * X, arg[3] * Y, arg[4] * X, arg[5] * Y, ( arg[7] or 1 ) * SCALE
 
    return drawText(unpack(arg))
end
 
function Rectangle(...)
    arg[1], arg[2], arg[3], arg[4] = arg[1] * X, arg[2] * Y, arg[3] * X, arg[4] * Y
   
    return drawRectangle(unpack(arg))
end

function Image(...)
    arg[1], arg[2], arg[3], arg[4] = arg[1] * X, arg[2] * Y, arg[3] * X, arg[4] * Y
   
    return drawImage(unpack(arg))
end

function guiCreateBrowser(...)
    arg[1], arg[2], arg[3], arg[4] = arg[1] * X, arg[2] * Y, arg[3] * X, arg[4] * Y
   
    return createBrowser(unpack(arg))
end

function guiCreateStaticImage(...)
    arg[1], arg[2], arg[3], arg[4] = arg[1] * X, arg[2] * Y, arg[3] * X, arg[4] * Y
   
    return createStaticImage (unpack(arg))
end

function ScrollPane(...)
    arg[1], arg[2], arg[3], arg[4] = arg[1] * X, arg[2] * Y, arg[3] * X, arg[4] * Y
   
    return createScrollPane (unpack(arg))
end

function Label(...)
    arg[1], arg[2], arg[3], arg[4] = arg[1] * X, arg[2] * Y, arg[3] * X, arg[4] * Y
   
    return createLabel (unpack(arg))
end

function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
	if type( sEventName ) == 'string' and 
		isElement( pElementAttachedTo ) and 
		type( func ) == 'function' 
	then
		local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
		if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
			for i, v in ipairs( aAttachedFunctions ) do
				if v == func then
					return true
				end
			end
		end
	end
	return false
end

-- Scripted by G&T Mapping
function dxPopupMessage(text,ms,r1,g1,b1,r2,g2,b2,outside)
	if not text then return end

	if not isElementWithinColShape(localPlayer,cinemaCol) and not outside then
		return
	end	
	
	if not ms then
		ms = 3500
	end
	if not r1 and not g1 and not b1 then -- BG color
		r1,g1,b1 = 255,25,25
	end
	if not r2 and not g2 and not b2 then -- TEXT color
		r2,g2,b2 = 255,255,255
	end
	if isTimer(isPopupMessageVisible) then
		killTimer(isPopupMessageVisible)
		if isTimer(isPopupFading) then
			killTimer(isPopupFading)
		end
		removeEventHandler("onClientRender",root,popupMessage)
	end
	Fading = false
	isPopupFading = setTimer(function() Fading = true end,ms-1000,1)
	alpha1 = 0
	alpha2 = 0
	function popupMessage()
		if not Fading then
			alpha1 = alpha1+6
			if alpha1 >= 190 then alpha1 = 190 end
			alpha2 = alpha2+7
			if alpha2 >= 255 then alpha2 = 255 end
		else
			alpha1 = alpha1-6
			if alpha1 <= 0 then alpha1 = 0 end
			alpha2 = alpha2-7
			if alpha2 <= 0 then alpha2 = 0 end
		end
		Rectangle(88, 0, 1099, 81, tocolor(r1,g1,b1, alpha1), true)
		Text(text, 301 + 1, 40 + 1, 976 + 1, 40 + 1, tocolor(0, 0, 0, alpha2), 2.00, "default", "center", "center", false, false, true, false, false)
		Text(text, 301, 40, 976, 40, tocolor(r2,g2,b2, alpha1), 2.00, "default", "center", "center", false, false, true, false, false)
	end
	addEventHandler("onClientRender",root,popupMessage)
	isPopupMessageVisible = setTimer(function()removeEventHandler("onClientRender",root,popupMessage)end,ms,1)
end
addEvent("onDxPopupMessage",true)
addEventHandler("onDxPopupMessage",resourceRoot,dxPopupMessage)

local X2,Y2 = 128,128
function showLoadIcon(bool)
	if bool == true then
		if isEventHandlerAdded("onClientRender",root,icon) then
			removeEventHandler("onClientRender",root,icon)
		end
		rot = 0
		function icon()
			rot = rot+3
			dxDrawImage((RES[1]/2)-(X2/2), (RES[2]/2)-(Y2/2), X2, Y2, "img/loading.png", rot, 0, 0, tocolor(255, 255, 255, 255), true)
		end
		addEventHandler("onClientRender",root,icon)
	else
		removeEventHandler("onClientRender",root,icon)
	end
end
addEvent("showLoadIcon",true)
addEventHandler("showLoadIcon",resourceRoot,showLoadIcon)

-- mta functions
function isCursorOverArea(posX, posY, sizeX, sizeY)
    if(isCursorShowing()) then
        local cX, cY = getCursorPosition()
        local cX, cY = (cX*SCRIPTER_RESOLUTION[1]), (cY*SCRIPTER_RESOLUTION[2])
        if(cX >= posX and cX <= posX+(sizeX - posX)) and (cY >= posY and cY <= posY+(sizeY - posY)) then
            return true
        else
            return false
        end
    else
        return false
    end
end

function isCursorWithin(posX, posY, sizeX, sizeY)
    if(isCursorShowing()) then
        local cx, cy = getCursorPosition()
        local cx, cy = (cx*SCRIPTER_RESOLUTION[1]), (cy*SCRIPTER_RESOLUTION[2])
        if(cx >= x and cx <= x + sizeX) and (cy >= y and cy <= y + sizeY) then
            return true
        else
            return false
        end
    else
        return false
    end
end