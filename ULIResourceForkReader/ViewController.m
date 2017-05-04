//
//  ViewController.m
//  ULIResourceForkReader
//
//  Created by Uli Kusterer on 03.05.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

#import "ViewController.h"
#import "ULIResourceFork.h"
#import "ULIResourceForkStream.h"


@interface ViewController ()

@property ULIResourceFork * fork;

@end


@implementation ViewController

-(IBAction) chooseFile: (id)sender
{
	NSOpenPanel * filePicker = [NSOpenPanel openPanel];
	[filePicker beginSheetModalForWindow: self.view.window completionHandler: ^(NSInteger result)
	{
		if( result == NSFileHandlingPanelOKButton )
		{
			[self.pathControl setURL: filePicker.URL];
			[self updateResourceFileView: self];
		}
	}];
}


-(IBAction) updateResourceFileView: (id)sender
{
	ULIInputStream * fileStream = nil;
	NSURL * theURL = self.pathControl.URL;
	
	if( self.dataForkRadioButton.state == NSOnState )
	{
		fileStream = [ULIInputStream inputStreamWithURL: theURL];
	}
	else if( self.xattrResourceForkRadioButton.state == NSOnState )
	{
		fileStream = [ULIInputStream inputStreamForResourceForkWithURL: theURL];
	}
	else if( self.namedForkResourceForkRadioButton.state == NSOnState )
	{
		fileStream = [ULIInputStream inputStreamWithURL: [theURL URLByAppendingPathComponent: @"..namedfork/rsrc"]];
	}

	[fileStream open];
	NSError * errObj = nil;
	self.fork = [ULIResourceFork resourceForkFromStream: fileStream error: &errObj];
	[fileStream close];
	
	[self.resourceBrowser reloadColumn: 0];
}


-(NSInteger) browser: (NSBrowser *)browser numberOfChildrenOfItem: (nullable id)item
{
	if( item == nil )
		return self.fork.resourceTypes.count;
	else if( [item isKindOfClass: [ULIResourceType class]] )
		return [(ULIResourceType*)item resources].count;
	else
		return 0;
}


-(BOOL)	browser: (NSBrowser *)browser isLeafItem: (id)item
{
	return [item isKindOfClass: [ULIResource class]];
}


-(id) browser: (NSBrowser *)browser child: (NSInteger)index ofItem: (nullable id)item
{
	if( item == nil )
		return self.fork.resourceTypes[self.fork.resourceTypes.allKeys[index]];
	else if( [item isKindOfClass: [ULIResourceType class]] )
		return [(ULIResourceType*)item resources][index];
	else
		return nil;
}


-(nullable id)	browser: (NSBrowser *)browser objectValueForItem: (nullable id)item
{
	if( item == nil )
		return @"File";
	else if( [item isKindOfClass: [ULIResourceType class]] )
		return [(ULIResourceType*)item resourceType];
	else if( [item isKindOfClass: [ULIResource class]] )
	{
		return [NSString stringWithFormat: @"%d \"%@\" %lu bytes", [(ULIResource*)item resourceID], [(ULIResource*)item resourceName], (unsigned long)[(ULIResource*)item resourceData].length];
	}
	else
		return nil;
}

@end
