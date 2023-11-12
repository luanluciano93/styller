// Copyright 2023 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#include "otpch.h"

#include "party.h"

#include "configmanager.h"
#include "events.h"
#include "game.h"

#include <fmt/format.h>

extern Game g_game;
extern ConfigManager g_config;
extern Events* g_events;

Party::Party(Player* leader) : leader(leader) { leader->setParty(this); }

void Party::disband()
{
	if (!g_events->eventPartyOnDisband(this)) {
		return;
	}

	Player* currentLeader = leader;
	leader = nullptr;

	currentLeader->setParty(nullptr);
	currentLeader->sendClosePrivate(CHANNEL_PARTY);
	g_game.updatePlayerShield(currentLeader);
	currentLeader->sendCreatureSkull(currentLeader);
	currentLeader->sendTextMessage(MESSAGE_INFO_DESCR, "Your party has been disbanded.");

	for (Player* invitee : inviteList) {
		invitee->removePartyInvitation(this);
		currentLeader->sendCreatureShield(invitee);
	}
	inviteList.clear();

	for (Player* member : memberList) {
		member->setParty(nullptr);
		member->sendClosePrivate(CHANNEL_PARTY);
		member->sendTextMessage(MESSAGE_INFO_DESCR, "Your party has been disbanded.");
	}

	for (Player* member : memberList) {
		g_game.updatePlayerShield(member);

		for (Player* otherMember : memberList) {
			otherMember->sendCreatureSkull(member);
		}

		member->sendCreatureSkull(currentLeader);
		currentLeader->sendCreatureSkull(member);
	}
	memberList.clear();
	delete this;
}

bool Party::leaveParty(Player* player, bool forceRemove /* = false */)
{
	if (!player) {
		return false;
	}

	if (player->getParty() != this && leader != player) {
		return false;
	}

	bool canRemove = g_events->eventPartyOnLeave(this, player);
	if (!forceRemove && !canRemove) {
		return false;
	}

	bool missingLeader = false;
	if (leader == player) {
		if (!memberList.empty()) {
			if (memberList.size() == 1 && inviteList.empty()) {
				missingLeader = true;
			} else {
				passPartyLeadership(memberList.front(), true);
			}
		} else {
			missingLeader = true;
		}
	}

	// since we already passed the leadership, we remove the player from the list
	auto it = std::find(memberList.begin(), memberList.end(), player);
	if (it != memberList.end()) {
		memberList.erase(it);
	}

	player->setParty(nullptr);
	player->sendClosePrivate(CHANNEL_PARTY);
	g_game.updatePlayerShield(player);

	for (Player* member : memberList) {
		member->sendCreatureSkull(player);
		player->sendPlayerPartyIcons(member);
	}

	leader->sendCreatureSkull(player);
	player->sendCreatureSkull(player);
	player->sendPlayerPartyIcons(leader);

	player->sendTextMessage(MESSAGE_INFO_DESCR, "You have left the party.");

	updateSharedExperience();

	clearPlayerPoints(player);

	broadcastPartyMessage(MESSAGE_INFO_DESCR, fmt::format("{:s} has left the party.", player->getName()));

	if (missingLeader || empty()) {
		disband();
	}

	return true;
}

bool Party::passPartyLeadership(Player* player, bool forceRemove /* = false*/)
{
	if (!player || leader == player || player->getParty() != this) {
		return false;
	}

	if (!g_events->eventPartyOnPassLeadership(this, player) && !forceRemove) {
		return false;
	}

	// Remove it before to broadcast the message correctly
	auto it = std::find(memberList.begin(), memberList.end(), player);
	if (it != memberList.end()) {
		memberList.erase(it);
	}

	broadcastPartyMessage(MESSAGE_INFO_DESCR, fmt::format("{:s} is now the leader of the party.", player->getName()),
	                      true);

	Player* oldLeader = leader;
	leader = player;

	memberList.insert(memberList.begin(), oldLeader);

	updateSharedExperience();

	for (Player* member : memberList) {
		member->sendCreatureShield(oldLeader);
		member->sendCreatureShield(leader);
	}

	for (Player* invitee : inviteList) {
		invitee->sendCreatureShield(oldLeader);
		invitee->sendCreatureShield(leader);
	}

	leader->sendCreatureShield(oldLeader);
	leader->sendCreatureShield(leader);

	player->sendTextMessage(MESSAGE_INFO_DESCR, "You are now the leader of the party.");
	return true;
}

bool Party::joinParty(Player& player)
{
	if (!g_events->eventPartyOnJoin(this, &player)) {
		return false;
	}

	auto it = std::find(inviteList.begin(), inviteList.end(), &player);
	if (it == inviteList.end()) {
		return false;
	}

	inviteList.erase(it);

	broadcastPartyMessage(MESSAGE_INFO_DESCR, fmt::format("{:s} has joined the party.", player.getName()));

	player.setParty(this);

	g_game.updatePlayerShield(&player);

	for (Player* member : memberList) {
		member->sendCreatureSkull(&player);
		player.sendPlayerPartyIcons(member);
	}

	player.sendCreatureSkull(&player);
	leader->sendCreatureSkull(&player);
	player.sendPlayerPartyIcons(leader);

	memberList.push_back(&player);

	player.removePartyInvitation(this);
	updateSharedExperience();

	const std::string& leaderName = leader->getName();
	player.sendTextMessage(
	    MESSAGE_INFO_DESCR,
	    fmt::format("You have joined {:s}'{:s} party. Open the party channel to communicate with your companions.",
	                leaderName, leaderName.back() == 's' ? "" : "s"));
	return true;
}

bool Party::removeInvite(Player& player, bool removeFromPlayer /* = true*/)
{
	auto it = std::find(inviteList.begin(), inviteList.end(), &player);
	if (it == inviteList.end()) {
		return false;
	}

	inviteList.erase(it);

	leader->sendCreatureShield(&player);
	player.sendCreatureShield(leader);

	if (removeFromPlayer) {
		player.removePartyInvitation(this);
	}

	if (empty()) {
		disband();
	}

	return true;
}

void Party::revokeInvitation(Player& player)
{
	if (!g_events->eventPartyOnRevokeInvitation(this, &player)) {
		return;
	}

	player.sendTextMessage(MESSAGE_INFO_DESCR, fmt::format("{:s} has revoked {:s} invitation.", leader->getName(),
	                                                       leader->getSex() == PLAYERSEX_FEMALE ? "her" : "his"));
	leader->sendTextMessage(MESSAGE_INFO_DESCR, fmt::format("Invitation for {:s} has been revoked.", player.getName()));
	removeInvite(player);
}

bool Party::invitePlayer(Player& player)
{
	if (isPlayerInvited(&player)) {
		return false;
	}

	if (empty()) {
		leader->sendTextMessage(
		    MESSAGE_INFO_DESCR,
		    fmt::format("{:s} has been invited. Open the party channel to communicate with your members.",
		                player.getName()));
		g_game.updatePlayerShield(leader);
		leader->sendCreatureSkull(leader);
	} else {
		leader->sendTextMessage(MESSAGE_INFO_DESCR, fmt::format("{:s} has been invited.", player.getName()));
	}

	inviteList.push_back(&player);

	leader->sendCreatureShield(&player);
	player.sendCreatureShield(leader);

	player.addPartyInvitation(this);

	player.sendTextMessage(MESSAGE_INFO_DESCR, fmt::format("{:s} has invited you to {:s} party.", leader->getName(),
	                                                       leader->getSex() == PLAYERSEX_FEMALE ? "her" : "his"));
	return true;
}

bool Party::isPlayerInvited(const Player* player) const
{
	return std::find(inviteList.begin(), inviteList.end(), player) != inviteList.end();
}

void Party::updateAllPartyIcons()
{
	for (Player* member : memberList) {
		for (Player* otherMember : memberList) {
			member->sendCreatureShield(otherMember);
		}

		member->sendCreatureShield(leader);
		leader->sendCreatureShield(member);
	}
	leader->sendCreatureShield(leader);
}

void Party::broadcastPartyMessage(MessageClasses msgClass, std::string_view msg, bool sendToInvitations /*= false*/)
{
	for (Player* member : memberList) {
		member->sendTextMessage(msgClass, msg);
	}

	leader->sendTextMessage(msgClass, msg);

	if (sendToInvitations) {
		for (Player* invitee : inviteList) {
			invitee->sendTextMessage(msgClass, msg);
		}
	}
}

void Party::updateSharedExperience()
{
	if (sharedExpActive) {
		bool result = canEnableSharedExperience();
		if (result != sharedExpEnabled) {
			sharedExpEnabled = result;
			updateAllPartyIcons();
		}
	}
}

bool Party::setSharedExperience(Player* player, bool sharedExpActive)
{
	if (!player || leader != player) {
		return false;
	}

	if (this->sharedExpActive == sharedExpActive) {
		return true;
	}

	this->sharedExpActive = sharedExpActive;

	if (sharedExpActive) {
		this->sharedExpEnabled = canEnableSharedExperience();

		if (this->sharedExpEnabled) {
			leader->sendTextMessage(MESSAGE_INFO_DESCR, "Shared Experience is now active.");
		} else {
			leader->sendTextMessage(
			    MESSAGE_INFO_DESCR,
			    "Shared Experience has been activated, but some members of your party are inactive.");
		}
	} else {
		leader->sendTextMessage(MESSAGE_INFO_DESCR, "Shared Experience has been deactivated.");
	}

	updateAllPartyIcons();
	return true;
}

void Party::shareExperience(uint64_t experience, Creature* source /* = nullptr*/)
{
	uint64_t shareExperience = experience;
	g_events->eventPartyOnShareExperience(this, shareExperience);

	for (Player* member : memberList) {
		member->onGainSharedExperience(shareExperience, source);
	}
	leader->onGainSharedExperience(shareExperience, source);
}

bool Party::canUseSharedExperience(const Player* player) const
{
	if (memberList.empty()) {
		return false;
	}

	uint32_t highestLevel = leader->getLevel();
	for (Player* member : memberList) {
		if (member->getLevel() > highestLevel) {
			highestLevel = member->getLevel();
		}
	}

	uint32_t minLevel = static_cast<uint32_t>(std::ceil((static_cast<float>(highestLevel) * 2) / 3));
	if (player->getLevel() < minLevel) {
		return false;
	}

	if (!Position::areInRange<EXPERIENCE_SHARE_RANGE, EXPERIENCE_SHARE_RANGE, EXPERIENCE_SHARE_FLOORS>(
	        leader->getPosition(), player->getPosition())) {
		return false;
	}

	if (!player->hasFlag(PlayerFlag_NotGainInFight)) {
		// check if the player has healed/attacked anything recently
		auto it = ticksMap.find(player->getID());
		if (it == ticksMap.end()) {
			return false;
		}

		uint64_t timeDiff = OTSYS_TIME() - it->second;
		if (timeDiff > static_cast<uint64_t>(g_config[ConfigKeysInteger::PZ_LOCKED])) {
			return false;
		}
	}
	return true;
}

bool Party::canEnableSharedExperience()
{
	if (!canUseSharedExperience(leader)) {
		return false;
	}

	for (Player* member : memberList) {
		if (!canUseSharedExperience(member)) {
			return false;
		}
	}
	return true;
}

void Party::updatePlayerTicks(Player* player, uint32_t points)
{
	if (points != 0 && !player->hasFlag(PlayerFlag_NotGainInFight)) {
		ticksMap[player->getID()] = OTSYS_TIME();
		updateSharedExperience();
	}
}

void Party::clearPlayerPoints(Player* player)
{
	auto it = ticksMap.find(player->getID());
	if (it != ticksMap.end()) {
		ticksMap.erase(it);
		updateSharedExperience();
	}
}

bool Party::canOpenCorpse(uint32_t ownerId) const
{
	if (Player* player = g_game.getPlayerByID(ownerId)) {
		return leader->getID() == ownerId || player->getParty() == this;
	}
	return false;
}
