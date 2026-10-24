/*
* Copyright (C) fastman92 <fastman92@gmail.com>, website: http://fastman92.com
* Licensed under the MIT License, see LICENSE at top level directory.
*
*/

#pragma once
#include "../Assertions.h"
#include <stdint.h>

#define IMG_MAX_FILENAME_LENGTH 39

namespace IMG_structure
{
	// IMG archive version 2	
	struct tImgVersion2directoryEntry
	{
		uint32_t PositionInSectors;				// In blocks
		uint16_t PackedSizeInSectors;	// In blocks
		uint16_t SizeFirstPriorityInSectors;		// In blocks
		char Name[24];				// NULL terminated
	};

	VALIDATE_SIZE(tImgVersion2directoryEntry, 0x20);

	//////////////////////////////////////////////////
	// IMG archive version fastman92_GTASA

	struct tImgFastman92GTASAfirstHeader
	{
		uint32_t magicID;	// VERF
		uint32_t archiveFlags;
		char authorName[12];	// constant value "fastman92" padded with zeros.
	};

	VALIDATE_SIZE(tImgFastman92GTASAfirstHeader, 0x14);

	struct tImgFastman92GTASAsecondHeader
	{
		uint32_t Check;	// constant value 1, after decryption it should have value 1. To check if decryption worked properly.
		uint32_t NumberOfEntries;

		char reserved[8];	// for future use, should be NULL now.
	};

	VALIDATE_SIZE(tImgFastman92GTASAsecondHeader, 16);

	#define IMG_FASTMAN92_GTASA_MAX_FILENAME_LENGTH 39

	class tImgFastman92GTASAdirectoryEntry
	{
	public:
		uint32_t PositionInSectors;
		uint16_t OriginalSizeInSectors;
		uint16_t NumberOfPaddedBytesInAlignedOriginalSize;
		uint16_t PackedSizeInSectors;
		uint16_t NumberOfPaddedBytesInAlignedPackedSize;
		uint32_t Flags;	// bits 0-3, compression type, bits 4-7, encryption type
		char Name[IMG_FASTMAN92_GTASA_MAX_FILENAME_LENGTH + 1];
		char Reserved[8];	// should have NULL values when reserved.
	};

	VALIDATE_SIZE(tImgFastman92GTASAdirectoryEntry, 64);

	static_assert(
		sizeof(tImgFastman92GTASAdirectoryEntry) % 16 == 0,
		"It's best if sizeof(tImgFastman92GTASAdirectoryEntry) is multiply of 16"
		);

	//////////////////////////////////////////////////
	// IMG archive version 3
	struct tImgVersion3Header		// size: 20 bytes
	{
		uint32_t MagicID;
		uint32_t Version;				// always should be 3
		uint32_t NumberOfItems;
		uint32_t TableOfItemsSize;
		uint16_t SingleTableItemSize;	// should be 0x10 (16)
		uint16_t Unknown;
	};

	VALIDATE_SIZE(tImgVersion3Header, 0x14);

	struct tImgVersion3directoryEntry		// size: 20 bytes
	{
		union
		{
			uint32_t ResourceFlags;
			uint32_t OriginalSizeInBytes;
		};

		uint32_t ResourceType;
		uint32_t PositionInSectors;		// in blocks
		uint16_t PackedSizeInSectors;
		uint16_t NumberOfPaddedBytesInAlignedOriginalSize;
	};

	VALIDATE_SIZE(tImgVersion3directoryEntry, 0x10);
}