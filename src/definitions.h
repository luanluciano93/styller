// Copyright 2023 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#ifndef FS_DEFINITIONS_H
#define FS_DEFINITIONS_H

inline constexpr auto STATUS_SERVER_NAME = "TFS Nekiro Downgrade";
inline constexpr auto STATUS_SERVER_VERSION = "1.5+";
inline constexpr auto STATUS_SERVER_DEVELOPERS = "Mark Samman";
inline constexpr auto STATUS_SERVER_REPOSITORY = "https://github.com/MillhioreBT/forgottenserver-downgrade";

inline constexpr auto CLIENT_VERSION_MIN = 860;
inline constexpr auto CLIENT_VERSION_MAX = 860;
inline constexpr auto CLIENT_VERSION_STR = "8.60";

inline constexpr unsigned int AUTHENTICATOR_DIGITS = 6;
inline constexpr unsigned int AUTHENTICATOR_PERIOD = 30;

#ifndef __FUNCTION__
#define __FUNCTION__ __func__
#endif

#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif

#ifndef _USE_MATH_DEFINES
#define _USE_MATH_DEFINES
#endif

#include <cmath>

#ifdef _WIN32
#ifndef NOMINMAX
#define NOMINMAX
#endif

#define WIN32_LEAN_AND_MEAN

#ifdef _MSC_VER
#ifdef NDEBUG
#define _SECURE_SCL 0
#define HAS_ITERATOR_DEBUGGING 0
#endif

#pragma warning(disable : 4127) // conditional expression is constant
#pragma warning(disable : 4244) // 'argument' : conversion from 'type1' to 'type2', possible loss of data
#pragma warning(disable : 4250) // 'class1' : inherits 'class2::member' via dominance
#pragma warning(disable : 4267) // 'var' : conversion from 'size_t' to 'type', possible loss of data
#pragma warning(disable : 4275) // can be ignored in Visual C++ if you are deriving from a type in the C++ STL
#pragma warning(disable : 4319) // '~': zero extending 'unsigned int' to 'lua_Number' of greater size
#pragma warning(disable : 4351) // new behavior: elements of array will be default initialized
#pragma warning(disable : 4458) // declaration hides class member
#pragma warning(disable : 4996) // gethostbyname is deprecated
#endif

#ifndef _WIN32_WINNT
// 0x0602: Windows 7
#define _WIN32_WINNT 0x0602
#endif
#endif

#endif
