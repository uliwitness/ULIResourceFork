//
//  ULIStream_Private.h
//  ULIResourceForkReader
//
//  Created by Uli Kusterer on 03.05.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

#import "ULIStream.h"


NS_ASSUME_NONNULL_BEGIN


@interface ULIFileInputStream : ULIInputStream
{
	FILE * _fileRecord;
}

- (nullable instancetype)	initWithURL: (NSURL*)inURL;

@end


@interface ULIDataInputStream : ULIInputStream
{
	NSUInteger _offsetInStream;
}

@property NSData * data;

- (nullable instancetype)	initWithData: (NSData*)inData;

@end


NS_ASSUME_NONNULL_END
