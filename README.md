ElTorqiro_UltimateAbility
=========================
An "Ultimate Ability" UI mod for the MMORPG "The Secret World"
   
   
What is this?
-------------
ElTorqiro_InCombat is a heads-up-display module that indicates when a character is in combat.  It has a rich set of configuration options, and you can even use your own custom images for the display.
Feedback, updates and community forum can be found at https://forums.thesecretworld.com/showthread.php?86001-MOD-ElTorqiro_InCombat
   
   
User Configuration
------------------
The mod provides an interactive on-screen icon which can be used to bring up a configuration panel.  Hover the mouse over the icon for instructions.  If you have Viper's Topbar Information Overload (VTIO) installed, or an equivalent handler, the icon will be available in a VTIO slot.
   
You can also toggle the configuration window with the option ElTorqiro_InCombat_ShowConfig, which can be set via a chat command as follows:
/setoption ElTorqiro_InCombat_ShowConfig 1
(1 = open, 0 = closed)
   
   
Custom Indicator Graphics
-------------------------
You can use custom images for the in-combat indicators.  The images match the possible combat states, i.e. threatened and combat.  They must be in PNG format, but can be any size and shape; you can even use them to replace the entire HUD if you disable some of the other UI elements.  The filenames are case-sensitive, as follows:

threatened.png	: when mobs are hunting you, but you are not yet engaged in combat
combat.png : when you are engaged in combat
	
Place these images into the ElTorqiro_InCombat folder, and then enable the custom icons option in the mod's in-game configuration window.
  
  
Known Issues
------------
* None yet   
   
  
Installation
------------
Extract the contents of the zip file into: YOUR_TSW_DIRECTORY\Data\Gui\Customized\Flash
This will add the appropriate directory and put the files in the right place.

Uninstallation
--------------
Delete the directory: YOUR_TSW_DIRECTORY\Data\Gui\Customized\Flash\ElTorqiro_InCombat
   
   
Source Code
-----------
You can get the source from GitHub at https://github.com/eltorqiro/TSW-InCombat