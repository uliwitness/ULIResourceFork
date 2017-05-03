//
//  ULIStream.h
//  ULIResourceForkReader
//
//  Created by Uli Kusterer on 03.05.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

/*
	Like NSStream or NSFileHandle, but you can seek in it, and it
	may refer to either a file or a block of memory.
*/

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@interface ULIStream : NSObject

- (void)open;
- (void)close;

- (NSUInteger)	offsetInStream;
- (BOOL)		setOffsetInStream: (NSUInteger)inOffset;

@end


@interface ULIInputStream : ULIStream

+ (nullable instancetype)inputStreamWithData: (NSData *)data;
+ (nullable instancetype)inputStreamWithURL: (NSURL *)url;

- (NSUInteger)	read: (uint8_t *)buffer maxLength: (NSUInteger)len;
- (NSData*)		readDataOfLength: (NSUInteger)len;

@end


NS_ASSUME_NONNULL_END
