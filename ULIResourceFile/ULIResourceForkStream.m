//
//  ULIResourceForkStream.m
//  ULIResourceForkReader
//
//  Created by Uli Kusterer on 03.05.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

#import "ULIResourceForkStream.h"
#import "ULIStream_Private.h"
#import <sys/xattr.h>


@implementation ULIInputStream (ULIResourceForkStream)

+ (nullable instancetype)inputStreamForResourceForkWithURL: (NSURL *)url
{
	if( ![url isFileURL] )
		return nil;
	
	NSString * path = [url path];
	size_t		dataSize = getxattr( [path fileSystemRepresentation], "com.apple.ResourceFork",
										NULL, ULONG_MAX, 0, 0 );
	if( dataSize == ULONG_MAX )
		return nil;
	NSMutableData*	data = [NSMutableData dataWithLength: dataSize];
	getxattr( [path fileSystemRepresentation], "com.apple.ResourceFork",
				[data mutableBytes], [data length], 0, 0 );
		
	return [ULIInputStream inputStreamWithData: data];
}

@end
