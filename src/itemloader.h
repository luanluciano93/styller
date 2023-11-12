// Copyright 2023 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#ifndef FS_ITEMLOADER_H
#define FS_ITEMLOADER_H

#include "fileloader.h"

enum itemgroup_t
{
	ITEM_GROUP_NONE,

	ITEM_GROUP_GROUND,
	ITEM_GROUP_CONTAINER,
	ITEM_GROUP_WEAPON,     // deprecated
	ITEM_GROUP_AMMUNITION, // deprecated
	ITEM_GROUP_ARMOR,      // deprecated
	ITEM_GROUP_CHARGES,
	ITEM_GROUP_TELEPORT,   // deprecated
	ITEM_GROUP_MAGICFIELD, // deprecated
	ITEM_GROUP_WRITEABLE,  // deprecated
	ITEM_GROUP_KEY,        // deprecated
	ITEM_GROUP_SPLASH,
	ITEM_GROUP_FLUID,
	ITEM_GROUP_DOOR, // deprecated
	ITEM_GROUP_DEPRECATED,

	ITEM_GROUP_LAST
};

/////////OTB specific//////////////
enum clientVersion_t
{
	CLIENT_VERSION_750 = 1,
	CLIENT_VERSION_755 = 2,
	CLIENT_VERSION_760 = 3,
	CLIENT_VERSION_770 = 3,
	CLIENT_VERSION_780 = 4,
	CLIENT_VERSION_790 = 5,
	CLIENT_VERSION_792 = 6,
	CLIENT_VERSION_800 = 7,
	CLIENT_VERSION_810 = 8,
	CLIENT_VERSION_811 = 9,
	CLIENT_VERSION_820 = 10,
	CLIENT_VERSION_830 = 11,
	CLIENT_VERSION_840 = 12,
	CLIENT_VERSION_841 = 13,
	CLIENT_VERSION_842 = 14,
	CLIENT_VERSION_850 = 15,
	CLIENT_VERSION_854_BAD = 16,
	CLIENT_VERSION_854 = 17,
	CLIENT_VERSION_855 = 18,
	CLIENT_VERSION_860_OLD = 19,
	CLIENT_VERSION_860 = 20,
};

enum rootattrib_
{
	ROOT_ATTR_VERSION = 0x01,
};

enum itemattrib_t
{
	ITEM_ATTR_FIRST = 0x10,
	ITEM_ATTR_SERVERID = ITEM_ATTR_FIRST,
	ITEM_ATTR_CLIENTID,
	ITEM_ATTR_NAME,
	ITEM_ATTR_DESCR,
	ITEM_ATTR_SPEED,
	ITEM_ATTR_SLOT,
	ITEM_ATTR_MAXITEMS,
	ITEM_ATTR_WEIGHT,
	ITEM_ATTR_WEAPON,
	ITEM_ATTR_AMU,
	ITEM_ATTR_ARMOR,
	ITEM_ATTR_MAGLEVEL,
	ITEM_ATTR_MAGFIELDTYPE,
	ITEM_ATTR_WRITEABLE,
	ITEM_ATTR_ROTATETO,
	ITEM_ATTR_DECAY,
	ITEM_ATTR_SPRITEHASH,
	ITEM_ATTR_MINIMAPCOLOR,
	ITEM_ATTR_07,
	ITEM_ATTR_08,
	ITEM_ATTR_LIGHT,

	// 1-byte aligned
	ITEM_ATTR_DECAY2,     // deprecated
	ITEM_ATTR_WEAPON2,    // deprecated
	ITEM_ATTR_AMU2,       // deprecated
	ITEM_ATTR_ARMOR2,     // deprecated
	ITEM_ATTR_WRITEABLE2, // deprecated
	ITEM_ATTR_LIGHT2,
	ITEM_ATTR_TOPORDER,
	ITEM_ATTR_WRITEABLE3, // deprecated

	ITEM_ATTR_WAREID,

	ITEM_ATTR_LAST
};

enum itemflags_t
{
	FLAG_BLOCK_SOLID = 1 << 0,
	FLAG_BLOCK_PROJECTILE = 1 << 1,
	FLAG_BLOCK_PATHFIND = 1 << 2,
	FLAG_HAS_HEIGHT = 1 << 3,
	FLAG_USEABLE = 1 << 4,
	FLAG_PICKUPABLE = 1 << 5,
	FLAG_MOVEABLE = 1 << 6,
	FLAG_STACKABLE = 1 << 7,
	FLAG_FLOORCHANGEDOWN = 1 << 8,   // unused
	FLAG_FLOORCHANGENORTH = 1 << 9,  // unused
	FLAG_FLOORCHANGEEAST = 1 << 10,  // unused
	FLAG_FLOORCHANGESOUTH = 1 << 11, // unused
	FLAG_FLOORCHANGEWEST = 1 << 12,  // unused
	FLAG_ALWAYSONTOP = 1 << 13,
	FLAG_READABLE = 1 << 14,
	FLAG_ROTATABLE = 1 << 15,
	FLAG_HANGABLE = 1 << 16,
	FLAG_VERTICAL = 1 << 17,
	FLAG_HORIZONTAL = 1 << 18,
	FLAG_CANNOTDECAY = 1 << 19, // unused
	FLAG_ALLOWDISTREAD = 1 << 20,
	FLAG_UNUSED = 1 << 21,        // unused
	FLAG_CLIENTCHARGES = 1 << 22, /* deprecated */
	FLAG_LOOKTHROUGH = 1 << 23,
	FLAG_ANIMATION = 1 << 24,
	FLAG_FULLTILE = 1 << 25, // unused
	FLAG_FORCEUSE = 1 << 26,
};

// 1-byte aligned structs
#pragma pack(1)

struct VERSIONINFO
{
	uint32_t dwMajorVersion;
	uint32_t dwMinorVersion;
	uint32_t dwBuildNumber;
	uint8_t CSDVersion[128];
};

struct lightBlock2
{
	uint16_t lightLevel;
	uint16_t lightColor;
};

#pragma pack()
/////////OTB specific//////////////
#endif
