//
//  ULIResourceFork.h
//  ULIResourceForkReader
//
//  Created by Uli Kusterer on 03.05.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ULIStream.h"


@interface ULIResource : NSObject

@property NSString* resourceType;
@property NSData* resourceData;
@property int16_t resourceID;
@property NSString* resourceName;

@property BOOL isChanged;
@property BOOL shouldBePreloaded;
@property BOOL isProtected;
@property BOOL isLocked;
@property BOOL isPurgeable;
@property BOOL shouldBeLoadedInSystemHeap;

@end


@interface ULIResourceType : NSObject

@property NSString* resourceType;
@property NSArray<ULIResource*>* resources;

@end


@interface ULIResourceFork : NSObject

@property NSDictionary<NSString*,ULIResourceType*>* resourceTypes;

+(instancetype) resourceForkFromStream: (ULIInputStream*)inStream error: (NSError**)outError;

-(void)	readFromStream: (ULIInputStream*)inStream error: (NSError**)outError;

@end


extern NSString* ULIResourceForkErrorDomain;

enum
{
	ULIResourceForkNoError = 0,
	ULIResourceForkPrematureEndOfFileError,
};
