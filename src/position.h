// Copyright 2023 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#ifndef FS_POSITION_H
#define FS_POSITION_H

enum Direction : uint8_t
{
	DIRECTION_NORTH = 0,
	DIRECTION_EAST = 1,
	DIRECTION_SOUTH = 2,
	DIRECTION_WEST = 3,

	DIRECTION_DIAGONAL_MASK = 4,
	DIRECTION_SOUTHWEST = DIRECTION_DIAGONAL_MASK | 0,
	DIRECTION_SOUTHEAST = DIRECTION_DIAGONAL_MASK | 1,
	DIRECTION_NORTHWEST = DIRECTION_DIAGONAL_MASK | 2,
	DIRECTION_NORTHEAST = DIRECTION_DIAGONAL_MASK | 3,

	DIRECTION_LAST = DIRECTION_NORTHEAST,
	DIRECTION_NONE = 8,
};

struct Position
{
	constexpr Position() = default;
	constexpr Position(uint16_t x, uint16_t y, uint8_t z) : x(x), y(y), z(z) {}

	template <int_fast32_t deltax, int_fast32_t deltay>
	static bool areInRange(const Position& p1, const Position& p2)
	{
		return Position::getDistanceX(p1, p2) <= deltax && Position::getDistanceY(p1, p2) <= deltay;
	}

	template <int_fast32_t deltax, int_fast32_t deltay, int_fast16_t deltaz>
	static bool areInRange(const Position& p1, const Position& p2)
	{
		return Position::getDistanceX(p1, p2) <= deltax && Position::getDistanceY(p1, p2) <= deltay &&
		       Position::getDistanceZ(p1, p2) <= deltaz;
	}

	static bool areInRange(const Position& p1, const Position& p2, int_fast32_t deltax, int_fast32_t deltay)
	{
		return Position::getDistanceX(p1, p2) <= deltax && Position::getDistanceY(p1, p2) <= deltay;
	}

	static int_fast32_t getOffsetX(const Position& p1, const Position& p2) { return p1.getX() - p2.getX(); }
	static int_fast32_t getOffsetY(const Position& p1, const Position& p2) { return p1.getY() - p2.getY(); }
	static int_fast16_t getOffsetZ(const Position& p1, const Position& p2) { return p1.getZ() - p2.getZ(); }

	static int32_t getDistanceX(const Position& p1, const Position& p2)
	{
		return std::abs(Position::getOffsetX(p1, p2));
	}
	static int32_t getDistanceY(const Position& p1, const Position& p2)
	{
		return std::abs(Position::getOffsetY(p1, p2));
	}
	static int16_t getDistanceZ(const Position& p1, const Position& p2)
	{
		return std::abs(Position::getOffsetZ(p1, p2));
	}

	uint16_t x = 0;
	uint16_t y = 0;
	uint8_t z = 0;

	bool operator<(const Position& p) const
	{
		if (z < p.z) {
			return true;
		}

		if (z > p.z) {
			return false;
		}

		if (y < p.y) {
			return true;
		}

		if (y > p.y) {
			return false;
		}

		if (x < p.x) {
			return true;
		}

		if (x > p.x) {
			return false;
		}

		return false;
	}

	bool operator>(const Position& p) const { return !(*this < p); }

	bool operator==(const Position& p) const { return p.x == x && p.y == y && p.z == z; }

	bool operator!=(const Position& p) const { return p.x != x || p.y != y || p.z != z; }

	Position operator+(const Position& p1) const { return Position(x + p1.x, y + p1.y, z + p1.z); }

	Position operator-(const Position& p1) const { return Position(x - p1.x, y - p1.y, z - p1.z); }

	int_fast32_t getX() const { return x; }
	int_fast32_t getY() const { return y; }
	int_fast16_t getZ() const { return z; }
};

std::ostream& operator<<(std::ostream&, const Position&);
std::ostream& operator<<(std::ostream&, const Direction&);

#endif
