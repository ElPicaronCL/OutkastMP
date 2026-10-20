-- Scripted by G&T Mapping & Loki

-------------------
--  SETTINGS/XML --
-------------------

local nodes = {
    "theater",
    "playback",
    "audio",
    "queue",
    "ambilight",
    "audience",
    "time",
    "weapons"
}
if not fileExists("cfg/settings.xml") then
    local node = xmlCreateFile("cfg/settings.xml","Settings")
    for ind, nn in ipairs(nodes) do
        local child = xmlCreateChild( node, tostring(nn))
        xmlNodeSetValue( child, "1" )
    end
    xmlSaveFile(node)
    xmlUnloadFile(node)
    outputDebugString("G&T Cinema settings created Successfully.")
end

function changeSetting(settingName)
    if getElementType(source) =="player" and not isPlayerManager(source) then
        triggerClientEvent(source,"onDxPopupMessage",resourceRoot,"You don't have permission to do this.",3500,255,255,255,255,0,0)
        return
    end
    if not fileExists("cfg/settings.xml") then
        triggerClientEvent(source,"onDxPopupMessage",resourceRoot,"Can't find settings file, please restart the resource.",3500)
    else
        local node = xmlLoadFile("cfg/settings.xml")
        for _,child in ipairs(xmlNodeGetChildren( node ))do
            if xmlNodeGetName( child ) == settingName:lower() then
                local val = xmlNodeGetValue( child )
                if val == "1" then
                    xmlNodeSetValue( child, "0" )
                    triggerClientEvent(source,"onDxPopupMessage",resourceRoot, settingName.." disabled.",2000)
                else
                    xmlNodeSetValue( child, "1" )
                    triggerClientEvent(source,"onDxPopupMessage",resourceRoot, settingName.." enabled.",2000)
                end
            end
        end
        xmlSaveFile(node)
        xmlUnloadFile(node)
        settingsUpdate()
    end
end
addEvent("onSettingChanged",true)
addEventHandler("onSettingChanged",root,changeSetting)

function settingsUpdate()
    local settingsTable = {}
    local node = xmlLoadFile("cfg/settings.xml")
    for _,child in ipairs(xmlNodeGetChildren( node ))do
        local val = xmlNodeGetValue( child )
        local childName = xmlNodeGetName( child )
        if val == "1" then
            val = true
        else 
            val = false
        end
        table.insert(settingsTable,1,{childName, val})
        settingsHandler(childName,val)
    end
	triggerClientEvent( "updatedSettings", resourceRoot, settingsTable )
    xmlUnloadFile(node)
end
addEvent( "updateCheckedSettings",true )
addEventHandler("updateCheckedSettings",resourceRoot,settingsUpdate)

-----------------------
-- ENTRY/LEAVE STUFF --
-----------------------

local entryMarker1 = createMarker(-1961.9163818359, 441.00451660156, 36.471875,"arrow",2.0,0,0,0,0 )
local entryMarker2 = createMarker(-1961.9163818359, 434.25451660156, 36.471875,"arrow",2.0,0,0,0,0 )
local entryPos = {-1944.1446533203, 417.55212402344, -4} -- rot 0

local exitMarker1 = createMarker(-1941.7396240234, 415.32360058594, -3.3265624046326,"arrow",2.0,255,255,255 )
local exitMarker2 = createMarker(-1946.6325683594, 415.32360839844, -3.3265624046326,"arrow",2.0,255,255,255 )
local exitPos = {-1970.8629150391, 437.7082824707, 35.6} -- rot 90

function setPlayerPositions(plr,pos,resourceStart)
	if pos == "outside" then
		if resourceStart then
			setElementPosition(plr,unpack(exitPos))
			setTimer(setElementRotation,250,1,plr,0,0,90)
			setTimer(setCameraTarget,500,1,plr,plr)
			return
		else
			posX,posY,posZ = unpack(exitPos)
			posRot = 90
			local h,m = getTime()
			local w = getWeather()
			local md = getMinuteDuration()
			setTimer(triggerClientEvent,1200,1,plr,"updateTimeOnExitCinema",resourceRoot,h,m,w,md)
		end
	elseif pos == "inside" then
		posX,posY,posZ = unpack(entryPos)
		posRot = 0
		triggerClientEvent(plr,"updateTimeOnEnterCinema",resourceRoot)
	end
	fadeCamera(plr,false)
	setTimer(fadeCamera,1500,1,plr,true)
	setTimer(setElementPosition,1200,1,plr,posX,posY,posZ)
	setTimer(setElementRotation,1300,1,plr,0,0,posRot)
	setTimer(setCameraTarget,1500,1,plr,plr)
end

function doorMarkers(plr)
	if getElementType(plr) == "player" then
		if not isPedInVehicle(plr) then
			if source == entryMarker1 or source == entryMarker2 then
				if isOpen or isObjectInACLGroup("user."..getAccountName(getPlayerAccount(plr)),aclGetGroup(aclGroup)) or isPlayerManager(plr) then 
					setPlayerPositions(plr,"inside",false)
					else
					triggerClientEvent(plr,"onDxPopupMessage",resourceRoot, "I'm sorry but we are closed. Please come again later.",4000,255,0,0,255,255,255,true)
				end
			elseif source == exitMarker1 or source == exitMarker2 then
				setPlayerPositions(plr,"outside",false)
			end
		end
	end 
end
addEventHandler("onMarkerHit",resourceRoot,doorMarkers)

function kickPlayerFromTheater(source,everyOne,selectedPlayer)
    local playersInside = getElementsWithinColShape(cinemaCol,"player")
    for _,plr in pairs(playersInside) do
        if getElementType(source) == "player" then
            if isPlayerManager(source) then
                if selectedPlayer then
                    setPlayerPositions(selectedPlayer,"outside",false)
                    triggerClientEvent(source,"onDxPopupMessage",resourceRoot,"You've kicked "..getPlayerName(selectedPlayer).." out of the theater.")
                elseif everyOne == "visitors" then
                    if isObjectInACLGroup("user."..getAccountName(getPlayerAccount(plr)),aclGetGroup(aclGroup)) then return end
                    setPlayerPositions(plr,"outside",false)
                elseif everyOne == "everyone" then
                    setPlayerPositions(plr,"outside",false)
                end
                triggerClientEvent(plr,"onDxPopupMessage",resourceRoot,"You've been kicked out of the theater by "..getPlayerName(source),6000,255,255,255,255,0,0,true)
            else
                triggerClientEvent(source,"onDxPopupMessage",resourceRoot,"You don't have permission to do this.",3500,255,255,255,255,0,0)
            end
        end
    end
end
addEvent("onKickPlayerFromTheater",true)
addEventHandler("onKickPlayerFromTheater",resourceRoot,kickPlayerFromTheater)

function kickPlayerFromTheaterOnStart()
    local playersInside = getElementsWithinColShape(cinemaCol,"player")
    for _,plr in pairs(playersInside) do
        setPlayerPositions(plr,"outside",true)
		local h,m = getTime()
		local w = getWeather()
		local md = getMinuteDuration()
		setTimer(triggerClientEvent,300,1,plr,"updateTimeOnExitCinema",resourceRoot,h,m,w,md,true)
    end
end

function settingsHandler(setting,tog)
    if setting == "theater" then
        if tog then         
            setMarkerColor( entryMarker1, 0, 255, 0, 255 )
            setMarkerColor( entryMarker2, 0, 255, 0, 255 )
            isOpen = true
        else
            setMarkerColor( entryMarker1, 255, 0, 0, 255 )
            setMarkerColor( entryMarker2, 255, 0, 0, 255 )
            isOpen = false
        end
    end

    if setting == "playback" then
    end

    if setting == "audio" then
    end

    if setting == "queue" then
    end

    if setting == "ambilight" and tog ~= ambilight then
        triggerClientEvent( "onToggleAmbilights",resourceRoot,tog)
        ambilight = tog
    end

    if setting == "audience" and tog ~= audience then
        createFakeCrowd(tog)
        audience = tog
    end

    if setting == "time" and tog ~= time then
    	for _,p in pairs(playersInCinema)do
    		local h,m = getTime()
			local w = getWeather()
			local md = getMinuteDuration()
			if isElement(p) then
				triggerClientEvent(p,"updateTimeOnExitCinema",resourceRoot,h,m,w,md)
			end
    	end
    end

    if setting == "weapons" then
        toggleWeapon(tog)
        setElementData( cinemaCol, "weapons", tog )
    end
end

-------------------
--   FUNCTIONS   --
------------------

-- colshape and visitor count

playersInCinema = getElementsWithinColShape(cinemaCol,"player")
addEventHandler("onResourceStart",resourceRoot,function()
	setTimer(triggerClientEvent,500,1, "updatedPlayersInCinema", resourceRoot, playersInCinema )
end)

--------------------
-- MANAGERS / XML --
--------------------

if not fileExists("cfg/managers.xml") then
    local xml = xmlCreateFile("cfg/managers.xml","Privileges")
    local node = xmlCreateChild(xml,"Serial")
    xmlNodeSetAttribute(node,"Name","")
    xmlSaveFile(xml)
    xmlUnloadFile(xml)
end

function setPrivileges(player)
    if isObjectInACLGroup("user."..getAccountName(getPlayerAccount(source)),aclGetGroup(aclGroup)) then
        local serial = getPlayerSerial(player)
        local xml = xmlLoadFile("cfg/managers.xml")
        if xml then
            local serialNodes = xmlNodeGetChildren(xml)
            if serialNodes then
                for _,node in pairs(serialNodes) do
                    local value = xmlNodeGetValue(node)
                    if value == '' then
                        xmlDestroyNode(node)
                    end
                    if value == serial then
                        xmlDestroyNode(node)
                        triggerClientEvent(source,"onDxPopupMessage",resourceRoot,"Removed privileges for "..getPlayerName(player),2500)
                        if source ~= player then
                            triggerClientEvent(player,"onDxPopupMessage",resourceRoot,"Your privileges have been removed by "..getPlayerName(source),2500)
                        end
                        xmlSaveFile(xml)
                        xmlUnloadFile(xml)
                        return
                    end
                end
            end
            local newNode = xmlCreateChild(xml,"Serial")
            xmlNodeSetValue(newNode,serial)
            xmlNodeSetAttribute(newNode,"Name",getPlayerName(player))
            triggerClientEvent(source,"onDxPopupMessage",resourceRoot,"Added privileges for "..getPlayerName(player),2500)
            if source ~= player then
                triggerClientEvent(player,"onDxPopupMessage",resourceRoot,"You have been granted privileges by "..getPlayerName(source),2500)
            end
            xmlSaveFile(xml)
            xmlUnloadFile(xml)
        end
    else
        triggerClientEvent(player,"onDxPopupMessage",resourceRoot,"Only admins can add/remove staff members.",3500,255,255,255,255,0,0)
    end
end
addEvent("addPlayerToVIP",true)
addEventHandler("addPlayerToVIP",root,setPrivileges)

function isPlayerManager(player)
    if fileExists("cfg/managers.xml") then
        if getElementType(player) == "player" then
            local serial = getPlayerSerial(player)
            local xml = xmlLoadFile("cfg/managers.xml")
            local playerNodes = xmlNodeGetChildren(xml)
            for _,node in pairs(playerNodes) do
                local value = xmlNodeGetValue(node)
                if value == serial then
                    xmlUnloadFile(xml)
                    return true
                end
            end
        end
    end
end

function enterupdate ( thePlayer )
    playersInCinema = getElementsWithinColShape( cinemaCol,"player" )
    triggerClientEvent( "updatedPlayersInCinema", resourceRoot, playersInCinema )
    if getElementData(cinemaCol,"weapons") ~= true and getElementType(thePlayer) == "player" then
        toggleWeapons(thePlayer,false)
    end
    if ambilight then
        triggerClientEvent(thePlayer, "onToggleAmbilights", root, true)
    end
end
addEventHandler ( "onColShapeHit", cinemaCol, enterupdate )

function exitUpdate ( thePlayer )
    local player = thePlayer or source
    if cinemaCol then
        playersInCinema = getElementsWithinColShape( cinemaCol,"player" )
		
		if #playersInCinema == 0 then
			triggerEvent("globalStop",resourceRoot,player)
		end
		
        setTimer(function()
			triggerClientEvent( "updatedPlayersInCinema", resourceRoot, playersInCinema )
		end,200,1)
    end
end
addEventHandler ( "onColShapeLeave", cinemaCol, exitUpdate )

addEventHandler ( "onPlayerQuit", cinemaCol, function()
    for i,plr in ipairs(playersInCinema) do
        if plr == source then
            table.remove(playersInCinema, i)
            return
        end
    end
end)

addEventHandler ( "onPlayerJoin", resourceRoot, exitUpdate )

-- Toggle Weapons --

function toggleWeapon(enabled)
    for _,player in pairs (playersInCinema)do
        if isElement(player) then
            toggleWeapons(player,enabled)
        end
    end
end
function removeWeaponSetting(leaveElement)
    toggleWeapons(leaveElement,true)
end
addEventHandler("onColShapeLeave",cinemaCol,removeWeaponSetting)
function toggleWeapons(player,enabled)
	if isElement(player) then
		toggleControl( player,"next_weapon", enabled )
		toggleControl( player,"previous_weapon", enabled )
		toggleControl( player,"fire", enabled )
		toggleControl( player,"aim_weapon", enabled )
		setPedWeaponSlot( player, 0 )
	end
end

-- Fake Crowd --

fakeCrowdPos = {{-1944.263, 425.859, -0.413, 359.971},
    {-1939.648, 426.133, -0.4, 11.521},
    {-1953.628, 424.165, 0.892, 315.459 },
    {-1944.763, 415.873, 2.634, 356.921 },
    {-1939.727, 420.403, 1.33, 9.609 },
    {-1928.377, 422.332, 2.634, 47.22 },
    {-1958.374, 423.195, 2.197, 312.967},
    {-1946.206, 420.107, 1.33, 358.091},
    {-1951.04, 421.392, 1.33, 333.621},
    {-1949.267, 417.983, 2.197, 344.95},
    {-1933.876, 424.977, 0.892, 21.88},
    {-1948.702, 428.227, -0.843, 337.246},
    {-1956.913, 417.85, 3.064, 326.371},
    {-1935.002, 417.917, 2.634, 20.748},
}

femaleSkins = {9, 10, 11, 12, 13, 31, 38, 39, 40, 41, 53, 54, 55, 56, 63, 64, 69, 75, 76, 77, 85, 87, 88, 89, 90, 91, 92, 93, 129, 130, 131, 138, 139, 140, 141, 145, 148, 150, 151, 152, 157, 169, 172, 178, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 201, 205, 207, 211, 214, 215, 216, 218, 219, 224, 225, 226, 231, 232, 233, 237, 238, 243, 244, 245, 246, 251, 256, 257, 263, 298, 304
}

local fakeCrowd = {}
local animTimer = {}
local crowdAnims = {"RIOT_CHANT","RIOT_ANGRY"}

function createFakeCrowd(crowdSpawned)
    if crowdSpawned then
        for i, v in ipairs(fakeCrowdPos) do
            local ID = femaleSkins[math.random(#femaleSkins)]
            fakeCrowd[i] = createPed(ID, v[1], v[2], v[3], v[4])
            local t = math.random(50,4000)
            animTimer[i] = setTimer(setPedAnimation,t,1,fakeCrowd[i],"RIOT",crowdAnims[math.random(#crowdAnims)])
            setElementFrozen(fakeCrowd[i],true)
        end
    else
        for i in ipairs(fakeCrowdPos) do
            if fakeCrowd[i] and isElement(fakeCrowd[i]) then
                destroyElement(fakeCrowd[i])
                if isTimer(animTimer[i]) then
                    killTimer(animTimer[i])
                end
            end
        end
    end
end
addEvent("onFakeCrowdSpawn",true)
addEventHandler( "onFakeCrowdSpawn",resourceRoot,createFakeCrowd)


-- Time --

function requestTime()
    local h,m = getTime()
    local w = getWeather()
    local md = getMinuteDuration()
	triggerClientEvent("updateTimeOnExitCinema",source,h,m,w,md)
end
addEvent("requestTime",true)
addEventHandler("requestTime",root,requestTime)

-- Blip --

local cinemaBlip = createBlip(-1953.275,439.171,-1.2, 43)