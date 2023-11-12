// Copyright 2023 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#include "otpch.h"

#include "housetile.h"

#include "configmanager.h"
#include "game.h"
#include "house.h"

extern Game g_game;
extern ConfigManager g_config;

HouseTile::HouseTile(uint16_t x, uint16_t y, uint8_t z, House* house) : DynamicTile(x, y, z), house(house) {}

void HouseTile::addThing(int32_t index, Thing* thing)
{
	Tile::addThing(index, thing);

	if (!thing->getParent()) {
		return;
	}

	if (Item* item = thing->getItem()) {
		updateHouse(item);
	}
}

void HouseTile::internalAddThing(uint32_t index, Thing* thing)
{
	Tile::internalAddThing(index, thing);

	if (!thing->getParent()) {
		return;
	}

	if (Item* item = thing->getItem()) {
		updateHouse(item);
	}
}

void HouseTile::updateHouse(Item* item)
{
	if (item->getParent() != this) {
		return;
	}

	Door* door = item->getDoor();
	if (door) {
		if (door->getDoorId() != 0) {
			house->addDoor(door);
		}
	} else {
		BedItem* bed = item->getBed();
		if (bed) {
			house->addBed(bed);
		}
	}
}

ReturnValue HouseTile::queryAdd(int32_t index, const Thing& thing, uint32_t count, uint32_t flags,
                                Creature* actor /* = nullptr*/) const
{
	if (const Creature* creature = thing.getCreature()) {
		if (const Player* player = creature->getPlayer()) {
			if (!house->isInvited(player)) {
				return RETURNVALUE_PLAYERISNOTINVITED;
			}
		} else {
			return RETURNVALUE_NOTPOSSIBLE;
		}
	} else if (thing.getItem()) {
		if (actor) {
			Player* actorPlayer = actor->getPlayer();
			if (!house->isInvited(actorPlayer)) {
				return RETURNVALUE_CANNOTTHROW;
			}
		}
	}
	return Tile::queryAdd(index, thing, count, flags, actor);
}

Tile* HouseTile::queryDestination(int32_t& index, const Thing& thing, Item** destItem, uint32_t& flags)
{
	if (const Creature* creature = thing.getCreature()) {
		if (const Player* player = creature->getPlayer()) {
			if (!house->isInvited(player)) {
				const Position& entryPos = house->getEntryPosition();
				Tile* destTile = g_game.map.getTile(entryPos);
				if (!destTile) {
					std::cout << "Error: [HouseTile::queryDestination] House entry not correct"
					          << " - Name: " << house->getName() << " - House id: " << house->getId()
					          << " - Tile not found: " << entryPos << std::endl;

					destTile = g_game.map.getTile(player->getTemplePosition());
					if (!destTile) {
						destTile = &(Tile::nullptr_tile);
					}
				}

				index = -1;
				*destItem = nullptr;
				return destTile;
			}
		}
	}

	return Tile::queryDestination(index, thing, destItem, flags);
}

ReturnValue HouseTile::queryRemove(const Thing& thing, uint32_t count, uint32_t flags,
                                   Creature* actor /*= nullptr*/) const
{
	const Item* item = thing.getItem();
	if (!item) {
		return RETURNVALUE_NOTPOSSIBLE;
	}

	if (actor && g_config[ConfigKeysBoolean::ONLY_INVITED_CAN_MOVE_HOUSE_ITEMS]) {
		Player* actorPlayer = actor->getPlayer();
		if (!house->isInvited(actorPlayer)) {
			return RETURNVALUE_NOTPOSSIBLE;
		}
	}
	return Tile::queryRemove(thing, count, flags);
}
