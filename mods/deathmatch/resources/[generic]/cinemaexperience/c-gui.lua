-- Scripted by G&T Mapping & Loki

-------------------
-- GUI / VISUALS --
-------------------

fontType = dxCreateFont("fonts/primetime.ttf",30,false,"antialiased")
thumb = "img/bg.png"

function Browser_Tab()
	Image(36, 177, 258, 49, thumb, 0, 0, 0, tocolor(255, 255, 255, 60), true)
end

plTabColor = {217, 45, 45, 255}
ulTabColor = {217, 217, 217, 255}
function Panel()
	Rectangle(16, 76, 1247, 870, tocolor(217, 45, 45, 255), false)
	Rectangle(842, 167, 411, 769, tocolor(16, 16, 16, 255), false)
	Rectangle(26, 167, 806, 769, tocolor(16, 16, 16, 255), false)
	Text("YouTube Browser", 36, 177, 293, 225, tocolor(255, 255, 255, 255), 2.00, "default", "center", "center", false, false, false, false, false)
	Text("Settings", 301, 177, 558, 225, tocolor(255, 255, 255, 255), 2.00, "default", "center", "center", false, false, false, false, false)
	Text("Help", 565, 177, 822, 225, tocolor(255, 255, 255, 255), 2.00, "default", "center", "center", false, false, false, false, false)
	Rectangle(36, 260, 786, 413, tocolor(38, 40, 40, 255), false)
	Rectangle(36, 683, 786, 243, tocolor(38, 40, 40, 255), false)
	Text("G&T & Loki's Cinema Experience", 76, 76, 772, 157, tocolor(255, 255, 255, 255), 1.1, fontType, "center", "center", false, false, false, false, false)
	Image(620, 741, 128, 128, "img/add.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
	Text("PLAY", 307, 693, 552, 916, tocolor(255, 255, 255, 255), 3.00, "default", "center", "center", false, true, false, false, false)
	Text("REMOVE", 46, 693, 291, 916, tocolor(255, 255, 255, 255), 3.00, "default", "center", "center", false, true, false, false, false)
	
	Rectangle(852, 260, 87, 38, tocolor(unpack(plTabColor)), false)
    Text("Playlist", 852, 260, 939, 298, tocolor(42, 42, 42, 255), 1.40, "default", "center", "center", false, false, false, false, false)
    Rectangle(949, 260, 87, 38, tocolor(unpack(ulTabColor)), false)
    Text("Visitors", 949, 260, 1036, 298, tocolor(42, 42, 42, 255), 1.40, "default", "center", "center", false, false, false, false, false)
	
    Text("Status:", 873, 86, 872, 157, tocolor(255, 255, 255, 255), 0.5, fontType, "left", "center", false, false, false, false, false)
    if theater then
        Text("OPEN", 968, 86, 872, 157, tocolor(0, 255, 0, 255), 0.5, fontType, "left", "center", false, false, false, false, false)
    else
        Text("CLOSED", 968, 86, 872, 157, tocolor(0, 0, 0, 255), 0.5, fontType, "left", "center", false, false, false, false, false)
    end
	
	Text("Visitors: ", 1077, 86, 872, 157, tocolor(255, 255, 255, 255), 0.5, fontType, "left", "center", false, false, false, false, false)
	Text(#getElementsWithinColShape(cinemaCol,"player"), 1185, 93, 872, 157, tocolor(255, 255, 255, 255), 1.6, "sans", "left", "center", false, false, false, false, false)
	
	Text("Ver. 2.3.5", 1080, 78, 1258, 107, tocolor(234, 234, 234, 255), 1.30, "default", "right", "top", false, false, true, false, false)
end

function Settings_Tab()
    if not settingsTabOpen then return end
	Image(301, 177, 258, 49, thumb, 0, 0, 0, tocolor(255, 255, 255, 60), false)
	
    Text("VIP settings_____________", 46, 270, 293, 308, tocolor(255, 255, 255, 255), 1.50, "default", "left", "center", false, false, false, false, true)
    Text("My settings______________", 46, 509, 293, 547, tocolor(255, 255, 255, 255), 1.50, "default", "left", "center", false, false, false, false, true)
 
    Text("Open/close Theater", 94, 325, 345, 354, tocolor(255, 255, 255, 255), 1.50, "default", "left", "center", false, false, false, false, true)
    if theater then
        Image(40, 325, 50, 29, "img/checked.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    else
        Image(40, 325, 50, 29, "img/unchecked.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    end
 
    Text("Toggle Ambilight", 408, 325, 659, 354, tocolor(255, 255, 255, 255), 1.50, "default", "left", "center", false, false, false, false, true)
    if ambilight then
        Image(354, 325, 50, 29, "img/checked.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    else
        Image(354, 325, 50, 29, "img/unchecked.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    end
 
    Text("Toggle Fake Audience", 94, 371, 659, 400, tocolor(255, 255, 255, 255), 1.50, "default", "left", "center", false, false, false, false, true)
    if audience then
        Image(40, 371, 50, 29, "img/checked.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    else
        Image(40, 371, 50, 29, "img/unchecked.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    end
 
    Text("Toggle Night Time", 408, 371, 659, 400, tocolor(255, 255, 255, 255), 1.50, "default", "left", "center", false, false, false, false, true)
    if time then
        Image(354, 371, 50, 29, "img/checked.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    else
        Image(354, 371, 50, 29, "img/unchecked.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    end

    Text("Toggle Weapons", 94, 417, 345, 446, tocolor(255, 255, 255, 255), 1.50, "default", "left", "center", false, false, false, false, true)
    if weapons then
        Image(40, 417, 50, 29, "img/checked.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    else
        Image(40, 417, 50, 29, "img/unchecked.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    end
    
    -- User Settings
    Text("Change view", 94, 610, 345, 639, tocolor(255, 255, 255, 255), 1.50, "default", "left", "center", false, false, false, false, true)
    if not playerView then
        Image(40, 610, 50, 29, "img/checked.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    else
        Image(40, 610, 50, 29, "img/unchecked.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    end
    
    Text("Toggle Audio", 94, 564, 345, 593, tocolor(255, 255, 255, 255), 1.50, "default", "left", "center", false, false, false, false, true)
    if not screenMuted then
        Image(40, 564, 50, 29, "img/checked.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    else
        Image(40, 564, 50, 29, "img/unchecked.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    end

    Text("Fix Aspect Ratio", 408, 564, 659, 593, tocolor(255, 255, 255, 255), 1.50, "default", "left", "center", false, false, false, false, true)
    if fixAspectRatio then
        Image(354, 564, 50, 29, "img/checked.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    else
        Image(354, 564, 50, 29, "img/unchecked.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    end
   
    Image(672, 316, 137, 46, "img/button.png", 0, 0, 0,         tocolor(255, 255, 255, 255), false)
    Text(LIST, 672, 316, 809, 362,                              tocolor(255, 255, 255, 255), 1.30, "default", "center", "center", false, true, false, false, false)
 
    Image(672, 362, 137, 46, "img/button.png", 0, 0, 0,         tocolor(255, 255, 255, 255), false)
    Text("Kick player from theater", 672, 362, 809, 408,        tocolor(255, 255, 255, 255), 1.30, "default", "center", "center", false, true, false, false, false)
 
    Image(672, 408, 137, 46, "img/button.png", 0, 0, 0,         tocolor(255, 255, 255, 255), false)
    Text("Kick all players from theater", 672, 408, 809, 454,   tocolor(255, 255, 255, 255), 1.30, "default", "center", "center", false, true, false, false, false)
 
    Image(672, 454, 137, 46, "img/button.png", 0, 0, 0, 		tocolor(255, 255, 255, 255), false)
	Text("Kick visitors from theater", 672, 454, 809, 500, 					tocolor(255, 255, 255, 255), 1.30, "default", "center", "center", false, true, false, false, false)

	Image(672, 500, 137, 46, "img/button.png", 0, 0, 0, 		tocolor(255, 255, 255, 255), false)
	Text("Add/Remove VIP", 672, 500, 809, 546, 					tocolor(255, 255, 255, 255), 1.30, "default", "center", "center", false, true, false, false, false)

    Image(672, 546, 137, 46, "img/button.png", 0, 0, 0, 		tocolor(255, 255, 255, 255), false)
	Text("Clear Playlist", 672, 546, 809, 592, 					tocolor(255, 255, 255, 255), 1.30, "default", "center", "center", false, true, false, false, false)
 
end

function Dialog()
	local text = "Are you sure?"
	local yes = "Yes"
	local no = "No"
	Rectangle(463, 355, 339, 214, tocolor(252, 40, 45, 255), true)
	Image(491, 486, 137, 47, "img/button.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	Text(yes, 490 + 1, 486 + 1, 627 + 1, 533 + 1, tocolor(0, 0, 0, 255), 1.50, "default", "center", "center", false, false, true, false, false)
	Text(yes, 490, 486, 627, 533, tocolor(255, 255, 255, 255), 1.50, "default", "center", "center", false, false, true, false, false)
	Image(637, 486, 137, 47, "img/button.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	Text(no, 637 + 1, 486 + 1, 774 + 1, 533 + 1, tocolor(0, 0, 0, 255), 1.50, "default", "center", "center", false, false, true, false, false)
	Text(no, 637, 486, 774, 533, tocolor(255, 255, 255, 255), 1.50, "default", "center", "center", false, false, true, false, false)
	Text(text, 463 + 1, 355 + 1, 802 + 1, 493 + 1, tocolor(0, 0, 0, 255), 2.00, "default", "center", "center", false, true, true, false, false)
	Text(text, 463, 355, 802, 493, tocolor(255, 255, 255, 255), 2.00, "default", "center", "center", false, true, true, false, false)
end

browserSwitch = "USE .TV"
panelBrowserURL = "https://www.youtube.com"
switchedBrowser = true
browserX, browserY = 36, 260
browserWidth, browserHeight = 786, 413

function drawBrowserSwitch()
	if not isPanelVisible then return end
	Rectangle(761, 260, 61, 38, tocolor(34, 34, 34, 210), true)
	Text(browserSwitch, 761, 260, 822, 298, tocolor(255, 255, 255, 255), 0.9, "default-bold", "center", "center", false, true, true, false, false)
end

function createBrowserGui()
	Browser_Bg = guiCreateStaticImage(browserX, browserY, browserWidth, browserHeight, "img/bg.png", false)
	Browser = guiCreateBrowser(0, 0, browserWidth, browserHeight, false, false, false, Browser_Bg)
	addEventHandler("onClientBrowserCreated", Browser, onPanelBrowserCreated)
    
end

function destroyBrowserGui()
    if isElement(Browser) then
		removeEventHandler("onClientBrowserCreated", Browser, onPanelBrowserCreated)
        Browser:destroy()
        Browser_Bg:destroy()
        Browser = nil
        Browser_Bg = nil
	end
end

function onPanelBrowserCreated()
    if isElement(Browser) then
        loadBrowserURL(guiGetBrowser(Browser), panelBrowserURL)
        setBrowserVolume(guiGetBrowser(Browser),0)
    end
end

function Help_Tab()
	Image(565, 177, 258, 49, thumb, 0, 0, 0, tocolor(255, 255, 255, 60), false)
end

sansBig = guiCreateFont( "fonts/sans.ttf", 11 )

HelpInfo = ScrollPane(41, 263, 774, 401, false)

HelpLabel = Label(2, 5, 746, 1100, [[G&T & Loki's Cinema Experience - Version 2.3.5

To report issues or provide feedback, please visit our official release thread:
http://bit.ly/2ajlgPv

Contact Loki on the MTA forums:
http://bit.ly/2aDgNDD

Instructions for Users:

Head to the red dragon marker on your map (San Fierro) and enter the cinema. When inside, find a nice place to stand and press F2. Now browse to your favorite YouTube video and click on 'ADD' to add it to the queue. It will start playing on the big screen immediately. You can browse for more videos and add them as well. Make sure you pause the video in the browser so you don't have two videos playing at the same time.
Select a video from the playlist and click on 'REMOVE' to remove it from the queue or click on 'PLAY' to view the video in the browser.

Instructions for Admins:

Before adding videos to the playlist, you must first grant the resource admin ACL access and you must also add yourself to the VIP/Staff list. To do this, go to the settings tab, then click on the visitors list and select yourself. When selected click on the 'Add/remove VIP' button. That's it. For more help read the instructions on our official MTA thread.

Command List:

Global Binds:

F2 - Opens and closes the browser.
M or /muteit - Mute/unmute the playback.
(+/-) - Adjusts the playback volume.

Global Commands:

/play [url] - Adds a valid YouTube URL to the playlist. Accepts most YouTube URL formats.
/playlist - Displays the playlist in the chatbox.
/geturl - Retrieves the URL of the current video.
/proper - Corrects the aspect ratio of the screen.

VIP/Staff Commands:

/replay - Replays the current video.
/skipvideo - Force skip the current video.
/remove [number] - Removes a video from the playlist.
/stopplay - Stops playback for all users and clears the playlist.]], false, HelpInfo)

guiLabelSetColor(HelpLabel,148,227,150)
guiLabelSetHorizontalAlign(HelpLabel,"left",true)
guiSetFont(HelpLabel,sansBig)

guiSetVisible(HelpInfo,false)
