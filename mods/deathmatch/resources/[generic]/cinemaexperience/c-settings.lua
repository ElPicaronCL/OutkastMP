-- Scripted by G&T Mapping & Loki

screenResX, screenResY = 1920, 1080 -- changing this might break stuff (e.g. auto click through (Default 1920x1080))
fixAspectRatio = false
tempFixAspectRatio = false

-------------------
--   CLICKABLES  --
-------------------

local dxClickables = {
	-- VIP Settings
	{pos = {46, 325, 298, 352}, vip_setting = {"Theater"}},
	{pos = {360, 325, 600, 351}, vip_setting = {"Ambilight"}},
	{pos = {46, 371, 298, 402}, vip_setting = {"Audience"}},
	{pos = {360, 371, 600, 402}, vip_setting = {"Time"}},
	{pos = {46, 417, 298, 444}, vip_setting = {"Weapons"}},
	-- User Settings
	{pos = {46, 564, 298, 593}, user_setting = {"ToggleAudio"}},
	{pos = {46, 610, 298, 639}, user_setting = {"ToggleView"}},
	{pos = {354, 564, 600, 593}, user_setting = {"ToggleFixAspectRatio"}},
	-- VIP Buttons
	{pos = {672, 362, 809, 408}, vip_button = {"KickPlayer"}},
	{pos = {672, 408, 809, 454}, vip_button = {"KickAllPlayers"}},
	{pos = {672, 454, 809, 500}, vip_button = {"KickVisitors"}},
	{pos = {672, 500, 809, 546}, vip_button = {"SetVIP"}},
	{pos = {672, 546, 809, 592}, vip_button = {"ClearPlaylist"}},
	-- Buttons
	{pos = {761, 260, 822, 298}, button = {"SwitchBrowser"}},
	-- Tabs
	{pos = {36, 177, 293, 225}, tab = {"BrowserTab"}},
	{pos = {301, 177, 558, 225}, tab = {"SettingsTab"}},
	{pos = {565, 177, 822, 225}, tab = {"HelpTab"}},
	-- Main
	{pos = {46, 693, 291, 916}, main = {"Remove"}},
	{pos = {1051, 207, 1243, 233}, main = {"SkipSong"}},
	{pos = {307, 693, 552, 916}, main = {"Play"}},
	{pos = {567, 693, 812, 916}, main = {"Add"}},
	
	{pos = {852, 260, 939, 298}, main = {"PlayList"}},
	{pos = {949, 260, 1036, 298}, main = {"UserList"}},
}

function onDxClick(button,state)
	if not isPanelVisible then return end
	if button ~= "right" and state == "down" then return end
	if isDialogVisible then return end

	local cx,cy = getCursorPosition()
	local sx,sy = guiGetScreenSize()

	for i=1,#dxClickables do
		local v = dxClickables[i]
		if isCursorOverArea(v.pos[1],v.pos[2],v.pos[3],v.pos[4]) then
			if settingsTabOpen then
				if v.vip_setting then
					playSFX("genrl", 52, 20, false)
					triggerServerEvent("onSettingChanged",localPlayer,v.vip_setting[1])
				elseif v.user_setting then
					playSFX("genrl", 52, 20, false)
					if v.user_setting[1] == "ToggleAudio" then
						toggleMuted()
					elseif v.user_setting[1] == "ToggleView" then
						togglePlayerView()
					elseif v.user_setting[1] == "ToggleFixAspectRatio" then
						toggleFixAspectRatio()
					end
				elseif v.vip_button then
					if v.vip_button[1] == "KickPlayer" then
						if userlist then
							if userlist:IsVisible() then
								if userlist:GetSelectedItem() then
									local _,name = userlist:GetItemDetails(names,userlist:GetSelectedItem())
									if name then
										local player = getPlayerFromName(name)
										if player then
											triggerServerEvent("onKickPlayerFromTheater",resourceRoot,localPlayer,false,player)
											userlist:SetSelectedItem(0)
										end
									end
								end
							end
						end
					elseif v.vip_button[1] == "KickAllPlayers" then
						triggerServerEvent("onKickPlayerFromTheater",resourceRoot,localPlayer,"everyone")
					elseif v.vip_button[1] == "KickVisitors" then
						triggerServerEvent("onKickPlayerFromTheater",resourceRoot,localPlayer,"visitors")
					elseif v.vip_button[1] == "SetVIP" then
						if userlist then
							if userlist:IsVisible() then
								if userlist:GetSelectedItem() then
									local _,name = userlist:GetItemDetails(names,userlist:GetSelectedItem())
									if name then
									local player = getPlayerFromName(name)
										if player then
											triggerServerEvent("addPlayerToVIP",localPlayer,player)
											refreshUserList()
										end
									end
								end
							end
						end
					elseif v.vip_button[1] == "ClearPlaylist" then
						if playlist:GetItemCount(videos) > 0 then
							if not isEventHandlerAdded("onClientRender",root,Dialog) then
								addEventHandler("onClientRender",root,Dialog)
								addEventHandler("onClientClick",root,showDialog)
								isDialogVisible = true
							end
						end
					end
				end
			end
			if v.main then
				if v.main[1] == "Add" then
					local browser = guiGetBrowser(Browser)
					local url = getBrowserURL(browser)..""
					if url then
						-- double click to pause browser (unreliable)
						if url:find('/tv') then
							clickScreenAt(browser, browserWidth/2, browserHeight/2)
							clickScreenAt(browser, browserWidth/2, browserHeight/2)
						end
						triggerServerEvent("requestPlay",resourceRoot,localPlayer,_,url)
					end
				elseif v.main[1] == "Play" then
					if playlist:GetSelectedItem() then
					local _,url = playlist:GetItemDetails(videos,playlist:GetSelectedItem())
						if url and browserSwitch == 'USE .TV' then
							loadBrowserURL(guiGetBrowser(Browser), 'https://www.youtube.com/watch?v='..parseYouTubeId(url))
						else
							loadBrowserURL(guiGetBrowser(Browser), url..'&autoplay=0')
						end
					end
				elseif v.main[1] == "SkipSong" then
					if isTimer(songProgress) then
						triggerServerEvent("voteToSkip",resourceRoot,localPlayer)
					end
				elseif v.main[1] == "Remove" then
					if playlist:GetSelectedItem() then
					local text = playlist:GetItemDetails(videos,playlist:GetSelectedItem())
						if text then
							local number = gettok(text,1,string.byte('.'))
							if tonumber(number) then
								triggerServerEvent("requestRemove",resourceRoot,localPlayer,tonumber(number))
								playlist:SetSelectedItem(0)
							end
						end
					end
				elseif v.main[1] == "PlayList" then
					showList("PlayList")
				elseif v.main[1] == "UserList" then
					showList("UserList")
				end
			elseif v.tab then
				if v.tab[1] == "BrowserTab" then
					switchToTab("browser")
				elseif v.tab[1] == "SettingsTab" then
					switchToTab("settings")
				elseif v.tab[1] == "HelpTab" then
					switchToTab("help")
				end
			end
			if not settingsTabOpen and not helpTabOpen then
				if v.button then
					if v.button[1] == "SwitchBrowser" then
						switchedBrowser = not switchedBrowser
						if switchedBrowser then
							browserSwitch = "USE .TV"
							panelBrowserURL = "https://www.youtube.com"
							loadBrowserURL(guiGetBrowser(Browser),panelBrowserURL)
						else
							browserSwitch = "USE .COM"
							panelBrowserURL = "https://www.youtube.com/tv"
							loadBrowserURL(guiGetBrowser(Browser),panelBrowserURL)
						end
					end
				end
			end
		end
	end
end
addEventHandler("onClientClick",root,onDxClick)

function switchToTab(tab)
	if tab == "browser" then
		if not browserTab and not browserTabOpen then
			removeEventHandler("onClientRender",root,Help_Tab)
			guiSetVisible(HelpInfo,false)
			removeEventHandler("onClientRender",root,Settings_Tab)
			guiSetVisible(Browser_Bg,true)
			addEventHandler("onClientRender",root,drawBrowserSwitch)
			browserTab = true
			browserTabOpen = true
			settingsTab = false
			settingsTabOpen = false
			helpTab = false
			helpTabOpen = false
		end
	elseif tab == "settings" then
		if not settingsTab and not settingsTabOpen then
			removeEventHandler("onClientRender",root,Help_Tab)
			guiSetVisible(HelpInfo,false)
			addEventHandler("onClientRender",root,Settings_Tab)
			guiSetVisible(Browser_Bg,false)
			removeEventHandler("onClientRender",root,drawBrowserSwitch)
			browserTab = false
			browserTabOpen = false
			settingsTab = true
			settingsTabOpen = true
			helpTab = false
			helpTabOpen = false
		end
	elseif tab == "help" then
		if not helpTab then
			removeEventHandler("onClientRender",root,Settings_Tab)
			addEventHandler("onClientRender",root,Help_Tab)
			guiSetVisible(HelpInfo,true)
			guiSetVisible(Browser_Bg,false)
			removeEventHandler("onClientRender",root,drawBrowserSwitch)
			browserTab = false
			browserTabOpen = false
			settingsTab = false
			settingsTabOpen = false
			helpTab = true
			helpTabOpen = true
		end
	end
end

local dxDialogClickables = {
	{pos = {490, 486, 627, 533}, button = "yes"},
	{pos = {637, 486, 774, 533}, button = "no"},
}

function showDialog(button,state)
	if button == "left" and state == "down" then
		for _,v in pairs(dxDialogClickables) do
			if isCursorOverArea(v.pos[1],v.pos[2],v.pos[3],v.pos[4]) then
				if v.button == "yes" then
					triggerServerEvent("globalStop",resourceRoot,localPlayer)
				end
				removeEventHandler("onClientRender",root,Dialog)
				removeEventHandler("onClientClick",root,showDialog)
				isDialogVisible = false
			end
		end
	end
end

-------------------
--   dxSettings  --
-------------------

addEvent("updatedPlayersInCinema", true)
addEventHandler( "updatedPlayersInCinema", root, function (playerTable)
	playersInCinema = playerTable
end)


triggerServerEvent( "updateCheckedSettings",resourceRoot )
addEvent( "updatedSettings",true)
addEventHandler( "updatedSettings",root,
    function (settingsTable)
        for _,setting in ipairs (settingsTable) do
			if setting[1] == "theater" then
				theater = setting[2]
			elseif setting[1] == "playback" then
				playback = setting[2]
			elseif setting[1] == "audio" then
				audio = setting[2]
			elseif setting[1] == "queue" then
				queue = setting[2]
			elseif setting[1] == "ambilight" then
				ambilight = setting[2]
			elseif setting[1] == "audience" then
				audience = setting[2]
			elseif setting[1] == "time" then
				time = setting[2]
				toggleNight()
			elseif setting[1] == "weapons" then
				weapons = setting[2]
			end
        end
    end
)

function onCinemaEnter()
	toggleNight()
end

function toggleNight()
	if isElementWithinColShape(localPlayer,cinemaCol) then
		if time then
			setTime(0,0)
			setWeather(12)
			setMinuteDuration(99999999)
		end
	end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
	checkFixAspectRatioSetting()
end)

function toggleFixAspectRatio(skipFile)
    fixAspectRatio = not fixAspectRatio
    if Screen then
        local sy = fixAspectRatio and screenResY-100 or screenResY
	    resizeBrowser(Screen, screenResX, sy)
    end
	if not skipFile then
		local f = File('fixAspectRatio_setting.txt')
		if f then
			f:write(fixAspectRatio and '1' or '0')
			f:close()
		end
	end
end
addCommandHandler('proper', toggleFixAspectRatio)

function checkFixAspectRatioSetting()
	if fileExists('fixAspectRatio_setting.txt') then
		local f = fileOpen('fixAspectRatio_setting.txt', true)
		if f then
			local c = f:read(f.size)
			f:close()
			if c == '1' then
				toggleFixAspectRatio(true)
			end
		end
	end
end

function onLeaveCinema(hitElement)
	if hitElement == localPlayer then
    	triggerServerEvent("requestTime",hitElement)
    end
	if not playerView then
		restorePlayerView()
		setCameraTarget(localPlayer, localPlayer)
	end
	destroyAmbilights()
end

function requestTime(h,m,w,md,onStart)
    setTime(h,m)
	setWeather(w)
	setMinuteDuration(md)
	
	if onStart then
		setTimer(function()
			showChat(true)
			showPlayerHudComponent("all",true)
		end,500,1)
	end
end
addEvent("updateTimeOnExitCinema",true)
addEventHandler("updateTimeOnExitCinema",resourceRoot,requestTime)

function setNightTime()
	setTimer(toggleNight,1500,1)
end
addEvent("updateTimeOnEnterCinema",true)
addEventHandler("updateTimeOnEnterCinema",root,setNightTime)

-------------------
--   Ambilight   --
-------------------

local ambiPositions = {
	{-1965.3,449.39999,-1.3},
	{-1965.3,449.39999,5.7},
	{-1965.3,449.39999,12.6},
	{-1922.5,449.39999,12.6},
	{-1922.5,449.39999,5.7},
	{-1922.5,449.39999,-1.3},
	{-1944.0996, 414.0996, 9, 0.75}
}
ambiMarkers = {}
local ambiLight = false

function createAmbilights()
    if not ambiLight then
        projectorLight = createLight(0, -1943.669, 451.898, 5.771, 50, 255, 33, 33)
        engineApplyShaderToWorldTexture(frameShader,"frame")
        dxSetShaderValue(frameShader, "gFrameColor", 15/255, 15/255, 15/255)
        for i=1,#ambiPositions do
            local v = ambiPositions[i]
            ambiMarkers[i] = createMarker(v[1], v[2], v[3], "corona", v[4] or 4, 255, 33, 33, 90)
        end
		ambiLight = true
    end
end

function destroyAmbilights()
	if ambiLight then
		if isElement(projectorLight) then
			destroyElement(projectorLight)
			engineRemoveShaderFromWorldTexture(frameShader,"frame")
		end
		for i=1,#ambiPositions do
			if ambiMarkers[i] and isElement(ambiMarkers[i]) then
				destroyElement(ambiMarkers[i])
			end
		end
		ambiLight = false
	end
end

function toggleAmbilights(toggle)
    if toggle then
        createAmbilights()
    else
        destroyAmbilights()
    end
end
addEvent("onToggleAmbilights", true)
addEventHandler("onToggleAmbilights", resourceRoot, toggleAmbilights)


local targetR, targetG, targetB = 0, 0, 0
local currentR, currentG, currentB = 0, 0, 0
local transitionDuration = 650 -- ms
local transitionStartTime = 0

local pixelsFormat = "plain"
local textureFormat = "dxt5"
local useMipmaps = false

function screenGlare()
    if isElement(Screen) and isElement(projectorLight) then
        local currentTime = getTickCount()

        -- get the center pixel color
        local centerPcol = dxGetTexturePixels(0, Screen, pixelsFormat, textureFormat, useMipmaps, (screenResX / 2), (screenResY / 2), 4, 4)
        local centerR, centerG, centerB = dxGetPixelColor(centerPcol, 3, 3)

        -- get the surrounding pixel colors
        local leftPcol = dxGetTexturePixels(0, Screen, pixelsFormat, textureFormat, useMipmaps, (screenResX / 4), (screenResY / 2), 4, 4)
        local rightPcol = dxGetTexturePixels(0, Screen, pixelsFormat, textureFormat, useMipmaps, (screenResX * 3 / 4), (screenResY / 2), 4, 4)
        local topPcol = dxGetTexturePixels(0, Screen, pixelsFormat, textureFormat, useMipmaps, (screenResX / 2), (screenResY / 4), 4, 4)
        local bottomPcol = dxGetTexturePixels(0, Screen, pixelsFormat, textureFormat, useMipmaps, (screenResX / 2), (screenResY * 3 / 4), 4, 4)

        local leftR, leftG, leftB = dxGetPixelColor(leftPcol, 3, 3)
        local rightR, rightG, rightB = dxGetPixelColor(rightPcol, 3, 3)
        local topR, topG, topB = dxGetPixelColor(topPcol, 3, 3)
        local bottomR, bottomG, bottomB = dxGetPixelColor(bottomPcol, 3, 3)

        -- calculate the average color
        local r = (centerR + leftR + rightR + topR + bottomR) / 5
        local g = (centerG + leftG + rightG + topG + bottomG) / 5
        local b = (centerB + leftB + rightB + topB + bottomB) / 5

        -- check if the target color has changed
        if r ~= targetR or g ~= targetG or b ~= targetB then
            targetR, targetG, targetB = r, g, b
            transitionStartTime = currentTime
        end

        -- calculate the interpolated color based on the transition duration
        local transitionProgress = (currentTime - transitionStartTime) / transitionDuration
        transitionProgress = math.min(transitionProgress, 1)

        currentR = lerp(currentR, targetR, transitionProgress)
        currentG = lerp(currentG, targetG, transitionProgress)
        currentB = lerp(currentB, targetB, transitionProgress)

        setLightColor(projectorLight, currentR, currentG, currentB)
        dxSetShaderValue(frameShader, "gFrameColor", currentR / 255, currentG / 255, currentB / 255)

        for i = 1, #ambiMarkers do
            setMarkerColor(ambiMarkers[i], currentR, currentG, currentB, 255)
        end
    end
end
addEventHandler("onClientRender", root, screenGlare)

function lerp(a, b, t)
    return a * (1 - t) + b * t
end

addEventHandler("onClientColShapeHit",cinemaCol,onCinemaEnter)
addEventHandler("onClientColShapeLeave",cinemaCol,onLeaveCinema)
addEventHandler("onClientResourceStop",resourceRoot,onLeaveCinema)