# Changelog

### Version 1.6.0

- Added support for quickly packing a bag ([Closes #5](https://github.com/rm-code/unpack-bags/issues/5))
	- Can be selected in the inventory screen and will grab all items in the same container as the bag
	- Ignores bags and equipped items
- Changed folder structure and added a mod id

### Version 1.5.0

- Added support for Tiny AVC (see https://github.com/blind-coder/pz-tiny_avc/releases/)

### Version 1.4.0

- Added a world context menu for unpacking items on the floor ([Closes #3](https://github.com/rm-code/unpack-bags/issues/3))

### Version 1.3.0

- Duration of the TimeAction is now dependent on the amount of items in the bag
- Bags can now be partially emptied if the target container is too small to hold all the items ([Closes #4](https://github.com/rm-code/unpack-bags/issues/4))
- [Fixed #2](https://github.com/rm-code/unpack-bags/issues/2): Items are now placed on the bag's IsoSquare

### Version 1.2.0

- Added translations for the warning modal
- Added russian translations
- Changed the background color of the warning modal
- Update the preview image

### Version 1.1.0

- Added special menu entries for one and multiple objects
- Added possiblity for translations
	- Added german translation
	- Added finnish translation
	- Added french translation
- [Fixed #1](https://github.com/rm-code/unpack-bags/issues/1): Items are no longer deleted
- Updated folder structure to make the mod work with the latest version of PZ
- Remove utility dependencies (no extra files are needed to run the mod)

### Version 1.0.4

- Updated to work with the latest modding utils

### Version 1.0.3

- Fixed: Mod not loading due to 'require' calls

### Version 1.0.2

- Fixed bug with expanded inventory list
- Fixed capacity exploit (thx to Tony_Travesi for reporting)
- Refactoring

### Version 1.0.1

- Updated to work with 2.9.9.17
=> added mod.info & poster image

### Version 1.0.0

- Shows multiple menu entries if player clicks on stacked bags

### Version 0.9.2

- Bags can now also be emptied out in containers & on the floor

### Version 0.9.1

- Fixed: Inventory refreshes correctly now.

### Version 0.9.0

- Added menu option to empty out a bag
- Shows the amount of items in the bag
