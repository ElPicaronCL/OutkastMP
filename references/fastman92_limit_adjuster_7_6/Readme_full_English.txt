***** fastman92 limit adjuster 7.6

Like many other games, GTA has limits that may later need to be increased as the modding community grows.
This limit adjuster gives you that opportunity.

Furthermore, it hacks some limits that were once deemed impossible to be hacked because of their complexity, as the ID limits itself took over 5000 lines of code to hack.
An example of these limits would be the ID limits, weapon limits, handling.cfg limits & cargrp.dat limit.
Map limits are also hacked. This means bigger maps with more cities.

Supported games: GTA III, GTA VC, GTA SA, GTA LCS, GTA IV, GTA V, Bully Scholarship Edition.

- - - - - - - - - - - - - - - - - -

See the project topic: http://gtaforums.com/topic/733982-fastman92-limit-adjuster/

***** Installation

Make sure you are using one of supported game versions.
You can find the information on supported versions in documentation\SupportedVersions.txt
You can find the extensive information on supported features per each game version in documentation\documentation.xmls, which is Excel file.

Documentation.docx contains an instruction, how to apply this project to games on Android.

-----
----------
-----
If you chose a platform WIN_X86:
	- GTA III, VC or Bully Scholarship Edition will require ASI loader that works before game gets started.
	  This one will be appropriate one: https://github.com/ThirteenAG/Ultimate_ASI_Loader/releases
	- GTA San Andreas requires ASI loader, Silent's ASI loader will be good:
	  http://www.gtagarage.com/mods/show.php?id=21709
	- GTA IV requires Xliveless, which has included ASI loader.

	- Copy all files from files\files\libraries\WIN_X86 to game directory.
	- Copy files from files\files\additional_files\%your_game%, depending on specific game, into root directory.
	- Do not change the name of $fastman92limitAdjuster.asi
	- Run the game, you should see the message box that the INI file does not exist and needs to be generated.
	- Now you can open the .ini file for specified game to change some options.
	- Look for fastman92limitaAdjuster.log, it should have been been created.
	
If you chose a platform WIN_X64:
	- GTA V will require ASI loader, you can use the one from OpenIV, made by Alexander Blade
	
	- Copy all files from files\files\libraries\WIN_X64 to game directory.
	- Copy files from files\files\additional_files\%your_game%, depending on specific game, into root directory.
	
	- Run the game, you should see the message box that the INI file does not exist and needs to be generated.
	- Now you can open the .ini file for specified game to change some options.
	- Look for fastman92limitaAdjuster.log, it should have been been created.
	
If you chose a platform ANDROID_*
	- Open Documentation.docx file, see the chapter "Use the FLA for games on Android".
		Follow the instructions carefully.
	- Recommended to use: fastman92 APK modifier, https://gtaforums.com/topic/979211-fastman92-apk-modifier/
	- Copy files from files\files\additional_files\%your_game%, depending on specific game, into root directory.
	- Path to root directory can be found in "AndroidPluginDeploymentSolution", property "external file directory for current game."
	
	- Run the game, INI file will be generated if it does not exist.
	- Now you can open the .ini file for specified game to change some options.
	- Look for fastman92limitaAdjuster.log, it should have been been created.
  
-----
----------
-----
It's recommended to see the documentation of this project - available in Documentation.docx file, which can be opened by Microsoft Word.
If you want to see what features are implemented for which game executables, you can take a look into Documentation.xlsm, which can be opened by Microsoft Excel.
-----

***** Changes
** 7.6
	- Android plugin deployment solution, more commands
	- Android plugin deployment solution, temporary files being removed now

** 7.5, 5 June 2024
	- WIN_X86, GTA SA 1.0 HOODLUM, (ADDONS -> Enable model special feature loader), for vehicle model that derives from 'hunter', door angle fixed
	- ANDROID_ARMEABI_V7A, GTA SA 2.00, (STREAMING -> Minimum number of iterations in LoadAllRequestedModels) implemented
	- ANDROID_ARMEABI_V7A, GTA SA 2.00, (STREAMING -> Number of requested models above which the game considers loading very busy) implemented
	- ANDROID_ARMEABI_V7A, GTA SA 2.00, ID limits, bug fixed. Nines and AK's can now be passed.
	- ANDROID_ARMEABI_V7A, GTA SA 2.00, ID limits, bug with IPL not being loaded fixed. This caused reflection bug.

** 7.4, 26 May 2024
	- ANDROID_ARMEABI_V7A, GTA SA 2.00, ID limits, bug with collision not being loaded fixed. This caused reflection bug.
	- ANDROID_ARMEABI_V7A, GTA SA 2.00, (MAP LIMITS -> World sector size), bug with stealable objects fixed. Now they can be picked up.
	- GTA SA, (MAP LIMITS -> Paths map size) bug fixed, when going to interiors

** 7.3, 2 May 2024
	- ANDROID_ARM64_V8A, GTA SA DE Rockstar 1.86.44544238 added
	- ANDROID_ARM64_V8A, GTA SA DE Rockstar 1.72.42919648 added
	- Android plugin deployment solution, fixed generation of APK/APKS, signing part
	- Android plugin deployment solution, can import library file from APKS file now
	- ANDROID_ARMEABI_V7A, GTA SA 2.00, (ID LIMITS -> FILE_TYPE_RRR) fixed.
	- ANDROID_X64, GTA SA 2.11.32, (ID LIMITS) implemented.
	- ANDROID_ARMEABI_V7A & ANDROID_ARM64_V8A, GTA SA 2.10, (SPECIAL -> Fix crashes on newer systems) implemented.

** 7.2, 27 Sep 2023
	- ANDROID_ARM64_V8A & ANDROID_X64, GTA SA 2.11.32, split_data_main.apk can be put into OBB directory. That is  /sdcard/Android(_unprotected)/obb/com.rockstargames.gtasa/
	- ANDROID_ARM64_V8A & ANDROID_X64, GTA SA 2.11.32, (SPECIAL -> Fix crashes on newer systems) implemented.
		Fixed problem in Renderware's code.
	
		Game can also run now on case sensitive file system (EXT4 here). If game crashes on some device, then it's possible the FLA will solve this problem.
		By convention all file names should be lower case (  FILEname.txt is not acceptable).  Otherwise they will be rendered inaccessible on case-sensitive file system.
		
	- ANDROID_ARM64_V8A & ANDROID_X64, GTA SA 2.11.32, (SPECIAL -> Alter file loading order) implemented. Now files from "game root directory" take a precedence over asset files from APK archive.
	- ANDROID_ARM64_V8A & ANDROID_X64, GTA SA 2.11.32 added
	- ANDROID_X64, added support
	- APKS (split APK) format implemented in Android plugin deployment solution. Now APK/APKS is supported. Newest games use APKS, so this was important to implement.
	- the use of 'fastman92 APK modifier' is no longer required.
	
** 7.1, 24 Jun 2023
	- ANDROID_ARMEABI_V7A, GTA CTW 1.04, (Fix crashes on newer systems) implemented
	- ANDROID_ARMEABI_V7A, GTA CTW 1.04, support added
	- sample plugin improved, now to support multiple platforms. See this if you want to develop your own plugin.
	- ANDROID_ARMEABI_V7A, GTA SA 2.10 version had wrong identifier and the FLA could not be loaded.

** 7.0, 24 Jun 2023
	- ANDROID_ARMEABI_V7A, GTA SA 2.00, (OTHER LIMITS -> References) added
	- Android plugin deployment solution, became more powerful. Some options added.
	- ANDROID_ARMEABI_V7A & ANDROID_ARM64_V8A, GTA SA 2.10, (SPECIAL -> Alter file loading order) implemented. Now files from "game root directory" take a precedence over asset files from APK archive.
	- ANDROID_ARMEABI_V7A & ANDROID_ARM64_V8A, GTA SA 2.10 added
	
	- remember to use 'fastman92 APK modifier' as well to generate new better APK, especially for APK packages with target SDK > 28 like GTA SA 2.10. Without that mprotect cannot work on program segments, which is neccessary for patching the code. The plugin loader won't work without that.
		Remember to use 'fastman92 APK modifier'.
		
	- ANDROID_ARM64_V8A, platform implemented, a lot of work was neccessary to make it happen.
	- documentation\SupportedVersions.txt file created. It contains an information on which game versions are supported by the FLA.
	- documentation.xmls, some options added, this Excel file tells, which features are supported by the FLA at which games.
	- WIN_X86, (Bully SE 1.0.0.18), (DYNAMIC LIMITS -> Prop anim) implemented.
	- WIN_X86, (Bully SE 1.0.0.18), (DYNAMIC LIMITS -> Reach driver) implemented.

** 6.5, 14 May 2022
	- ANDROID_ARM32, plugin loader enhanced. Now can load .so files from StorageRootDirectory.
		For example /sdcard/Android/com.rockstargames.gtasa/files/ or /sdcard/Android_unprotected/com.rockstargames.gtasa/files/
			if 'fastman92 APK modifier' modified it.
	- ANDROID_ARM32, plugin loader, can load libcleo.so properly and CLEO plugins still work now.
	- WIN, support for reading FLA files from StorageRootDirectory\AutoID3000\fla

** 6.4, 27 Jan 2022
	- ANDROID_ARM32, GTA SA 2.0, problem solved in module SaveOfVariableLength. Game was crashing when loading the saved game.
	- WIN_X86, GTA SA 1.0 HOODLUM, (WEAPON LIMITS -> Enable weapon type loader) bug fixed in CEventDamage::ComputeDeathAnim

** 6.3, 22 Jan 2022
	- ANDROID_ARM32, GTA SA 2.0, (SCM LIMITS -> Max size of MAIN segment, Max mission size, Running scripts, Mission cleanup, Max number of used objects, Switch jump table cases) implemented
	- WIN_X86, GTA SA 1.0 HOODLUM, (MAP LIMITS -> Paths map size) bug fixed in CPathFind::SwitchRoadsOffInArea
	- Android plugin deployment solution, running the application changed. Now finding the activity to launch.
		Solves a possible problem of "Waiting for debugger" because of trying to launch unexported activity.
	- (SPECIAL -> Fix HAL crashing on devices with Android 11 and higher) restored. It was removed by mistake in the previous version.

** 6.2, 10 Jan, 2022
	- ANDROID_ARM32, GTA SA 2.0, (SPECIAL -> Disable CINFO.BIN and MINFO.BIN loading) implemented
	- ANDROID_ARM32, plugin loader fixed and prepared to work properly with the latest version of APK modifier.
		previous version was unusable.

** 6.1, 30 December, 2021
	- WIN_X64, GTA The Trilogy SA 1.0.0.14718, (DEBUG OUTPUT -> Enable debug output). Use a debugger to catch GTA internal messages.
	- WIN_X64, GTA The Trilogy SA 1.0.0.14718, (SPECIAL -> Disable CINFO.BIN and MINFO.BIN loading) implemented
	- WIN_X64, GTA The Trilogy SA 1.0.0.14718, (IDE LIMITS -> Vehicle Models) implemented
	- WIN_X64, GTA The Trilogy SA 1.0.0.14718, support implemented for this game version and ready to use
	- WIN_X86, GTA SA 1.0 HOODLUM, (IPL -> Pickup collected) checking now if the value isn't higher than 127, which is an error.
	- ANDROID_ARM32, GTA SA 2.0, (SPECIAL -> Make save of variable size) implemented
	- ANDROID_ARM32, GTA LCS, plugin loader - compatibility with "fastman92 APK modifier" and launcher's Android_unprotected.
		Works properly and Android's scoped storage problem can be solved.
	- ANDROID_ARM32, GTA SA 2.0, [HANDLING.CFG LIMITS] fixed. Handling flags for tuning the vehicle read correctly.
	- ANDROID_ARM32, GTA SA 2.0, (MAP LIMITS -> World sector size) fixed
	- WIN_X86, GTA SA 1.0 US compact/HOODLUM, compatibility with GTA V HUD by DK22Pac v0.925 ASI
	- ANDROID_ARM32, GTA SA GER 2.09, (SPECIAL -> Fix HAL crashing on devices with Android 11 and higher) implemented.
	- ANDROID_ARM32, GTA SA GER 2.09, support implemented for this game version and ready to use

** 6.0, March 26, 2021
	- ANDROID_ARM32, GTA LCS 2.4, plugin loader fixed. No more problem with getting a root path directory

** 5.9, March 25, 2021
	- ANDROID_ARM32, Bully SE 1.0.0.18, Documentation Excel file didn't have this game included. Problem fixed.
	- ANDROID_ARM32, (GTA SA 1.08), (SPECIAL -> Fix HAL crashing on devices with Android 11 and higher) fixed.

** 5.8, March 25, 2021
	- ANDROID_ARM32, (GTA SA 1.08, GTA SA 2.0, GTA LCS 2.4, Bully SE 1.0.0.18), (SPECIAL -> Fix HAL crashing on devices with Android 11 and higher) implemented.
		Game cannot not be run on devices with Android 11, for example Pixel 5 devices.
		The FLA solves this problem.
		
	- ANDROID_ARM32, Bully SE 1.0.0.18, support implemented for this game version and ready to use
	- (ANDROID_ARM32, ANDROID_ARM64, ANDROID_X86, ANDROID_X64), global exception handler has got stack dump implemented
	- WIN_X86, GTA SA 1.0 HOODLUM, (MAP LIMITS -> Paths map size) bug fixed in CPathFind::CalcRoadDensity
	- ANDROID_ARM32, GTA SA 2.0, (OTHER LIMITS -> Coronas), bug fixed

** 5.7, March 2, 2021
	- ANDROID_ARM32, GTA SA 2.0, (ROADBLOCK LIMITS -> Apply roadblox.dat better loader) implemented
	- WIN_X64, GTA 5, global exception handler now working
	- WIN_X86 & WIN_X64, global exception handler has got stack dump implemented
	- ANDROID_ARM32, GTA SA 2.0, (IPL -> Entry exits) implemented.
	- ANDROID_ARM32, GTA SA 2.0, (MAP LIMITS -> Apply paths limit patch, Paths map size) implemented.
		This required many months of work and brought a lot of progress to the project.
		
		Warning: racing won't work. CCarCtrl::SteerAICarWithPhysicsFollowPath is not altered properly. This could be done later.
			Everything else should work as expected.

	- GTA SA, new better simplified path format introduced. Alignment problem of path structures fixed.
		GTA map file renamer can convert standard GTA SA files into new format for testing.
		https://gtaforums.com/topic/944538-gta-map-file-renamer/
	
	- ANDROID_ARM32, GTA III 1.8 & GTA VC 1.09, 'STREAMING -> Memory available' implemented

** 5.6, July 12, 2020
	- ANDROID_ARM32, GTA SA 2.0, ID LIMITS fixed. Game could crash because of this bug.
	- ANDROID_ARM32, GTA SA 2.0, (IDE LIMITS -> IDE Objects Type 2, Timed Objects, Hier Objects, Weapon Models, 2DFX Effects) implemented

** 5.5, June 21, 2020
	- ANDROID_ARM32, GTA LCS 2.4, support implemented for this game version and ready to use
	- WIN_X86, GTA SA 1.0 US compact/HOODLUM, (SHADOW LIMITS -> Real time shadows) bug fixed
	- ANDROID_ARM32, GTA LCS 2.4, (SPECIAL -> Make loading of files from root directory possible) implemented.
		Allows loading of files from "game root directory".
	- ANDROID_ARM32, GTA SA 2.0, (OTHER LIMITS -> Collision size) implemented
	- ANDROID_ARM32, GTA SA 2.0, (OTHER LIMITS -> Object info entries) implemented
	- ANDROID_ARM32, GTA SA 1.08, GTA SA 2.0 (SPECIAL -> Remove LOD DFF requirement to hold native data) implemented.
		Now LOD DFF files, which are platform independendent (with uninstanced geometry) will no longer crash the game, when rendered.

** 5.4, June 6, 2020
	- ANDROID_ARM32, GTA SA 2.0, (IPL -> Dummies) implemented
	- WIN_X86, GTA SA 1.0 US compact/HOODLUM, (OTHER LIMITS -> Vehicle colors) bug fixed
	- ANDROID_ARM32, GTA SA 2.0, (DYNAMIC LIMITS -> Matrices, rwObjectInstances, PtrNode Singles, PtrNode Doubles, EntryInfoNodes) implemented
	- ANDROID_ARM32, GTA SA 2.0, [RENDERER LIMITS] implemented
	- ANDROID_ARM32, GTA SA 2.0, (ID LIMITS -> Count of killable model IDs) implemented
	- ANDROID_ARM32, GTA SA 1.08 (SPECIAL -> Alter file loading order) implemented. Now files from "game root directory" take a precedence over asset files from APK archive.
	- ANDROID_ARM32, GTA SA 2.0, ID LIMITS fixed. Game could crash because of this bug.
	- ANDROID_ARM32, GTA SA 2.0, [WATER LIMITS] implemented

** 5.3, June 2, 2020	
	- ANDROID_ARM32, GTA III 1.8, GTA VC 1.09, GTA SA 2.0 (SPECIAL -> Alter file loading order) implemented. Now files from "game root directory" take a precedence over asset files from APK archive.
	- WIN_X86, GTA SA 1.0 HOODLUM, ([MAP LIMITS] -> Paths map size) interiors fixed
	- [HANDLING.CFG LIMITS] fixed

** 5.2, May 31, 2020
	- ANDROID_ARM32, GTA SA 2.0, (DYNAMIC LIMITS -> ColModels) implemented
	- ANDROID_ARM32, GTA SA 2.0, (STREAMING -> Max number of stream handles) implemented
	- ANDROID_ARM32, GTA SA 2.0, (IMG LIMITS -> Max number of IMG archives) implemented
	- ANDROID_ARM32, GTA SA 2.0, (MAP LIMITS -> Enable path debugging) implemented
	- ANDROID_ARM32, GTA SA 2.0, (MAP LIMITS -> Water map size) implemented
	- ANDROID_ARM32, GTA SA 2.0, (MAP LIMITS -> World map size, World sector size, World LOD sector size) implemented
	- ANDROID_ARM32, GTA SA 2.0, (MAP LIMITS -> Renderware world map size) implemented
	- ANDROID_ARM32, GTA SA 2.0, ID limits implemented
	- ANDROID_ARM32, GTA SA 2.0, [HANDLING.CFG LIMITS] implemented

** 5.1, February 13, 2020
	- added (MAIN -> Disable FLA loading text)
	- Android plugin deployment solution, the game .so library can now be imported from the APK package installed on the device. 
	- the online content functionality and telemetry currently removed from the project, because of certain problem noticed.
	   it needs to be implemented in better way
	   an optimal solution will still require more planning.

** 5.0, February 9, 2020
	- ANDROID_ARM32, global exception handler implemented
	- WIN, global exception handler improved to work properly, when more than one thread crashes in very similar time 
	- WIN_X64, GTA 5, global exception handler now working
	- WIN_X86, GTA VC 1.0, (IDE LIMITS -> Vehicle Models) implemented
	- ANDROID_ARM32, GTA SA 2.0, (IPL -> Buildings) implemented
	- ANDROID_ARM32, GTA SA 2.0, vehicle audio loader implemented
	- ANDROID_ARM32, GTA SA 2.0, (IDE LIMITS -> IDE Objects Type 1, Vehicle Models, Ped Models) implemented
	- WIN_X86, GTA SA 1.0 US compact, (IMG LIMITS -> Enable handling of new enhanced IMG archives) implemented
	- WIN_X86 -> GTA III 1.0 / ANDROID_ARM32->GTA III 1.8, (SPECIAL -> Enable loading text) implemented
	- ANDROID_ARM32, (PLUGIN PATCHES -> Enable CLEO loading, Enable CLEO patches) implemented.
		CLEO ANDROID (24 Mar 2015) can be patched by the FLA to support newer game versions. See the documentation. 
	- WIN, implemented online content possibility
	- ANDROID_ARM32, GTA SA 2.0, (SPECIAL -> Fix keyboard making bad mouse movement) implemented
	- ANDROID_ARM32, GTA SA 1.0.8, GTA SA 2.0, (SPECIAL -> Fix cheats typed by keyboard not working) implemented
	- ANDROID_ARM32, GTA SA 2.0, 'STREAMING -> Memory available' implemented
	- implemented the code to write the INI file. The INI files are not supplied anymore with the FLA.
		The INI file gets generated on user's computer, when it does not exist.
	- WIN_X86, implemented the code to write Documentation, an Excel file.
	- implemented the code for Excel/INI fields.
	- WIN_X86, GTA SA 1.0 compact/HOODLUM, (ERROR REPORTING -> Requested file does not exist),
			model ID >= 374 && model ID <= 381 does not require a file and file is not required by the FLA anymore.
	- WIN_X86, GTA SA 1.0 HOODLUM, ([ADDONS] -> Enable model special feature loader) implemented
	- WIN_X86, GTA VC 1.0, [HANDLING.CFG LIMITS] implemented
	- WIN_X86, GTA SA 1.0 compact/HOODLUM, (IPL -> COccluder, apply coordinate limit patch) implemented.
	- WIN_X86, GTA SA 1.0 compact/HOODLUM, (IPL -> Occluders) wouldn't adjust the limit. Fixed.
	- WIN_X86, GTA SA 1.0 compact/HOODLUM, (OTHER LIMITS -> Set pieces, OTHER LIMITS -> Set pieces, apply coordinate limit patch) implemented.
	- WIN_X86, GTA SA 1.0 compact/HOODLUM, (WEAPON LIMITS, Melee type loader) had got a parent melee combo type added in the DAT file. It should have fixed some bugs.
	- WIN_X86, GTA SA 1.0 HOODLUM, fixed bug in Paths map size, racing mission didn't work properly
	- global exception handler improved. It didn't work on some games, because of the exceptions being caught by the process itself.
	- WIN_X86, GTA SA 1.0 compact/HOODLUM, (WATER LIMITS -> Blocks to be rendered outside world) implemented.
	- WIN_X86, GTA SA 1.0 compact/HOODLUM, (SCM LIMITS -> Scripts for brains) implemented.
	- WIN_X86, GTA SA 1.0 compact/HOODLUM, Radar blip sprite filename loader improved. Now GXT fields added.
		It has backward compatibility with older configuration file as well.
	- WIN_X86, GTA SA 1.0 compact/HOODLUM, (OTHER LIMITS -> Collision size) improved.
		Now loading of collisions from model files doesn't use a PC_Scratch, which still made a limit of 16384 bytes.
	- WIN_X86, Bully SE, (ID LIMITS -> NIF) fixed, now CModelInfo::ms_modelInfoFlags gets reallocated
	- WIN_X86, Bully SE, 'Not a prop ID range loader' fixed
	- WIN_X86, GTA SA 1.0 compact/HOODLUM, (SHADOW LIMITS -> Real time shadows) implemented
	- documentation.docx was made
	- WIN_X86, GTA IV, vehicle audio loader can load INI files from the DLCs such as
		DLC\TLAD\\content\pc\audio\config\TLAD_vehicleAudioSettings.ini
		or
		DLC\TBoGT\content\pc\\audio\config\TBoGT_vehicleAudioSettings.ini
		
		while EFLC the following would be loaded:
		TLAD\pc\\audio\\config\TLAD_vehicleAudioSettings.ini
		or 
		TBoGT\pc\audio\\config\TBoGT_vehicleAudioSettings.ini
		
	- WIN_X86, GTA IV 1.1.2.0, GTA IV 1.1.3.0, implemented DYNAMIC LIMITS -> VehicleStructs	
	- WIN_X86, GTA SA 1.0 compact/HOODLUM, (OTHER LIMITS -> Vehicle colors), 32-bit color ID implemented, now it's possible to have more than 255 colors.
	- WIN_X86, GTA SA 1.0 compact/HOODLUM, (MAP LIMITS -> Enable path debugging), now doesn't require 'Apply paths limit patch' to be enabled.
	- WIN_X86, GTA SA 1.0 HOODLUM, fixed some code related to 32-bit model IDs

** 4.3, June 19, 2017
	- WIN_X86, GTA SA 1.0 HOODLUM, 32-bit DFF/TXD IDs introduced. It took me more over 2 months of work.
	- WIN_X86, GTA SA 1.0 HOODLUM, COL ID limit can now be over 256 buglessly
	- WIN_X86, GTA SA 1.0 HOODLUM, IPL ID limit can now be over 256 buglessly
	- WIN_X86, GTA SA 1.0 compact/HOODLUM, (WEAPON LIMITS, Melee type loader) had a bug, which got fixed.
	- WIN_X86, GTA EFLC 1.1.2.0, ID limits implemented
	- WIN_X86, GTA SA 1.0 HOODLUM, fixed bug in melee combo type loader
	- WIN_X86, GTA SA 1.0 compact/HOODLUM, the limit (OTHER LIMITS -> Collision size) was never executed. There was no code to run it.
	- WIN_X86, GTA EFLC 1.1.2.0, (OTHER LIMITS -> Vehicle colors) implemented
	- WIN_X86, GTA EFLC 1.1.2.0, [HANDLING.CFG LIMITS] implemented

** 4.2, March 29, 2017
	- WIN_X86, GTA SA 1.0 compact/HOODLUM, (ERROR REPORTING -> Stream handles limit exceeded) implemented
	- WIN_X86, GTA SA 1.0 compact/HOODLUM, (IMG LIMITS -> Enable handling of IMGLIST keyword) implemented, define a list of IMG archives like in GTA IV.
	- WIN_X86, GTA SA 1.0 compact/HOODLUM, (STREAMING -> Max number of stream handles) implemented 
	- WIN_X86, GTA SA, 'Count of killable model IDs' in the previous version required the ID limits to be enabled, which was very wrong.
	- WIN_X86, GTA 1.0 compact, support added
	- added some messages boxes, when some of the FLA files is missing, in which the game would have crashed previously
	- WIN_X86, GTA SA 1.0, (OTHER LIMITS: Max number of particles) implemented
	- WIN_X86, GTA IV, improved (IDE LIMITS -> Vehicle Models), including the array loaded by file vehOff.csv now
	- WIN_X86, GTA EFLC 1.1.2.0, FXT loader implemented
	- WIN_X86, GTA EFLC 1.1.2.0 support added
	- WIN_X86, GTA SA 1.0 HOODLUM, found a missing patch at 0x73A4D7, thanks to dkluin
	- WIN_X86, GTA VC 1.0, vehicle audio loader implemented
	- WIN_X86, GTA SA 1.01, vehicle audio loader implemented
	- 'Plane speed limit disabled' was still acting as if the game was GTA SA 1.0 HOODLUM, no matter what the game was.
	- 'Water quads and triangles list triangles' was still acting as if the game was GTA SA 1.0 HOODLUM, no matter what the game was.
	- many of DYNAMIC LIMITS weren't working for games other than GTA SA
	- WIN_X86, added support of GTA SA 1.01
	- WIN_X86, GTA EFLC 1.1.2.0, the IDE limits got hacked
	- WIN_X86, GTA SA 1.0 HOODLUM, fixed bug in CPathFind::Init, fixed bug in CPathFind::RemoveInterior
	- WIN_X86, GTA IV 1.0.4.0, (OTHER LIMITS -> Vehicle colors) implemented
	- WIN_X86, GTA IV, (OTHER LIMITS -> Vehicle colors) was missing the CVehicleModelInfo::ms_policeScannerPrefixTable and CVehicleModelInfo__ms_policeScannerColourTable, which wasn't reallocated.
	- WIN_X86, GTA IV 1.0.4.0, [HANDLING.CFG LIMITS] implemented
	- WIN_X86, GTA IV 1.0.4.0, vehicle audio loader implemented
	- WIN_X86, GTA IV 1.0.4.0, FXT loader implemented
	- WIN_X86, GTA IV 1.0.4.0, the IDE limits got hacked
	- WIN_X86, GTA IV 1.0.4.0 support added

** 4.1, January 2, 2017
	- WIN_X86, GTA IV 1.0.7.0, GTA IV 1.0.8.0, implemented DYNAMIC LIMITS:
		VehicleStructs, EntryInfoNodes, Objects, Tasks, Events, PointRoute,
		CDummyTask, PatrolRoute, InteriorInst, PortalInst, CAnimBlender,
		CAtdNodeAnimChangePooledObject, CAtdNodeAnimPlayer, crFrameFilterBoneMask,
		crFrameFilterBoneAnalogue, crExpressionProcessor, crmtObserver,
		NavMeshRoute, Cam, ExplosionType, PedAttractors
	- WIN_X86, GTA IV 1.0.7.0, GTA IV 1.0.8.0, (OTHER LIMITS -> Vehicle colors) implemented
	- WIN_X86, GTA VC 1.0, 'STREAMING -> Memory available' implemented
	- WIN_X86, GTA SA 1.0 HOODLUM, Car generator with invalid model ID is getting registered implemented
	- WIN_X86, GTA SA 1.0 HOODLUM, GTA_ERROR_CAR_GENERATOR_LIMIT_EXCEEDED error implemented.
	- WIN_X86, GTA SA 1.0 HOODLUM, ([DYNAMIC LIMITS] -> ColModels) fixed
	- WIN_X86, GTA IV 1.0.7.0, handling.cfg limits would crash if new limit was set, but not increased. Fixed.
	- WIN_X86, GTA IV 1.0.8.0, the IDE limits got hacked

** 4.0, December 12, 2016
	- started work on support of Android platforms, but unfinished
	- Microsoft Visual C++ 2010 Redistributable Package (x86) is no longer required for DllTricks
	- WIN_X86, GTA IV 1.0.8.0 support added, a lot of options are implemented
	- WIN_X86, GTA EFLC 1.1.2.0 support added, vehicle audio loader implemented
	- major design changes,
	  with the thought of supporting multiple plaforms, multiple games, multiple executables.

** 3.45, June 30, 2016
	- GTA SA, MAP LIMITS -> Enable track config loader implemented.
	- GTA SA, 'MAP LIMITS -> Number of tracks.dat files' option was removed.
	- GTA SA, fixed bug in CRoadBlocks which crashed the FLA completely in other games than GTA SA

** 3.4, June 30, 2016
	- GTA SA, fixed bug in SHADOW LIMITS -> Poly bunches
	- GTA SA, added ROADBLOCK LIMITS -> Apply roadblox.dat better loader

** 3.3, June 21, 2016
	- GTA SA, added PED STREAMING -> Pedgrp peds per group

** 3.2, June 8, 2016
	- GTA SA, fixed little bug with the paths in CRoadBlocks::GetRoadBlockNodeInfo
	
** 3.1, 07-06-2016, June 7, 2016
	- GTA SA, firing a rocket projectile didn't work because of little bug.
	- GTA SA, melee.dat limits had something missing, what caused the audio of weapons not working
	
** 3.0, June 3, 2016
	- GTA SA, WEAPON LIMITS were disabled in the previous version, which was a mistake

** 2.9, March 6, 2016
	- GTA SA, added SHADOW LIMITS: Shadows stored, Poly bunches, Static shadows, Permanent shadows
	- Bully SE, added DYNAMIC LIMITS: Peds, Vehicles, Objects
	- GTA SA, added DYNAMIC LIMITS: Peds, Vehicles, Objects, Tasks, Events, PointRoute, PatrolRoute, NodeRoute, TaskAllocator, PedAttractors
	- global exception handler improved

** 2.8, May 5, 2016
	- GTA VC, ID limits had enabled debug mode, which was a mistake
	- GTA IV, PtrNode Singles, PtrNode Doubles had enabled debug mode, which was a mistake
	- GTA SA, weapon limits improved

** 2.7, May 28, 2016
	- GTA VC, ID limits had enabled debug mode, which was a mistake
	- GTA IV, PtrNode Singles, PtrNode Doubles had enabled debug mode, which was a mistake
	- GTA SA, weapon limits improved, added BINOCULARS_TYPE

** 2.6, May 21, 2016
	- GTA SA, melee.dat limits hacked, added to WEAPON LIMITS
	- GTA SA, bug with crashing map in menu fixed
	- GTA SA, improved weapon limits, completely new gtasa_weapon_config.dat

** 2.5, April 15, 2016
	- GTA SA, added MAP LIMITS -> Enable frontend map different
	- GTA III, added ID limits
	- GTA III, introduced support
	- GTA IV, added IPL -> Buildings, Animated buildings, Dummies
	- GTA SA, weapon limits got hacked!
	- GTA SA, added SCM LIMITS -> Switch jump table cases

** 2.4, April 4, 2016
	- GTA SA, fixed bug AUZO boxes coordinate limit hack
	- GTA SA, fixed bug in Paths map size
	- GTA IV, added DYNAMIC LIMITS -> PtrNode Singles
	- GTA IV, added DYNAMIC LIMITS -> PtrNode Doubles
	- GTA IV, added IPL -> Inst entries per file
	- GTA IV, added IPL -> Entity index array
	- GTA SA, added train type carriages loader
	- GTA IV, added train type carriages loader
	- GTA IV, added MAP LIMITS -> Radar map size
	- GTA IV, added MAP LIMITS -> Water map size
	- GTA IV, vehicle audio loader now works
	- GTA SA, added vehicle special features for ZR350
	- GTA SA, added SCM LIMITS -> Max number of used objects
	- GTA SA, added price multipliers to level limits

** 2.3, 19-02-2016 February 19, 2016
	- Bully scholarschip Edition, this game is supported from now on!
	- GTA SA, added radar blip sprite filename loader
	- GTA SA, vehicle special features, hydra shooting fixed.
	- GTA SA, added train type carriage loader
	- GTA SA, added OTHER LIMITS -> Radar traces
	- GTA SA, implemented errors for killable IDs exceeded
	- GTA SA, SPECIAL -> Fix streaming memory bug cannot crash the game anymore.

** 2.2, November 28, 2015
	- cheatStrings.dat updated with real cheat codes, thanks to Junior_Djjr
	- GTA SA, added SPECIAL -> Fix streaming memory bug, thanks to Link2012 for explanation of some Renderware structures.
	- GTA IV, added MAP LIMITS -> Tracks.dat file size limit
	- GTA SA, added MAP LIMITS -> Tracks.dat file size limit
	- GTA IV, world sector map limits hacked
	- GTA SA, added VISIBILITY -> Weapon peds for PC limit
	- GTA SA, added SPECIAL -> Make paintjobs work for any ID
	- GTA IV, added IDE LIMITS: IDE Objects Type 1, IDE Objects Type 2, Timed Objects, Vehicle Models, Ped Models
	- GTA SA, IDE:2dfx limit hacked

** 2.1, September 9, 2015
	- GTA SA, IMG archives can be recursive. When Enhanced IMG archives option is enabled.
	- GTA V, FXT loader made
	- GTA IV, FXT loader made
	- GTA SA, fixed a bug in ID limits over 65535
	- GTA IV, the message about vehicle audio loader enabled was missing in log file.
	- GTA SA, level limits fixed, CStreaming__GetDefaultCabDriverModel had an infinite loop freezing the game.
	- GTA SA, COL ID limit got hacked. Now CColModel items can have unsigned __int16 exCOL_file_ID;
	
** 2.0, August 31, 2015
	- GTA IV, vehicle audio loader made
	- GTA SA, made a good class CIniReader and reading the values of limit looks in source code much better.
	- GTA SA, vehicle audio loader integrated into limit adjuster.
	- GTA SA, added VEHICLE SPECIAL FEATURES
	- GTA SA, added OTHER LIMITS -> LOD distance
	- GTA SA, cheat string loader integrated into limit adjuster.
	- GTA SA, pickup limit including the coordinate limit hacked
	- GTA SA, AUZO boxes limit hacked including the coordinate limit for this
	- GTA SA, added ERROR REPORTING -> Model has collision already set up
	- GTA SA, tracks*.dat coordinate limit hacked
	- GTA SA, added SPECIAL -> Disable radar rotation
	- GTA SA, added LEVEL LIMITS, now it's possible new zones and assign the police, fire, ambulance, taxi IDs
	- GTA SA, added IMG LIMITS -> Increase the IMG archive size limit
	- GTA SA, added DEBUGGING -> Copy info to pad 1 from pad 0
	- GTA SA, added path debugging
	- GTA SA, fixed Coronas limit, function CCoronass::Render, more than 64 coronas can now be rendered.
	- GTA SA, now coordinates of default San Andreas zones are updated with "Radar map size"

** 1.9, June 21, 2015
	- GTA SA, added DIRECTORY LIMITS: Extra objects directory, Cutscene directory, Clothes directory
	- GTA SA, added IPL -> Entry Exits
	- GTA SA, added IPL -> Timecycle modifiers
	- GTA SA, added IPL: CULL mirror attribute zones, CULL tunnel attribute zones, CULL attribute zones
	- GTA SA, moved Stunt jumps from [DYNAMIC LIMITS] to [IPL]
	- GTA SA, vehicle colors (carcols.dat) limit hacked.
	- GTA SA, added support of enhanced fastman92 IMG archives. Supported longer filenames, compression and encryption.
	- GTA_ERROR_IMG_ARCHIVE_NEEDS_REBUILDING was dependent on GTA_ERROR_CAR_GENERATOR_LIMIT_EXCEEDED and wouldn't work without. Fixed.
	- GTA IV, now ASLR is supported and limit adjuster started working instead of crashing the game while loading ASI plugin.	

** 1.8, May 2, 2015
	- GTA SA, added a possibility to use __int32 base ID. Now you can have more than 65535 file IDs!
	- GTA SA, added ERROR REPORTING: IMG archive needs rebuilding
	- GTA SA, added STREAMING options:
		- Number of requested models above which the game considers loading very busy
		- Minimum number of iterations in LoadAllRequestedModels
	- GTA SA, added DYNAMIC LIMITS -> Stunt Jumps
	- GTA SA, added WATER LIMITS -> Water vertices

** 1.7, April 7, 2015
	- GTA IV, handling.cfg limits hacked
	- GTA SA, object.dat limit hacked

** 1.6, April 6, 2015
	- GTA SA, added [SPECIAL] -> Make save of variable size.
	- GTA SA, added DEBUG OUTPUT -> Enable debug output. Use a debugger to catch GTA internal messages.
	- GTA SA, added OTHER LIMITS -> Coronas
	- GTA SA, fixed position of zones revealed on radar. Although, there's still no support for zones revealed outside of -3000 to 3000.
	- GTA SA, fixed CIDlimitManagerGeneral<eFileType>::IsAnyIDlimitIncreased()
	- GTA SA, added DYNAMIC LIMITS: CustomEnvMapPipeMatDataPool, CustomEnvMapPipeAtmDataPool, CustomSpecMapPipeMaterialDataPool
	- GTA SA, added MAP LIMITS: Renderware world map size
	- GTA SA, added RENDERER LIMITS:
		- Invisible entity pointers
		- Visible super LOD pointers
		- Visible LOD pointers
		- Visible entity pointers
		
	- GTA SA, added VISIBILITY LIMITS:
		- Alpha list limit
		- Alpha boat atomic list limit
		- Alpha entity list limit
		- Alpha underwater entity list limit
		- Alpha really draw last list limit
		
	- GTA SA, fixed little bugs when ID is unsigned
	- GTA SA, fixed CPathFind::CompleteNewInterior, storing coordinates.
	
** 1.5, March 14, 2015
	- GTA SA, added path limit, supported two formats of path files: 'standard GTA SA path format' and 'fastman92 path format'
		programmers who want to support new path file format should read the documentation.
	- GTA SA, added SCM LIMITS -> Mission cleanup
	- GTA SA, added OTHER LIMITS: References, Cover points, Collision size

** 1.4
	- GTA SA, fixed 'World map size' limit. Added missing dependency, constant -3000.0 and 3000.0 values for QuadTree constructors
	- GTA SA, fixed limit MAP LIMITS -> Water map size
	- GTA SA, added WATER LIMITS: Water triangles, Water quads, Water quads and triangles list
	- GTA SA, added IPL -> Dummies, Entity index array
	- GTA SA, added DYNAMIC LIMITS: QuadTreeNodes, Collision links
	- GTA SA, added error reporting for 2 common errors while creating maps

** 1.3, February 15, 2015
	- added limit patches for GTA SA limits: IMG archives, PtrNode Singles, PtrNode Doubles, EntryInfoNodes
	- fixed RCBANDIT handling line processing. Now identified by handling name, instead of index.
	- added map limits to GTA SA and some other limits
	- fixed badly written CTheCarGenerators::RemoveCarGenerators
	- added support of GTA IV, ID limits hacked.
	- bug fixed in CGenericGameStorage::CheckDataNotCorrupt, pointer would become invalid
	- added limit ([ID LIMITS] Count of killable model IDs)
	- added patch for CLEO library 4.3.16 to make it compatible with limit adjuster
	- added support of GTA VC, ID limits hacked.
	- fixed bug of cargrp.dat limit because of missing memset with NULL value
	- fixed bug in CCarGenerator::CheckForBlockage
		New car would be created on top of existing one.
	- added crash exception handler
	- added new option ([CAR STREAMING] Accept any ID for car generator)

** 1.2, November 11, 2014
	- fixed bike handling bug caused by not applying to different calculations to bikes.
	- added ([STREAMING] Memory available) limit
	- added a check to Streaming_DesiredNumberOfVehiclesLoaded value, it must be higher than cargrp.dat limit.
	- added a check to Cargrp cars per group value of limit.
	- fixed log messages of IDE limits, they were missing a value of limit.
	
** 1.1, November 17, 2014
	- fixed missing #pragma pack(pop) to source code, added memset to IDE limits.
** 1.0, first version released
** start of development, June 1, 2014

***** The FLA includes certain files, which are property of third-party entities:
CLEO for GTA games on Android - made by Alexander Blade
SignAPK - unknown author
7-zip - made by Igor Pavlov

***** Credits:
LCstuntman - verifying the paths of game directories on Android in his own device, creating an illustration
Noskillx - for reporting a long time bug with handling.cfg limits
Junior_Djjr - cheatStrings.dat updated with real cheat codes and promoting this project on his website
Link2012 - for explanation of some Renderware structures.
RJSanmaster - for leading into discovery of 'Count of killable model IDs' limit.
DK22Pac - for giving a first insight into CPathFind structure
Parik - for helping with WINAPI GUI stuff
iFarbod - for testing of weapon limits
dkluin - for intense testing of the FLA and finding few bugs
Claude_Lib - for an active debugging of the FLA on his computer
downtheory - for good collaboration with debugging of GTA/Bully game crashing on Android 11

*****
Copyright (c) 2024, fastman92
All rights reserved.

***** Informations:
Date of release: 14-06-2024 (d-m-Y)
Author: fastman92
E-mail: fastman92@gmail.com
Visit fastman92.com