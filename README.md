# MXPF
MXPF is an xEdit scripting library that provides a variety of functions for the generation of patches.  Want to rebalance armor and weapons in Skyrim?  Done.  Apply a new particle effect to every weather?  Easy.  Change the configuration of all NPCs?  Cake.

MXPF is comprised a suite of functions that do the work of finding the records you want to patch, identifying/creating a patch file, and copying records to the patch.  Where you would normally have to learn to do all of these steps yourself, with MXPF you can accomplish everything you need with a few simple functions.

## Installation
To install, simply copy the files in the Edit Scripts folder to xEdit's Edit Scripts folder.

The Documentation folder contains all the documentation you'll need to get started using MXPF to automate the creation of patches in xEdit.

The ESPs folder has three plugins for use with the MXPF test suite, you don't need to install them for MXPF to function.

## Dependencies
* [mteFunctions](https://github.com/matortheeternal/TES5EditScripts/blob/master/trunk/Edit%20Scripts/mteFunctions.pas): Utility and helper functions for xEdit scripting.  Comes packaged with mxpf.
* [jvTest](https://github.com/matortheeternal/jvTest): jvInterpreter testing framework.  Comes packaged with mxpf.
* xEdit: Download from [Nexus Mods](http://www.nexusmods.com/skyrim/mods/25859), or [GitHub](https://github.com/TES5Edit/TES5Edit).  v3.1.2 or newer is required.  The test suite only works with TES5Edit.
* Bethesda game: xEdit supports [Skyrim](http://store.steampowered.com/app/72850), 
[Oblivion](http://store.steampowered.com/app/22330), 
[Fallout 3](http://store.steampowered.com/app/22300), and 
[Fallout New Vegas](http://store.steampowered.com/app/22380)
