//
//  AppDelegate.m
//  ULIResourceForkReader
//
//  Created by Uli Kusterer on 03.05.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

#import "AppDelegate.h"
#import "ULIResourceFork.h"
#import "ULIResourceForkStream.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
//	ULIInputStream * fileStream = [ULIInputStream inputStreamWithURL: [NSURL fileURLWithPath: @"/Users/uli/Testfile.rsrc"]];
	ULIInputStream * fileStream = [ULIInputStream inputStreamForResourceForkWithURL: [NSURL fileURLWithPath: @"/Users/uli/Testfile.rsrc"]];
	
	[fileStream open];
	NSError * errObj = nil;
	ULIResourceFork * fork = [ULIResourceFork resourceForkFromStream: fileStream error: &errObj];
	[fileStream close];
	
	if( fork )
	{
		NSLog( @"%@", fork );
	}
	else
	{
		NSLog( @"Error: %@", errObj );
	}
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


@end
