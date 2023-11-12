// Copyright 2023 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#ifndef FS_OUTPUTMESSAGE_H
#define FS_OUTPUTMESSAGE_H

#include "connection.h"
#include "networkmessage.h"
#include "tools.h"

class OutputMessage : public NetworkMessage
{
public:
	OutputMessage() = default;

	// non-copyable
	OutputMessage(const OutputMessage&) = delete;
	OutputMessage& operator=(const OutputMessage&) = delete;

	uint8_t* getOutputBuffer() { return &buffer[outputBufferStart]; }

	void writeMessageLength() { add_header(info.length); }

	void addCryptoHeader(const bool addChecksum)
	{
		if (addChecksum) {
			add_header(adlerChecksum(&buffer[outputBufferStart], info.length));
		}

		writeMessageLength();
	}

	void append(const NetworkMessage& msg)
	{
		auto msgLen = msg.getLength();
		std::memcpy(buffer.data() + info.position, msg.getBuffer() + 8, msgLen);
		info.length += msgLen;
		info.position += msgLen;
	}

	void append(const OutputMessage_ptr& msg)
	{
		auto msgLen = msg->getLength();
		std::memcpy(buffer.data() + info.position, msg->getBuffer() + 8, msgLen);
		info.length += msgLen;
		info.position += msgLen;
	}

private:
	template <typename T>
	void add_header(T add)
	{
		assert(outputBufferStart >= sizeof(T));
		outputBufferStart -= sizeof(T);
		std::memcpy(buffer.data() + outputBufferStart, &add, sizeof(T));
		// added header size to the message size
		info.length += sizeof(T);
	}

	MsgSize_t outputBufferStart = INITIAL_BUFFER_POSITION;
};

class OutputMessagePool
{
public:
	// non-copyable
	OutputMessagePool(const OutputMessagePool&) = delete;
	OutputMessagePool& operator=(const OutputMessagePool&) = delete;

	static OutputMessagePool& getInstance()
	{
		static OutputMessagePool instance;
		return instance;
	}

	static OutputMessage_ptr getOutputMessage();

	void addProtocolToAutosend(Protocol_ptr protocol);
	void removeProtocolFromAutosend(const Protocol_ptr& protocol);

private:
	OutputMessagePool() = default;
	// NOTE: A vector is used here because this container is mostly read and relatively rarely modified (only when a
	// client connects/disconnects)
	std::vector<Protocol_ptr> bufferedProtocols;
};

#endif // FS_OUTPUTMESSAGE_H
