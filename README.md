# Convenient Bags

__Convenient Bags__ (_previously Unpack Bags_) is a mod for [Project Zomboid](http://projectzomboid.com/) which adds several new features to the vanilla item containers.

## Features

### Overview

- Add tags to a bag to allow quick sorting of items
- Quickly pack items into a bag
- Quickly unpack items from a bag
- Quickly drop all equipped bags via keypress
- Includes translations for English, German, French, Russian and Finnish
- [Tiny AVC](https://github.com/blind-coder/pz-tiny_avc) Support

![preview](https://raw.githubusercontent.com/rm-code/convenient-bags/master/RMConvenientBags/poster.png)

### Unpacking Bags

Bags can be quickly unpacked via a context menu. The bag will drop its contents into the container in which it currently is contained (this can be the player's inventory, a container or even the floor). If the container is full the bag will only be partially emptied.

### Using tags

Tags can be added to a bag to limit it only to certain types of items. Click on the bag you want to edit and select "Edit Tags". A small text box will show up, allowing you to add or remove tags. This can be an item category (Food, Weapon, etc.) or an item's full or partial name (Water, Bowl, Garbage Bag). You can add multiple tags at once by separating them with a comma (e.g.: ```Food, Hammer, Butter Knife```).

These tags are used by the packing option (see below).

### Packing Bags

Bags can also be conveniently filled with items. Clicking on "Pack items" will move all items in the same container as the bag except for containers and equipped items into the bag.

By using tags this option can be limited to certain types of items. If a bag has at least one tag only items fitting the tag will be transferred into the bag.

![packing.gif](https://cloud.githubusercontent.com/assets/11627131/9081433/8f21224a-3b5c-11e5-94ac-5097bd4e9214.gif)

### Turn Tail

The mod also allows you to use a key (Default: 'X' - can be changed in the options menu) to quickly drop equipped bags in case of an emergency. This might come in handy if you are overencumbered while being ambushed by some zombies.

The bags will be dropped in the following order:

1. Bags equipped in primary slot
2. Bags equipped in secondary slot
3. Bags equipped on the back

This feature was inspired by the original "Turn Tail" Mod by The_Real_Al. 

## Installation

[Look here](http://theindiestone.com/forums/index.php/topic/1395-) for installation instructions.

## Translations
The mod has already been translated to a bunch of different languages. If you want to add a translation, feel free to fork this project and send a pull request.

Adding new languages is quite easy. Just take a look at the ```media/lua/shared/Translate``` folder in this mod.

For more information about translations check the [official forums](http://theindiestone.com/forums/index.php/forum/56-).
