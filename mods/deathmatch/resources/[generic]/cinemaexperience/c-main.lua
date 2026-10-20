-- Scripted by G&T Mapping & Loki

-------------------
-- GUI FUNCTIONS --
-------------------

local screenVolume = 1
screenMuted = false
playerView = true

isPanelVisible = false
browserTab = true
theList = "PlayList"
local toggleClickScreen = false

local chatVisible
local hudVisible

function togglePanel()
    isPanelVisible = not isPanelVisible
    if isPanelVisible then
        if activeList then
            showList(activeList)
        else
            showList(theList)
        end
    
        if not isCursorShowing() then
            if cursorX and cursorY then
                setCursorPosition(cursorX*RES[1],cursorY*RES[2])
            end
        end
        if not isElement(Browser_Bg) then
            createBrowserGui()
        end

        local browser = guiGetBrowser(Browser)
        if browser then
            setBrowserVolume(browser, 1)
        end

        if playerView then
            chatVisible = isChatVisible()
            hudVisible = {}
            for _, component in ipairs({"ammo", "area_name", "armour", "breath", "clock", "health", "money", "radar", "vehicle_name", "weapon","radio", "wanted", "crosshair"}) do
                hudVisible[component] = isPlayerHudComponentVisible(component)
            end
        end

        showPlayerHudComponent("all",false)
        showChat(false)
        showCursor(true)
        LIST = "Visitors"
        addEventHandler("onClientRender",root,Panel)

        if browserTab then
            guiSetVisible(Browser_Bg,true)
            if not browserTabOpen then
                addEventHandler("onClientRender", root, drawBrowserSwitch)
            end
            browserTabOpen = true
        elseif settingsTab then
            addEventHandler("onClientRender",root,Settings_Tab)
            settingsTabOpen = true
        elseif helpTab then
            guiSetVisible(HelpInfo,true)
            addEventHandler("onClientRender",root,Help_Tab)
            helpTabOpen = true
        end

    else
        local browser = guiGetBrowser(Browser)
        if browser then
            setBrowserVolume(guiGetBrowser(Browser), 0)
        end

        cursorX,cursorY = getCursorPosition()

        if playerView then
            restorePlayerView()
        end

        showCursor(false)
        if playlist then
            playlist:SetVisible(false)
        end
        if userlist then
            userlist:SetVisible(false)
        end
        removeEventHandler("onClientRender",root,Panel)

        if guiGetVisible(Browser_Bg) then
            guiSetVisible(Browser_Bg,false)
        end
        if browserTab and browserTabOpen then
            browserTabOpen = false
        end
        removeEventHandler("onClientRender",root,drawBrowserSwitch)

        if settingsTab and settingsTabOpen then
            removeEventHandler("onClientRender",root,Settings_Tab)
            showCursor(false)
            settingsTabOpen = false
        end

        if helpTab and helpTabOpen then
            removeEventHandler("onClientRender",root,Help_Tab)
            guiSetVisible(HelpInfo,false)
            showCursor(false)
            helpTabOpen = false
        end
        
    end
end
addEvent("togglePanel",true)
addEventHandler("togglePanel",resourceRoot,togglePanel)

function closePanelOnLeave(hitElement)
    if hitElement == localPlayer then
        cleanUp()
        
        activeList = "PlayList"
        
        switchToTab("browser")
        
        if isPanelVisible then
            togglePanel()
        end

        destroyBrowserGui()
    end
end
addEventHandler("onClientColShapeLeave",cinemaCol,closePanelOnLeave)

-------------------
--  DX PLAYLIST  --
-------------------

function createPlaylist()
    playlist = dxGrid:Create(852, 298, 391, 628)
    videos = playlist:AddColumn("Playlist",391)
end

function createUserlist()
    userlist = dxGrid:Create(852, 298, 391, 628)
    names = userlist:AddColumn("Visitors",391)
end

function showPlaylist()
    if not isTimer(showDelay) then
        triggerServerEvent("showPlaylist",resourceRoot,localPlayer)
        showDelay = setTimer(function()end,7000,1)
    else
        outputChatBox("Please wait a few seconds before using this command again",245,180,140,true)
    end
end
addCommandHandler("playlist",showPlaylist)

function syncPlaylist(list)
    if playlist then
        playlist:Clear()
        for i,v in pairs(list) do			
            if i == 2 then
                playlist:AddItem(videos,"Next Up:","",148,227,150)
            end
            if i == 1 then
                playlist:AddItem(videos,"Now Playing:","",148,227,150)
                playlist:AddItem(videos,i..". "..v[1].title,v[1].url,211,211,211)
            else
                playlist:AddItem(videos,i..". "..v[1].title,v[1].url,211,211,211)
            end
        end
    end
end
addEvent("syncRequest",true)
addEventHandler("syncRequest",resourceRoot,syncPlaylist)

-------------------
-- COLSHAPE STUF --
-------------------

function showList(theList)
    if not userlist then
        createUserlist()
    end
    if not playlist then
        createPlaylist()
        setTimer(function()triggerServerEvent("syncRequestFromClient",resourceRoot,localPlayer)end,500,1)
    end
    if theList == "UserList" then
        if userlist then
            userlist:SetVisible(true)
            userlist:Clear()
            triggerServerEvent("onGetPlayersInCol",resourceRoot)
            plTabColor = {217, 217, 217, 255}
            ulTabColor = {217, 45, 45, 255}
            activeList = "UserList"
            if playlist:IsVisible() then
                playlist:SetVisible(false)
                playlist:SetSelectedItem(0)
            end
        end
    elseif theList == "PlayList" then
        if playlist then
            playlist:SetVisible(true)
            plTabColor = {217, 45, 45, 255}
            ulTabColor = {217, 217, 217, 255}
            activeList = "PlayList"
            if userlist:IsVisible() then
                userlist:SetVisible(false)
            end
        end
    end
end
                
function refreshUserList()
    if userlist then
        triggerServerEvent("onGetPlayersInCol",resourceRoot)
    end
end
addEvent("syncUserList",true)
addEventHandler("syncUserList",resourceRoot,refreshUserList)

function addPlayersToUserlist(playersTable)
    if userlist then
        playersInCinema = playersTable
        userlist:Clear()
        for i,plr in ipairs(playersTable)do
            if plr.vip == true then
                userlist:AddItem(names,i..". [STAFF] "..plr.name,plr.name,217,45,45)
            else
                userlist:AddItem(names,i..". "..plr.name,plr.name,255,255,255)
            end
        end
    end
end
addEvent("onAddToUserlist",true)
addEventHandler("onAddToUserlist",resourceRoot,addPlayersToUserlist)

-------------------
-- FUNCTIONALITY --
-------------------

-- Render votes
function syncVotes(voteCount,maxVotes)
    if voteCount then
        if isEventHandlerAdded("onClientRender",root,displayVotes) then
            removeEventHandler("onClientRender",root,displayVotes)
        end
        function displayVotes()
            if isPanelVisible then
                Text("Vote to skip ("..voteCount.."/"..maxVotes..')', 1051, 207, 1192, 233, tocolor(255, 255, 255, 255), 1.10, "default", "center", "center", true, false, true, false, false)
            end
        end
    end
end
addEvent("syncVotes",true)
addEventHandler("syncVotes",resourceRoot,syncVotes)

-- new screen
local screenShader = dxCreateShader("screen/screen.fx")
frameShader = dxCreateShader("screen/screen_frame.fx")
local renderTargetTexture = dxCreateRenderTarget(screenResX, screenResY, true)

-- Screen Click through positions
local buttons = {
    guest0 = {
        clickPos = {0.688, 0.41},
        matchPattern = {
            {pos = {0.669, 0.41}, col = tocolor(243, 243, 243, 255)},
            {pos = {0.688, 0.41}, col = tocolor(33, 33, 33, 255)},
            {pos = {0.708, 0.41}, col = tocolor(243, 243, 243, 255)},
        }
    },
    guest1 = {
        clickPos = {0.688, 0.41},
        matchPattern = {
            {pos = {0.669, 0.41}, col = tocolor(242, 242, 242, 255)},
            {pos = {0.688, 0.41}, col = tocolor(15, 15, 15, 255)},
            {pos = {0.708, 0.41}, col = tocolor(242, 242, 242, 255)},
        }
    },
    guest2 = {
        clickPos = {0.5, 0.41},
        matchPattern = {
            {pos = {0.480, 0.41}, col = tocolor(15, 15, 15, 255)},
            {pos = {0.5, 0.41}, col = tocolor(243, 243, 243, 255)},
            {pos = {0.520, 0.41}, col = tocolor(15, 15, 15, 255)},
        }
    },
    guest3 = {
        clickPos = {0.5, 0.41},
        matchPattern = {
            {pos = {0.480, 0.41}, col = tocolor(15, 15, 15, 255)},
            {pos = {0.5, 0.41}, col = tocolor(241, 241, 241, 255)},
            {pos = {0.520, 0.41}, col = tocolor(15, 15, 15, 255)},
            
        }
    },
    guest4 = {
        clickPos = {0.5, 0.41},
        matchPattern = {
            {pos = {0.480, 0.41}, col = tocolor(33, 33, 33, 255)},
            {pos = {0.5, 0.41}, col = tocolor(242, 242, 242, 255)},
            {pos = {0.520, 0.41}, col = tocolor(33, 33, 33, 255)},
            
        }
    },
    guest5 = {
        clickPos = {0.5, 0.41},
        matchPattern = {
            {pos = {0.476, 0.430}, col = tocolor(15, 15, 15, 255)},
            {pos = {0.494, 0.428}, col = tocolor(241, 241, 241, 255)},
            {pos = {0.513, 0.436}, col = tocolor(15, 15, 15, 255)},
            
        }
    },
    guest6 = {
        clickPos = {0.510, 0.859},
        matchPattern = {
            {pos = {0.4760, 0.148}, col = tocolor(255, 0, 51, 255)},
            {pos = {0.510, 0.859}, col = tocolor(55, 55, 55, 255)},
        }
    },
    skipAd = {
        clickPos = {0.88, 0.90},
        matchPattern = {
            {pos = {0.83, 0.90}, col = tocolor(241, 241, 241, 255)},
            {pos = {0.88, 0.90}, col = tocolor(15, 15, 15, 255)},
            {pos = {0.93, 0.90}, col = tocolor(0, 0, 0, 255)},
        }
    }
}

local function getColorAt(x, y)
    local pix = dxGetTexturePixels(Screen, 'plain', 'argb', false, x*screenResX, y*screenResY, 1, 1)
    local r, g, b, a = dxGetPixelColor(pix, 0, 0)
    return tocolor(r, g, b, a), {r,g,b,a}
end
  
function clickScreenAt(browser, x, y)
    if browser then
        browser:injectMouseMove(x * screenResX, y * screenResY)
        browser:injectMouseUp('left')
    end
end

if getDevelopmentMode() then
    localPlayer.position = localPlayer.matrix:transformPosition(0,0,0.05) -- ensure player triggers cinema colshape on /restart res to save effort
end

local function checkYoutubeTVButtons()
    for _, butt in pairs(buttons) do
        local visible = true
        for _, patt in ipairs(butt.matchPattern) do
            local col, rgb = getColorAt(patt.pos[1],patt.pos[2])
            if col ~= patt.col then
                visible = false
                break
            end
        end
        if visible then
            clickScreenAt(Screen, butt.clickPos[1], butt.clickPos[2])
            if tempFixAspectRatio then
                toggleFixAspectRatio()
                tempFixAspectRatio = false
            end
        end
    end
end

local nick, title, msgStart, fadeStart, fadeAlpha = '', '', nil, nil, 255
local msgDur, fadeDur = 7500, 2500 -- ms
  
local function drawScreen()
    dxSetRenderTarget(renderTargetTexture, true)
    dxSetBlendMode("overwrite")
    dxDrawRectangle(0, 0, screenResX, screenResY, tocolor(0, 255, 0, 255))
    dxDrawImage(0, 0, screenResX, screenResY, Screen)
    dxSetBlendMode("blend")
    
    local time = getTickCount()
    if time - msgStart < msgDur + fadeDur then
        if not fadeStart then
            fadeStart = time + msgDur
        end
        local alpha = time > fadeStart and math.max(0, 255 - (time - fadeStart) / fadeDur * 255) or 255

        dxDrawText('Cinema Experience | '..title, screenResX * 0.02 + 2, screenResY * 0.02 + 2, 0, 0, tocolor(0, 0, 0, alpha), 3.5, "default-bold")
        dxDrawText('Cinema Experience | #ffffff'..title, screenResX * 0.02, screenResY * 0.02, 0, 0, tocolor(255, 55, 55, alpha), 3.5, "default-bold", "left", "top", false, false, false, true)
        dxDrawText('Requested by: ' .. nick, screenResX * 0.02 + 2, screenResY * 0.08 + 2, 0, 0, tocolor(0, 0, 0, alpha), 2.75, "default-bold")
        dxDrawText('#ffbbbbRequested by: ' .. nick, screenResX * 0.02, screenResY * 0.08, 0, 0, tocolor(255, 255, 255, alpha), 2.75, "default-bold", "left", "top", false, false, false, true)
    end

    -- Debug (displays local screen cursor and shows screen click through button positions)
    if getDevelopmentMode() then
        dxDrawText("**DEBUG MODE** #00ff00(disable with setDevelopmentMode(false))", 10, 5, 390, 25, tocolor(255, 156, 0), 2, "default-bold", "left", "top", false, false, false, true)
        dxDrawText("TOGGLE CURSOR (K): " .. (isCursorShowing() and "#00FF00ON" or "#FF0000OFF") ..' #00ff00(Log screen click pos and pixel color)', 10, 35, 390, 125, tocolor(255, 165, 0), 2, "default-bold", "left", "top", false, false, false, true)
        dxDrawText("TOGGLE INPUT (J): " .. (toggleClickScreen and "#00FF00ON" or "#FF0000OFF") ..' #00ff00(Allow screen browser click input)', 10, 65, 390, 155, tocolor(255, 165, 0), 2, "default-bold", "left", "top", false, false, false, true)

        local cursorX, cursorY = getCursorPosition()
        if cursorX then
            cursorX, cursorY = cursorX * screenResX, cursorY * screenResY
            dxDrawRectangle(cursorX, cursorY, 5, 5, tocolor(255, 0, 0, 255))
        end

        for name, button in pairs(buttons) do
            for _, patt in ipairs(button.matchPattern) do
                dxDrawRectangle(patt.pos[1] * screenResX - 5, patt.pos[2] * screenResY - 5, 10, 10, tocolor(255, 0, 0, 255)) -- red square
            end

            local x = button.clickPos[1] * screenResX
            local y = button.clickPos[2] * screenResY
            dxDrawRectangle(x - 5, y - 5, 10, 10, tocolor(0, 255, 0, 255)) 

            local textX, textY = x + 5, y + 5
            dxDrawText(name, textX + 1, textY + 1, textX + 1, textY + 1, tocolor(0, 0, 0, 255), 2, "default", "left", "top")
            dxDrawText(name, textX, textY, textX, textY, tocolor(255, 255, 255, 255), 2, "default", "left", "top")
        end
    end

    dxSetRenderTarget()
    dxSetShaderValue(screenShader, "gTexture", renderTargetTexture)

    if getTickCount() % 200 < 20 then -- check every 200ms
        checkYoutubeTVButtons()
    end
end
  
local function showMsg(n, m)
    nick = n
    title = m
    msgStart = getTickCount()
    fadeStart = nil
    fadeAlpha = 255
end

function playVideo(url, title, length, nick, atTime)
    if isElementWithinColShape(localPlayer,cinemaCol) then
        engineApplyShaderToWorldTexture(screenShader,"screen")

        showMsg(nick, title)

        if fixAspectRatio then
            tempFixAspectRatio = true
            toggleFixAspectRatio()
        end

        local videoURL = useEmbeds and tostring(url).."?autoplay=1&controls=0&start="..atTime.."&t="..atTime or tostring(url).."&t="..atTime
        if Screen then
            removeEventHandler("onClientRender",root,displayTitle)
            loadBrowserURL(Screen,videoURL)
            destroyElement(Screen)
        end

        local sy = fixAspectRatio and screenResY-100 or screenResY
        Screen = createBrowser(screenResX, sy, false, false)
        addEventHandler("onClientBrowserCreated",Screen,function()
            loadBrowserURL(Screen,videoURL)
            addEventHandler("onClientBrowserLoadingFailed",Screen,function(url,err,errorDescription)
                if err == 3 then
                    triggerEvent("onDxPopupMessage",resourceRoot,"SCREEN ERROR - ERR_ABORTED: '"..url.."'",5000)
                    outputDebugString("SCREEN ERROR - ERR_ABORTED: '"..url.."'")
                end
            end)
        end)
        
        if title and tonumber(length) then
            local msecs = length*1000
            local total = msecs/1000
            local secs = msecs/1000
            local increment = 391/secs
            local width = increment*atTime
            length = string.format("%.2d:%.2d:%.2d",secs/(60*60),secs/60%60,secs%60)
            
            if isTimer(progressBar) and isTimer(songProgress) then
                killTimer(progressBar)
                killTimer(songProgress)
            end
            
            progressBar = setTimer(function()
                width = width+increment
            end,1000,secs)
            
            songProgress = setTimer(function()
                if isTimer(progressBar) then
                    killTimer(progressBar)
                end
            end,msecs,1)
                    
            function displayTitle()
                if not screenMuted then
                    setBrowserVolume(Screen,screenVolume)
                else
                    setBrowserVolume(Screen,0)
                end
                
                -- new screen
                if Screen then
                    drawScreen()
                end
                
                if isTimer(songProgress) then
                    ms = getTimerDetails(songProgress)
                    secs = (ms/1000)-atTime
                    secs = total-secs
                    remaining = string.format("%.2d:%.2d:%.2d",secs/(60*60),secs/60%60,secs%60)
                end
                
                if isPanelVisible then
                    Text("Now Playing: "..title.."\nLength: "..remaining.." / "..length.."\nAdded by: "..nick, 852, 170, 1243, 249, tocolor(255, 255, 255, 255), 1.15, "default", "left", "top", true, false, true, false, false)
                    
                    Rectangle(852, 239, 391, 10, tocolor(217, 217, 217, 255), true)
                    Rectangle(852, 239, width, 10, tocolor(217, 45, 45, 255), true)
                    Rectangle(852+width, 239, 4, 10, tocolor(156, 156, 156, 255), true)
                    
                    Image(1051, 207, 141, 26, "img/button.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
                    Image(1197, 207, 46, 26, "img/button.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
                    if not isEventHandlerAdded("onClientRender",root,displayVotes) then
                        addEventHandler("onClientRender",root,displayVotes)
                    end
                    Text("Skip", 1197, 207, 1243, 233, tocolor(255, 255, 255, 255), 1.10, "default", "center", "center", true, false, true, false, false)
                    
                end
            end
            addEventHandler("onClientRender",root,displayTitle)
        end
    end
end
addEvent("playRequest",true)
addEventHandler("playRequest",resourceRoot,playVideo)

function cleanUp()
    if Screen then
        if isTimer(songProgress) or isTimer(progressBar) then
            killTimer(songProgress)
            killTimer(progressBar)
        end
        playlist:Clear()
        removeEventHandler("onClientRender",root,displayTitle)
        
        if isEventHandlerAdded("onClientRender",root,displayVotes) then
            removeEventHandler("onClientRender",root,displayVotes)
        end
        
        -- reset shaders / markers color
        dxSetShaderValue(frameShader, "gFrameColor", 15/255, 15/255, 15/255)
        engineRemoveShaderFromWorldTexture(screenShader,"screen")
        
        for i=1,#ambiMarkers do
            if isElement(ambiMarkers[i]) then
                setMarkerColor(ambiMarkers[i], 255, 33, 33, 90)
                if projectorLight then
                    setLightColor(projectorLight, 255, 33, 33)
                end
            end
        end

        destroyElement(Screen)
        Screen = nil
    end
end
addEvent("stopRequest",true)
addEventHandler( "stopRequest",resourceRoot,cleanUp)


-- Control browser volume with +/- keys and 'm' for muting
function toggleMuted()
    screenMuted = not screenMuted
    
    if screenMuted then
        if Screen then
            setBrowserVolume(Screen,0)
        end
        triggerEvent("onDxPopupMessage",resourceRoot,"Playback muted",2000)
    else
        if Screen then
            setBrowserVolume(Screen,screenVolume)
        end
        triggerEvent("onDxPopupMessage",resourceRoot,"Playback unmuted",2000)
    end
end
addCommandHandler("muteit",toggleMuted)


function togglePlayerView()
    playerView = not playerView
    if playerView then
        restorePlayerView()
        setCameraTarget(localPlayer, localPlayer)
    else
        setCameraMatrix(-1943.8605957031, 429.76181030273, 6.4516000747681, -1943.8602294922, 430.76181030273, 6.4519276618958, 0, 90)
        setPlayerHudComponentVisible("all", false)
        setPlayerHudComponentVisible("radar", false)
        showChat(false)
    end
end

function restorePlayerView()
    showChat(chatVisible)
    for component, visible in pairs(hudVisible) do
        setPlayerHudComponentVisible(component, visible)
    end
    playerView = true
end

function changeScreenVolume(state)    
    if state == "up" then
        screenVolume = math.round(screenVolume + 0.05,2)
    elseif state == "down" then
        screenVolume = math.round(screenVolume - 0.05,2)
    end

    screenMuted = screenVolume <= 0
    
    setBrowserVolume(Screen,screenVolume)
    triggerEvent("onDxPopupMessage",resourceRoot,"Playback Volume: "..math.round(screenVolume*100),2000)
end

addEventHandler("onClientKey",root,function(key,down)
    if not isChatBoxInputActive() then
        if isElementWithinColShape(localPlayer,cinemaCol) and Screen and not down then
            if key == "m" then
                toggleMuted()
            elseif key == "+" or key == "=" or key == "num_add" then
                if screenVolume < 1 then
                    changeScreenVolume("up")
                end
                return
            elseif key == "-" or key == "num_sub" then
                if screenVolume > 0 then
                    changeScreenVolume("down")
                end
            end

            if getDevelopmentMode() and not isPanelVisible then
                if key == 'mouse1' then
                    local cursorX, cursorY = getCursorPosition()
                    if cursorX and Screen then
                        local _, rgba = getColorAt(cursorX, cursorY)
                        local r, g, b = unpack(rgba)
                        outputChatBox('Click Pos: (' .. cursorX .. ', ' .. cursorY .. ') RGB Color: (' .. r .. ', ' .. g .. ', ' .. b .. ')', 0, 255, 255)
                        if toggleClickScreen then
                            clickScreenAt(Screen, cursorX, cursorY)
                        end
                    end
                elseif key == 'j' then
                    toggleClickScreen = not toggleClickScreen
                elseif key == 'k' then
                    showCursor(not isCursorShowing())
                end
            end
        end
    end
end)