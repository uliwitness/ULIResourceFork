//
//  ULIResourceFork.m
//  ULIResourceForkReader
//
//  Created by Uli Kusterer on 03.05.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

#import "ULIResourceFork.h"


NSString * ULIResourceForkErrorDomain = @"ULIResourceForkErrorDomain";


// Resource attribute bit flags:
enum
{
	// Bit 0 is reserved.
	ULIResourceAttributeIsChanged					= (1 << 1),
	ULIResourceAttributeShouldBePreloaded			= (1 << 2),
	ULIResourceAttributeIsProtected					= (1 << 3),
	ULIResourceAttributeIsLocked					= (1 << 4),
	ULIResourceAttributeIsPurgeable					= (1 << 5),
	ULIResourceAttributeShouldBeLoadedInSystemHeap	= (1 << 6)
	// Bit 7 is reserved.
};



@implementation ULIResourceFork

+(instancetype) resourceForkFromStream: (ULIInputStream*)inStream error: (NSError**)outError
{
	ULIResourceFork* theFork = [[self alloc] init];
	[theFork readFromStream: inStream error: outError];
	if( *outError != nil )
		return nil;
	return theFork;
}


-(uint32_t)	readUIntFromStream: (ULIInputStream*)inStream error: (NSError**)outError
{
	uint32_t resourceDataOffset = 0;
	if( [inStream read: (uint8_t*)&resourceDataOffset maxLength: sizeof(resourceDataOffset)] != sizeof(resourceDataOffset) )
	{
		*outError = [NSError errorWithDomain: ULIResourceForkErrorDomain code: ULIResourceForkPrematureEndOfFileError userInfo: @{ NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat: @"Couldn't read 4 bytes from offset %lu.", (unsigned long)inStream.offsetInStream] }];
		return 0;
	}
	resourceDataOffset = NSSwapBigIntToHost(resourceDataOffset);
	return resourceDataOffset;
}


-(uint16_t)	readUShortFromStream: (ULIInputStream*)inStream error: (NSError**)outError
{
	uint16_t resourceDataOffset = 0;
	if( [inStream read: (uint8_t*)&resourceDataOffset maxLength: sizeof(resourceDataOffset)] != sizeof(resourceDataOffset) )
	{
		*outError = [NSError errorWithDomain: ULIResourceForkErrorDomain code: ULIResourceForkPrematureEndOfFileError userInfo: @{ NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat: @"Couldn't read 2 bytes from offset %lu.", (unsigned long)inStream.offsetInStream] }];
		return 0;
	}
	resourceDataOffset = NSSwapBigShortToHost(resourceDataOffset);
	return resourceDataOffset;
}


-(void)	readFromStream: (ULIInputStream*)inStream error: (NSError**)outError
{
	uint32_t resourceDataOffset = [self readUIntFromStream: inStream error: outError];
	if( *outError != nil )
		return;
	uint32_t resourceMapOffset = [self readUIntFromStream: inStream error: outError];
	if( *outError != nil )
		return;
	uint32_t lengthOfResourceData = [self readUIntFromStream: inStream error: outError];
	#pragma unused(lengthOfResourceData)
	if( *outError != nil )
		return;
	uint32_t lengthOfResourceMap = [self readUIntFromStream: inStream error: outError];
	#pragma unused(lengthOfResourceMap)
	if( *outError != nil )
		return;
	[inStream setOffsetInStream: inStream.offsetInStream +112ULL];	// Skip system data.
	[inStream setOffsetInStream: inStream.offsetInStream +128ULL];	// Skip application data.
	
	[inStream setOffsetInStream: resourceMapOffset];
	[inStream setOffsetInStream: inStream.offsetInStream +16ULL];		// Skip resource file header copy.
	[inStream setOffsetInStream: inStream.offsetInStream +4ULL];		// Skip next resource map placeholder.
	[inStream setOffsetInStream: inStream.offsetInStream +2ULL];		// Skip file ref num placeholder.
	uint16_t resFileAttributes = [self readUShortFromStream: inStream error: outError];
	#pragma unused(resFileAttributes)
	if( *outError != nil )
		return;
	
	uint16_t typeListOffset = [self readUShortFromStream: inStream error: outError];
	if( *outError != nil )
		return;
	uint16_t nameListOffset = [self readUShortFromStream: inStream error: outError];
	if( *outError != nil )
		return;
	
	NSUInteger typeListSeekPos = (NSUInteger)resourceMapOffset + (NSUInteger)typeListOffset;
	[inStream setOffsetInStream: typeListSeekPos];

	uint16_t numTypes = [self readUShortFromStream: inStream error: outError];
	if( *outError != nil )
		return;
	
	NSMutableDictionary<NSString*,ULIResourceType*>* types = [NSMutableDictionary dictionaryWithCapacity: numTypes +1];
	for( int x = 0; x < ((int)numTypes +1); x++ )
	{
		uint32_t currType = 0;
		if( [inStream read: (uint8_t*)&currType maxLength: sizeof(currType)] != sizeof(currType) )
		{
			*outError = [NSError errorWithDomain: ULIResourceForkErrorDomain code: ULIResourceForkPrematureEndOfFileError userInfo: @{}];
			return;
		}
		NSString* typeStr = [[NSString alloc] initWithBytes: &currType length: 4 encoding: NSMacOSRomanStringEncoding];
		
		uint16_t numResources = [self readUShortFromStream: inStream error: outError];
		if( *outError != nil )
			return;
		uint16_t refListOffset = [self readUShortFromStream: inStream error: outError];
		if( *outError != nil )
			return;
		
		NSUInteger oldOffset = inStream.offsetInStream;
		NSUInteger refListSeekPos = (NSUInteger)typeListSeekPos +(NSUInteger)refListOffset;
		[inStream setOffsetInStream: refListSeekPos];
		
		NSMutableArray<ULIResource*>* resources = [NSMutableArray arrayWithCapacity: numResources +1];
		for( int y = 0; y < ((int)numResources +1); y++ )
		{
			int16_t resourceID = (int16_t)[self readUShortFromStream: inStream error: outError];
			if( *outError != nil )
				return;
			uint16_t nameOffset = [self readUShortFromStream: inStream error: outError];
			if( *outError != nil )
				return;

			unsigned char	attributesAndDataOffset[4];
			uint32_t		dataOffset = 0;
			if( [inStream read: attributesAndDataOffset maxLength: sizeof(attributesAndDataOffset)] != sizeof(attributesAndDataOffset) )
			{
				*outError = [NSError errorWithDomain: ULIResourceForkErrorDomain code: ULIResourceForkPrematureEndOfFileError userInfo: @{}];
				return;
			}
			uint8_t	resourceAttributes = attributesAndDataOffset[0];
			memmove( ((char*)&dataOffset) +1, attributesAndDataOffset +1, 3 );
			dataOffset = NSSwapBigIntToHost(dataOffset);

			[inStream setOffsetInStream: inStream.offsetInStream +4ULL];		// Skip resource Handle placeholder.

			NSUInteger innerOldOffset = inStream.offsetInStream;
			NSUInteger dataSeekPos = (NSUInteger)resourceDataOffset +(NSUInteger)dataOffset;
			[inStream setOffsetInStream: dataSeekPos];

			uint32_t dataLength = [self readUIntFromStream: inStream error: outError];
			if( *outError != nil )
				return;
			
			NSString * resName = @"";
			NSData* resData = [inStream readDataOfLength: dataLength];
			if( -1 != (long)nameOffset )
			{
				NSUInteger nameSeekPos = (NSUInteger)resourceMapOffset +(NSUInteger)nameListOffset +(NSUInteger)nameOffset;
				[inStream setOffsetInStream: nameSeekPos];
				
				uint8_t nameLength = 0;
				if( [inStream read: (uint8_t*)&nameLength maxLength: sizeof(nameLength)] != sizeof(nameLength) )
				{
					*outError = [NSError errorWithDomain: ULIResourceForkErrorDomain code: ULIResourceForkPrematureEndOfFileError userInfo: @{}];
					return;
				}
				if( nameLength > 0 )
				{
					char resourceNameBytes[255] = {};
					if( [inStream read: (uint8_t*)resourceNameBytes maxLength: nameLength] != nameLength )
					{
						*outError = [NSError errorWithDomain: ULIResourceForkErrorDomain code: ULIResourceForkPrematureEndOfFileError userInfo: @{}];
						return;
					}
					resName = [[NSString alloc] initWithBytes: resourceNameBytes length: nameLength encoding: NSMacOSRomanStringEncoding];
				}
			}
			[inStream setOffsetInStream: innerOldOffset];
			
			ULIResource * theResource = [[ULIResource alloc] init];
			theResource.resourceType = typeStr;
			theResource.resourceID = resourceID;
			theResource.resourceName = resName;
			theResource.resourceData = resData;
			theResource.isChanged = (resourceAttributes & ULIResourceAttributeIsChanged) != 0;
			theResource.shouldBePreloaded = (resourceAttributes & ULIResourceAttributeShouldBePreloaded) != 0;
			theResource.isProtected = (resourceAttributes & ULIResourceAttributeIsProtected) != 0;
			theResource.isLocked = (resourceAttributes & ULIResourceAttributeIsLocked) != 0;
			theResource.isPurgeable = (resourceAttributes & ULIResourceAttributeIsPurgeable) != 0;
			theResource.shouldBeLoadedInSystemHeap = (resourceAttributes & ULIResourceAttributeShouldBeLoadedInSystemHeap) != 0;
			
			[resources addObject: theResource];
		}
		
		ULIResourceType * theType = [[ULIResourceType alloc] init];
		theType.resourceType = typeStr;
		theType.resources = resources;
		[types setObject: theType forKey: typeStr];
		
		[inStream setOffsetInStream: oldOffset];
	}
	
	self.resourceTypes = types;
}

-(NSString*) description
{
	return [NSString stringWithFormat: @"<%@ %p> %@", NSStringFromClass(self.class), self, self.resourceTypes];
}

@end


@implementation ULIResource

-(NSString*) description
{
	return [NSString stringWithFormat: @"<%@ %p> { type = \"%@\", ID = %d, data = %@ }", NSStringFromClass(self.class), self, self.resourceType, self.resourceID, self.resourceData];
}

@end


@implementation ULIResourceType

-(NSString*) description
{
	return [NSString stringWithFormat: @"<%@ %p> { type = \"%@\", %@ }", NSStringFromClass(self.class), self, self.resourceType, self.resources];
}

@end

