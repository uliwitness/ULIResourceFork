//
//  ULIStream.m
//  ULIResourceForkReader
//
//  Created by Uli Kusterer on 03.05.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

#import "ULIStream.h"
#import "ULIStream_Private.h"


@implementation ULIStream

- (void)open
{

}

- (void)close
{

}

- (NSUInteger)	offsetInStream
{
	return 0;
}

- (BOOL)		setOffsetInStream: (NSUInteger)inOffset
{
	return NO;
}

@end


@implementation ULIInputStream

+ (nullable instancetype)inputStreamWithData: (NSData *)data
{
	return [[ULIDataInputStream alloc] initWithData: data];
}


+ (nullable instancetype)inputStreamWithURL: (NSURL *)url
{
	return [[ULIFileInputStream alloc] initWithURL: url];
}

- (NSUInteger)	read: (uint8_t *)buffer maxLength: (NSUInteger)len
{
	return 0;
}

- (NSData*)	readDataOfLength: (NSUInteger)len
{
	return nil;
}

@end


@implementation ULIFileInputStream

- (instancetype)	initWithURL: (NSURL*)inURL
{
	self = [super init];
	if( self )
	{
		if( ![inURL isFileURL] )
			return nil;
		NSString * thePath = [inURL path];
		_fileRecord = fopen([thePath fileSystemRepresentation],"r");
	}
	return self;
}


-(void)	dealloc
{
	if( _fileRecord )
	{
		fclose(_fileRecord);
	}
}


- (void)open
{
	
}


- (void)close
{
	if( _fileRecord )
	{
		fclose(_fileRecord);
		_fileRecord = NULL;
	}
}


- (NSUInteger)	offsetInStream
{
	fpos_t theOffset = 0;
	if( fgetpos( _fileRecord, &theOffset ) != 0 )
		return 0;
	return theOffset;
}


- (BOOL)	setOffsetInStream: (NSUInteger)inOffset
{
	fpos_t theOffset = inOffset;
	if( fsetpos( _fileRecord, &theOffset ) != 0 )
		return NO;
	return YES;
}


- (NSUInteger)	read: (uint8_t *)buffer maxLength: (NSUInteger)len
{
	size_t readBytes = fread( buffer, 1, len, _fileRecord );
	return readBytes;
}


-(NSData*)	readDataOfLength: (NSUInteger)len
{
	NSMutableData* resData = [NSMutableData dataWithLength: len];
	size_t readBytes = fread( resData.mutableBytes, 1, len, _fileRecord );
	if( readBytes != len )
		[resData setLength: readBytes];
	return resData;
}

@end


@implementation ULIDataInputStream

- (instancetype)	initWithData: (NSData*)inData
{
	self = [super init];
	if( self )
	{
		self.data = inData;
	}
	return self;
}


- (NSUInteger)	offsetInStream
{
	return _offsetInStream;
}

- (BOOL)	setOffsetInStream: (NSUInteger)inOffset
{
	if( inOffset >= self.data.length )
		return NO;
	_offsetInStream = inOffset;
	return YES;
}


- (NSUInteger)	read: (uint8_t *)buffer maxLength: (NSUInteger)len
{
	NSUInteger availableLength = len;
	if( (_offsetInStream + availableLength) > self.data.length )
	{
		availableLength = self.data.length -_offsetInStream;
	}
	[self.data getBytes: buffer range: NSMakeRange( _offsetInStream, availableLength )];
	return availableLength;
}


- (NSData*) readDataOfLength: (NSUInteger)len
{
	return [self.data subdataWithRange: NSMakeRange(_offsetInStream, len)];
}

@end

