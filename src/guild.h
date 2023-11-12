// Copyright 2023 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#ifndef FS_GUILD_H
#define FS_GUILD_H

class Player;

struct GuildRank
{
	uint32_t id;
	std::string name;
	uint8_t level;

	GuildRank(uint32_t id, std::string_view name, uint8_t level) : id{id}, name{name}, level{level} {}
};

using GuildRank_ptr = std::shared_ptr<GuildRank>;

class Guild
{
public:
	Guild(uint32_t id, std::string_view name) : name{name}, id{id} {}

	void addMember(Player* player);
	void removeMember(Player* player);

	uint32_t getId() const { return id; }
	const std::string& getName() const { return name; }
	const std::list<Player*>& getMembersOnline() const { return membersOnline; }
	uint32_t getMemberCount() const { return memberCount; }
	void setMemberCount(uint32_t count) { memberCount = count; }

	const std::vector<GuildRank_ptr>& getRanks() const { return ranks; }
	GuildRank_ptr getRankById(uint32_t rankId) const;
	GuildRank_ptr getRankByName(std::string_view name) const;
	GuildRank_ptr getRankByLevel(uint8_t level) const;
	void addRank(uint32_t rankId, std::string_view rankName, uint8_t level);

	const std::string& getMotd() const { return motd; }
	void setMotd(std::string_view motd) { this->motd = motd; }

private:
	std::list<Player*> membersOnline;
	std::vector<GuildRank_ptr> ranks;
	std::string name;
	std::string motd;
	uint32_t id;
	uint32_t memberCount = 0;
};

using GuildWarVector = std::vector<uint32_t>;

namespace IOGuild {
Guild* loadGuild(uint32_t guildId);
uint32_t getGuildIdByName(std::string_view name);
} // namespace IOGuild

#endif
