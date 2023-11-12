// Copyright 2023 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#ifndef FS_PARTY_H
#define FS_PARTY_H

#include "monsters.h"
#include "player.h"

class Player;
class Party;

using PlayerVector = std::vector<Player*>;

inline constexpr int32_t EXPERIENCE_SHARE_RANGE = 30;
inline constexpr int32_t EXPERIENCE_SHARE_FLOORS = 1;

class Party
{
public:
	explicit Party(Player* leader);

	Player* getLeader() const { return leader; }
	PlayerVector& getMembers() { return memberList; }
	const PlayerVector& getInvitees() const { return inviteList; }
	size_t getMemberCount() const { return memberList.size(); }
	size_t getInvitationCount() const { return inviteList.size(); }

	void disband();
	bool invitePlayer(Player& player);
	bool joinParty(Player& player);
	void revokeInvitation(Player& player);
	bool passPartyLeadership(Player* player, bool forceRemove = false);
	bool leaveParty(Player* player, bool forceRemove = false);

	bool removeInvite(Player& player, bool removeFromPlayer = true);

	bool isPlayerInvited(const Player* player) const;
	void updateAllPartyIcons();
	void broadcastPartyMessage(MessageClasses msgClass, std::string_view msg, bool sendToInvitations = false);
	bool empty() const { return memberList.empty() && inviteList.empty(); }
	bool canOpenCorpse(uint32_t ownerId) const;

	void shareExperience(uint64_t experience, Creature* source = nullptr);
	bool setSharedExperience(Player* player, bool sharedExpActive);
	bool isSharedExperienceActive() const { return sharedExpActive; }
	bool isSharedExperienceEnabled() const { return sharedExpEnabled; }
	bool canUseSharedExperience(const Player* player) const;
	void updateSharedExperience();

	void updatePlayerTicks(Player* player, uint32_t points);
	void clearPlayerPoints(Player* player);

private:
	bool canEnableSharedExperience();

	std::map<uint32_t, int64_t> ticksMap;

	PlayerVector memberList;
	PlayerVector inviteList;

	Player* leader;

	bool sharedExpActive = false;
	bool sharedExpEnabled = false;
};

#endif
