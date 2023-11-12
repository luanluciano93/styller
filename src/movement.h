// Copyright 2023 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#ifndef FS_MOVEMENT_H
#define FS_MOVEMENT_H

#include "baseevents.h"
#include "creature.h"
#include "item.h"
#include "luascript.h"
#include "vocation.h"

extern Vocations g_vocations;

enum MoveEvent_t
{
	MOVE_EVENT_STEP_IN,
	MOVE_EVENT_STEP_OUT,
	MOVE_EVENT_EQUIP,
	MOVE_EVENT_DEEQUIP,
	MOVE_EVENT_ADD_ITEM,
	MOVE_EVENT_REMOVE_ITEM,
	MOVE_EVENT_ADD_ITEM_ITEMTILE,
	MOVE_EVENT_REMOVE_ITEM_ITEMTILE,

	MOVE_EVENT_LAST,
	MOVE_EVENT_NONE
};

class MoveEvent;
using MoveEvent_ptr = std::unique_ptr<MoveEvent>;

struct MoveEventList
{
	std::list<MoveEvent> moveEvent[MOVE_EVENT_LAST];
};

class MoveEvents final : public BaseEvents
{
public:
	MoveEvents();
	~MoveEvents();

	// non-copyable
	MoveEvents(const MoveEvents&) = delete;
	MoveEvents& operator=(const MoveEvents&) = delete;

	uint32_t onCreatureMove(Creature* creature, const Tile* tile, MoveEvent_t eventType);
	ReturnValue onPlayerEquip(Player* player, Item* item, slots_t slot, bool isCheck);
	ReturnValue onPlayerDeEquip(Player* player, Item* item, slots_t slot);
	uint32_t onItemMove(Item* item, Tile* tile, bool isAdd);

	MoveEvent* getEvent(Item* item, MoveEvent_t eventType);

	bool registerLuaEvent(MoveEvent* event);
	bool registerLuaFunction(MoveEvent* event);
	void clear(bool fromLua) override final;

private:
	using MoveListMap = std::map<uint16_t, MoveEventList>;
	using MovePosListMap = std::map<Position, MoveEventList>;
	void clearMap(MoveListMap& map, bool fromLua);
	void clearPosMap(MovePosListMap& map, bool fromLua);

	LuaScriptInterface& getScriptInterface() override;
	std::string_view getScriptBaseName() const override;
	Event_ptr getEvent(std::string_view nodeName) override;
	bool registerEvent(Event_ptr event, const pugi::xml_node& node) override;

	void addEvent(MoveEvent moveEvent, uint16_t id, MoveListMap& map);

	void addEvent(MoveEvent moveEvent, const Position& pos, MovePosListMap& map);
	MoveEvent* getEvent(const Tile* tile, MoveEvent_t eventType);

	MoveEvent* getEvent(Item* item, MoveEvent_t eventType, slots_t slot);

	MoveListMap uniqueIdMap;
	MoveListMap actionIdMap;
	MoveListMap itemIdMap;
	MovePosListMap positionMap;

	LuaScriptInterface scriptInterface;
};

using StepFunction = std::function<uint32_t(Creature* creature, Item* item, const Position& pos)>;
using MoveFunction = std::function<uint32_t(Item* item, Item* tileItem, const Position& pos)>;
using EquipFunction =
    std::function<ReturnValue(MoveEvent* moveEvent, Player* player, Item* item, slots_t slot, bool boolean)>;

class MoveEvent final : public Event
{
public:
	explicit MoveEvent(LuaScriptInterface* interface);

	MoveEvent_t getEventType() const;
	void setEventType(MoveEvent_t type);

	bool configureEvent(const pugi::xml_node& node) override;
	bool loadFunction(const pugi::xml_attribute& attr, bool isScripted) override;

	uint32_t fireStepEvent(Creature* creature, Item* item, const Position& pos);
	uint32_t fireAddRemItem(Item* item, Item* tileItem, const Position& pos);
	ReturnValue fireEquip(Player* player, Item* item, slots_t slot, bool isCheck);

	uint32_t getSlot() const { return slot; }

	// scripting
	bool executeStep(Creature* creature, Item* item, const Position& pos);
	bool executeEquip(Player* player, Item* item, slots_t slot, bool isCheck);
	bool executeAddRemItem(Item* item, Item* tileItem, const Position& pos);
	//

	// onEquip information
	uint32_t getReqLevel() const { return reqLevel; }
	uint32_t getReqMagLv() const { return reqMagLevel; }
	bool isPremium() const { return premium; }
	std::string_view getVocationString() const { return vocationString; }
	void setVocationString(std::string_view str) { vocationString = str; }
	uint32_t getWieldInfo() const { return wieldInfo; }
	const auto& getVocationEquipSet() const { return vocationEquipSet; }
	void addVocationEquipSet(std::string_view vocationName)
	{
		if (auto vocationId = g_vocations.getVocationId(vocationName)) {
			vocationEquipSet.insert(vocationId.value());
		}
	}
	bool hasVocationEquipSet(uint16_t vocationId) const
	{
		return vocationEquipSet.empty() || vocationEquipSet.contains(vocationId);
	}

	bool getTileItem() const { return tileItem; }
	void setTileItem(bool b) { tileItem = b; }

	auto stealItemIdRange()
	{
		std::vector<uint16_t> ret{};
		std::swap(itemIdRange, ret);
		return ret;
	}
	void addItemId(uint16_t id) { itemIdRange.emplace_back(id); }

	auto stealActionIdRange()
	{
		std::vector<uint16_t> ret{};
		std::swap(actionIdRange, ret);
		return ret;
	}
	void clearActionIdRange() { actionIdRange.clear(); }
	void addActionId(uint16_t id) { actionIdRange.emplace_back(id); }

	auto stealUniqueIdRange()
	{
		std::vector<uint16_t> ret{};
		std::swap(uniqueIdRange, ret);
		return ret;
	}
	void clearUniqueIdRange() { uniqueIdRange.clear(); }
	void addUniqueId(uint16_t id) { uniqueIdRange.emplace_back(id); }

	auto stealPosList()
	{
		std::vector<Position> ret{};
		std::swap(posList, ret);
		return ret;
	}
	void clearPosList() { posList.clear(); }
	void addPosList(const Position& pos) { posList.emplace_back(pos); }

	void setSlot(uint32_t s) { slot = s; }
	uint32_t getRequiredLevel() { return reqLevel; }
	void setRequiredLevel(uint32_t level) { reqLevel = level; }
	uint32_t getRequiredMagLevel() { return reqMagLevel; }
	void setRequiredMagLevel(uint32_t level) { reqMagLevel = level; }
	bool needPremium() { return premium; }
	void setNeedPremium(bool b) { premium = b; }
	uint32_t getWieldInfo() { return wieldInfo; }
	void setWieldInfo(WieldInfo_t info) { wieldInfo |= info; }

	static uint32_t StepInField(Creature* creature, Item* item, const Position& pos);
	static uint32_t StepOutField(Creature* creature, Item* item, const Position& pos);

	static uint32_t AddItemField(Item* item, Item* tileItem, const Position& pos);
	static uint32_t RemoveItemField(Item* item, Item* tileItem, const Position& pos);

	static ReturnValue EquipItem(MoveEvent* moveEvent, Player* player, Item* item, slots_t slot, bool isCheck);
	static ReturnValue DeEquipItem(MoveEvent* moveEvent, Player* player, Item* item, slots_t slot, bool);

	MoveEvent_t eventType = MOVE_EVENT_NONE;
	StepFunction stepFunction;
	MoveFunction moveFunction;
	EquipFunction equipFunction;

private:
	std::string_view getScriptEventName() const override;

	uint32_t slot = SLOTP_WHEREEVER;

	// onEquip information
	uint32_t reqLevel = 0;
	uint32_t reqMagLevel = 0;
	bool premium = false;
	std::string vocationString;
	uint32_t wieldInfo = 0;
	std::unordered_set<uint16_t> vocationEquipSet;
	bool tileItem = false;

	std::vector<uint16_t> itemIdRange;
	std::vector<uint16_t> actionIdRange;
	std::vector<uint16_t> uniqueIdRange;
	std::vector<Position> posList;
};

#endif
